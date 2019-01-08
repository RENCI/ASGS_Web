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
                
    # init the return data
    retVal = '';
    
    # only legal commands can pass
    if reqType in theLegalReqTypes:   
        # init the param value
        paramVal = ''
                     
        # config details need a parameter
        if reqType == 'config_detail':            
            # get any params if there are any
            param = request.GET.get('param')
        
            # its a failure if there was no param passed for this type
            if param is None:
                retVal = 'Invalid or missing parameter.' 
            else:
                paramVal = param

        # if no errors continue
        if retVal == '':
            # create the SQL. raw SQL calls using the django db model need an ID
            theSQL = 'SELECT 1 AS ''id'', public.get_' + reqType + '_json(' + paramVal + ') AS ''data'';'
                
            # get the data
            retVal = str(models.Json.objects.raw(theSQL)[0].data).replace("'", "\"")
        
            # reformat empty data sets
            if retVal == "None":
                retVal = '"None"'
                            
            # events need a wrapper
            if reqType == 'event':
                retVal = 'retry:3000\ndata: {"utilization" : ' + retVal +'} \n\n'
    else:
        retVal = 'Invalid or illegal data request.'
               
    # load the response and it type
    response = HttpResponse(retVal, content_type='text/event-stream')
    response['Cache-Control'] = 'no-cache'
    
    # return the resultant JSON to the caller
    return response