from django.shortcuts import render

from django.http import HttpResponse
from random import randint 

from ASGS_Mon import models

# main entry point
def index(request):
    return render(request, 'ASGS_Mon/index.html', {})

# client-side event request handler
def event(request):

    # compile the info to send back   
    data = 'data: {"sites" : ['

    for e in models.Event.objects.raw('select e.id AS ''id'', s.name AS ''site_name'', mt.name AS ''message_type_name'', e.event_ts AS ''ts'', s.cluster_name AS ''cluster_name'' \
                                ,m.advisory_id AS ''advisory_id'', m.message AS ''message_text'', m.storm_name AS ''storm_name'', s.nodes AS ''total_nodes'', CAST(e.nodes_in_use AS varchar(10)) AS ''nodes_in_use'' \
                                ,m.storm_number AS ''storm_number'', m.other AS ''other'', et.name AS ''event_type_name'', e.nodes_available AS ''nodes_available'' \
                                from ASGS_Mon_event e \
                                join ASGS_Mon_message m on m.id=e.message_id \
                                join ASGS_Mon_message_type_lu mt on mt.id=m.message_type_id \
                                join ASGS_Mon_site_lu s on s.id=e.site_id \
                                join ASGS_Mon_event_type_lu et on et.id=e.event_type_id') :    
        # for each record returned    
        data += '{ \
                        "site" : "' + e.site_name + '", \
                        "info" : \
                        { \
                            "rnd" : ' + str(randint(0,3)) + ', \
                            "cluster_name" : "' + e.cluster_name + '", \
                            "nodes" : ' + str(e.total_nodes) + ', \
                            "nodes_in_use" : ' + str(e.nodes_in_use) + ', \
                            "nodes_available" : ' + str(e.nodes_available) + ', \
                            "type" : "' + str(e.event_type_name) + '", \
                            "datetime" : "' + str(e.ts) + '", \
                            "hurricane" : \
                            { \
                                "storm" : "' + e.storm_name + '", \
                                "storm_number" : "' + e.storm_number + '", \
                                "advisory_number" : "' + e.advisory_id + '" \
                            }, \
                            "weather" :  \
                            { \
                                "message" : "' + e.message_text + '", \
                                "message_type" : "' + str(e.message_type_name) + '" \
                            } \
                        } \
                  },'
    
    # remove the trailing comma
    data = data[:-1]
    
    # finish off the request
    data += '] } \n\n'
    
    # compile the response
    response = HttpResponse(data, content_type='text/event-stream')
    response['Cache-Control'] = 'no-cache'
    
    # return to the caller
    return response
