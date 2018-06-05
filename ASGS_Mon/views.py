from django.shortcuts import render
from django.http import HttpResponse

from random import randint 
from ASGS_Mon import models

# main entry point
def index(request):
    return render(request, 'ASGS_Mon/index.html', {})

# client-side event request handler
def event(request):
    # define a variable that controls the event source reload time.
    retryMilliSec = '3000'
    
    # compile the info to send back   
    data = 'retry:' + retryMilliSec + '\ndata: {"sites" : ['
    utilization = '';
    
    # TODO: use native django object models to get this data rather than direct SQL
    for e in models.Event.objects.raw('select e.id AS ''id'', s.name AS ''site_name'', etl.name AS ''event_type_name'', e.event_ts AS ''ts'', s.cluster_name AS ''cluster_name'' \
                                               ,eg.advisory_id AS ''advisory_id'', etl.description AS ''message_text'', e.pct_complete AS ''pct_complete'', stl.name AS ''state'' \
                                               ,eg.storm_name AS ''storm_name'', eg.storm_number AS ''storm_number'', etl.name AS ''event_type_name'', e.process as ''process'' \
                                       from ASGS_Mon_event e \
                                       join ASGS_Mon_site_lu s ON s.id=e.site_id join ASGS_Mon_event_group eg ON eg.id=e.event_group_id join ASGS_Mon_event_type_lu etl ON etl.id=e.event_type_id \
                                       join ASGS_Mon_state_type_lu stl ON stl.id=eg.state_type_id \
                                       inner join (select max(id) AS id from ASGS_Mon_event group by site_id) AS meid ON meid.id=e.id \
                                       inner join (select max(id) AS id, site_id from ASGS_Mon_event_group group by site_id) AS megid ON megid.id=e.event_group_id AND megid.site_id=e.site_id;') :    
        # TODO: move to use native python arrays and then make call to convert to JSON
        # for each record returned. may be problematic because of specialized input to UI  
        data += '{ \
                        "site" : "' + e.site_name + '", \
                        "info" : \
                        { \
                            "rnd" : ' + str(randint(0,3)) + ', \
                            "cluster_name" : "' + e.cluster_name + '", \
                            "type" : "' + str(e.event_type_name) + '", \
                            "pct_complete" : "' + str(e.pct_complete) + '", \
                            "process" : "' + str(e.process) + '", \
                            "state" : "' + e.state + '", \
                            "datetime" : "' + str(e.ts) + '", \
                            "message" : "' + e.message_text + '", \
                            "storm" : "' + e.storm_name + '", \
                            "storm_number" : "' + e.storm_number + '", \
                            "advisory_number" : "' + e.advisory_id + '" \
                        } \
                  },'
    

        # load the data used to populate each bar graph        
        utilization += '{"title" : "' + e.site_name  + '", "subtitle" : "' + e.cluster_name + '", "event_message" : "' + e.message_text + '", "ranges" : [0, 0, 100], "measures" : [0,' + str(e.pct_complete) + '], "markers" : [0]},'

    # remove the trailing commas
    data = data[:-1]
    utilization = utilization[:-1]
    
    #add in the utilization
    data += '], "utilization" : [' + utilization + ']} \n\n'
    
    # load the response and it type
    response = HttpResponse(data, content_type='text/event-stream')
    response['Cache-Control'] = 'no-cache'
    
    # return the resultant JSON to the caller
    return response
