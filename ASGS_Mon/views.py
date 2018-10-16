from django.shortcuts import render
from django.http import HttpResponse
from ASGS_Mon import models
    
# define legal request types
theLegalReqTypes = ['init', 'event']

# main entry point
def index(request):
    return render(request, 'ASGS_Mon/index.html', {})

# gets the running instances
def dataReq(request): 
    # get the request type         
    reqType = request.GET.get('type')

    # only legal commands can pass
    if reqType in theLegalReqTypes:
        # create the SQL. raw SQL calls using the django db model needs a ID
        theSQL = 'SELECT 1 AS ''id'', public.get_' + reqType + '_json() AS ''data'';'
            
        # get the data
        data = str(models.Json.objects.raw(theSQL)[0].data).replace("'", "\"")
    
        # events need a wrapper
        if reqType == 'event':
            data = 'retry:3000\ndata: {"utilization" : ' + data +'} \n\n'
    else:
        data = ''
               
    # load the response and it type
    response = HttpResponse(data, content_type='text/event-stream')
    response['Cache-Control'] = 'no-cache'
    
    # return the resultant JSON to the caller
    return response