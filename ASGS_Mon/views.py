from django.shortcuts import render
from django.http import HttpResponse
from ASGS_Mon import models
    
# define legal request types
theLegalReqTypes = ['init', 'event', 'config_list', 'config_detail']

# main entry point
def index(request):
    return render(request, 'ASGS_Mon/index.html', {})

# gets the running instances
def dataReq(request): 
    # get the request type         
    reqType = request.GET.get('type')
    param = request.GET.get('param')
    
    # if there was no param passed just init the paramval used to an empty string
    if param is None: 
        paramVal = '' 
    else:
        paramVal = param
        
    # only legal commands can pass
    if reqType in theLegalReqTypes:
        
        # create the SQL. raw SQL calls using the django db model need an ID
        theSQL = 'SELECT 1 AS ''id'', public.get_' + reqType + '_json(' + paramVal + ') AS ''data'';'
            
        # get the data
        data = str(models.Json.objects.raw(theSQL)[0].data).replace("'", "\"")
    
        if data == "None":
            data = '"None"'
            
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