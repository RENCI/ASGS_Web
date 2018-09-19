from django.shortcuts import render
from django.http import HttpResponse

from ASGS_Mon import models

# main entry point
def index(request):
    return render(request, 'ASGS_Mon/index.html', {})

# gets the running instances
def init(request):        
    siteInstances = "";
    
    # create the SQL
    theSQL = 'select i.id AS ''id'', s.name AS ''site_name'', s.cluster_name AS ''cluster_name'', i.process_id AS ''process_id'', i.run_params AS ''run_params''  \
             from ASGS_Mon_instance i \
             join ASGS_Mon_site_lu s ON s.id=i.site_id;'
                                           
    # TODO: use native django object models to get this data rather than direct SQL
    for e in models.Event.objects.raw(theSQL) :               
        # load the data used to populate each bar graph        
        siteInstances += '{\
                            "instance_id" : "' + str(e.id) + '", \
                            "process_id" : "' + str(e.process_id) + '", \
                            "run_params" : "' + e.run_params + '", \
                            "title" : "' + e.site_name  + '", \
                            "subtitle" : "' + e.cluster_name + '", \
                            "message" : "", \
                            "ranges" : [100], \
                            "measures" : [0], \
                            "markers" : [0] \
                        },'

    # remove the trailing commas and create a json array
    siteInstances = "[" + siteInstances[:-1] + ']'
    
    # load the response and it type
    response = HttpResponse(siteInstances, content_type='text/event-stream')
    response['Cache-Control'] = 'no-cache'
    
    # return the resultant JSON to the caller
    return response
    
# client-side event request handler to populate the information in each instance view
def event(request):
    # define a variable that controls the event source reload time.
    retryMilliSec = '3000';

    # compile the info to send back   
    data = '';
    
    # create the SQL
    theSQL = 'select e.id AS ''id'', s.name AS ''site_name'', eg.id AS ''eg_id'', etl.name AS ''event_type_name'', e.event_ts AS ''ts'', s.cluster_name AS ''cluster_name'', eg.advisory_id AS ''advisory_id'', \
             etl.description AS ''message_text'', etl.pct_complete AS ''def_pct_complete'', e.pct_complete AS ''pct_complete'', stlgrp.description AS ''group_state'', stlgrp.id AS ''group_state_id'', istlu.description AS ''cluster_state'', \
             istlu.id AS ''cluster_state_id'', eg.storm_name AS ''storm_name'', eg.storm_number AS ''storm_number'', etl.name AS ''event_type_name'', i.process_id as ''process_id'', i.id as ''instance_id'' \
             from ASGS_Mon_instance i \
             join ASGS_Mon_site_lu s ON s.id=i.site_id \
             join ASGS_Mon_event_group eg ON eg.instance_id=i.id \
             join ASGS_Mon_event e on e.event_group_id=eg.id \
             join ASGS_Mon_event_type_lu etl ON etl.id=e.event_type_id \
             join ASGS_Mon_state_type_lu stlgrp ON stlgrp.id=eg.state_type_id \
             join ASGS_Mon_instance_state_type_lu istlu ON istlu.id=i.inst_state_type_id \
             inner join (select max(id) AS id from ASGS_Mon_event group by event_group_id) AS meid ON meid.id=e.id \
             inner join (select max(id) AS id, instance_id from ASGS_Mon_event_group group by instance_id) AS megid ON megid.id=e.event_group_id AND megid.instance_id=i.id;'
                                           
    # TODO: use native django object models to get this data rather than direct SQL
    for e in models.Event.objects.raw(theSQL) :    
        # save the pct complete from the event
        pct_complete = e.pct_complete

        # if the pct on the event is 0 use the default value
        if pct_complete == 0:
            pct_complete = e.def_pct_complete
            
        # load the data used to populate each bar graph        
        data += '{\
                    "title" : "' + e.site_name  + '", \
                    "instance_id" : "' + str(e.instance_id) + '", \
                    "process_id" : "' + str(e.process_id) + '", \
                    "cluster_name" : "' + e.cluster_name + '", \
                    "cluster_state" : "' + e.cluster_state + '", \
                    "cluster_state_id" : "' + str(e.cluster_state_id) + '", \
                    \
                    "ranges" : [100], \
                    "measures" : [' + str(pct_complete) + '], \
                    "markers" : [0], \
                    \
                    "eg_id" : "' + str(e.eg_id)  + '", \
                    "group_state" : "' + e.group_state + '", \
                    "group_state_id" : "' + str(e.group_state_id) + '", \
                    \
                    "type" : "' + str(e.event_type_name) + '", \
                    "event_message" : "Storm ' + e.storm_name + ': ' + e.message_text + ' for advisory number ' + e.advisory_id + '.", \
                    "pct_complete" : "' + str(pct_complete) + '", \
                    "datetime" : "' + str(e.ts) + '", \
                    "message" : "' + e.message_text + '", \
                    "storm" : "' + e.storm_name + '", \
                    "storm_number" : "' + e.storm_number + '", \
                    "advisory_number" : "' + e.advisory_id + '" \
                },'

    # remove the trailing commas
    data = 'retry:' + retryMilliSec + '\ndata: {"utilization" : [' + data[:-1] +']} \n\n'
    
    # load the response and it type
    response = HttpResponse(data, content_type='text/event-stream')
    response['Cache-Control'] = 'no-cache'
    
    # return the resultant JSON to the caller
    return response
