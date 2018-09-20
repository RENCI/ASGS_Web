from django.shortcuts import render
from django.http import HttpResponse
from ASGS_Mon import models
    
# main entry point
def index(request):
    return render(request, 'ASGS_Mon/index.html', {})

# gets the running instances
def init(request):           
    # create the SQL. raw SQL calls using the django db model needs a ID
    theSQL = 'SELECT 1 AS ''id'', public.get_init_json() AS ''data'';'
            
    # load the response and it type
    response = HttpResponse(str(models.Json.objects.raw(theSQL)[0].data).replace("'", "\""), content_type='text/event-stream')
    response['Cache-Control'] = 'no-cache'
    
    # return the resultant JSON to the caller
    return response
    
# client-side event request handler to populate the information in each instance view
def event(request):
    # create the SQL. raw SQL calls using the django db model needs a ID
    theSQL = 'SELECT 1 AS ''id'', public.get_event_json() AS ''data'';'
            
    # build the response
    data = 'retry:3000\ndata: {"utilization" : ' + str(models.Json.objects.raw(theSQL)[0].data).replace("'", "\"") +'} \n\n'
    
    # load the response and it type
    response = HttpResponse(data, content_type='text/event-stream')
    response['Cache-Control'] = 'no-cache'
    
    # return the resultant JSON to the caller
    return response
