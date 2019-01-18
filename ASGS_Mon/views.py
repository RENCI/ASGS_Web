from django.shortcuts import render, redirect
from django.http import HttpResponse

from django.contrib.auth.views import login

from django.contrib import messages
from django.contrib.auth import update_session_auth_hash
from django.contrib.auth.forms import PasswordChangeForm

from ASGS_Mon import models

# renders the change password form
def change_password(request):
    # only allow access to authenticated users
    if request.user.is_authenticated:
        # if this is a post back
        if request.method == 'POST':
            # grab the form data
            form = PasswordChangeForm(request.user, request.POST)
            
            # validate the form
            if form.is_valid():
                # save the form data
                user = form.save()
                
                # update the session authentication
                update_session_auth_hash(request, user)  # Important!
                 
                # head over to the password complete page
                return redirect('change_password_complete')
            else:
                messages.error(request, 'Please correct the error below.')
        else:
            # just render the form
            form = PasswordChangeForm(request.user)
    
        # if we get here just re-render the form
        return render(request, 'core/changepassword.html', {'form': form})
    else:
        # head over to the login page
        return login(request, template_name='core/login.html')

# renders the change password complete form
def change_password_complete(request):
    # only allow access to authenticated users
    if request.user.is_authenticated:
        # render the password change complete page
        return render(request, 'core/changepasswordcomplete.html', {})
    else:
        # head over to the login page
        return login(request, template_name='core/login.html')

# redirect to the correct place when authenticated. otherwise go to the login page
def custom_login(request):
    # only allow access to authenticated users
    if request.user.is_authenticated:
        # render the main page
        return render(request, 'ASGS_Mon/index.html', {})
    else:
        # head over to the login page
        return login(request, template_name='core/login.html')
    
# main entry point
def index(request):
    # only allow access to authenticated users
    if request.user.is_authenticated:
        # render the main page
        return render(request, 'ASGS_Mon/index.html', {})
    else:
        # head over to the login page
        return login(request, template_name='core/login.html')    

# gets the running instances
def dataReq(request): 
    # only allow access to authenticated users
    if request.user.is_authenticated:
        # define legal request types
        theLegalReqTypes = ['init', 'event', 'config_list', 'config_detail']
    
        # get the request type         
        reqType = request.GET.get('type')
                    
        # init the return data
        retVal = '';
        
        # only legal commands can pass
        if reqType in theLegalReqTypes and request.user.is_authenticated:   
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
                   
        # load the response and type, no caching here
        response = HttpResponse(retVal, content_type='text/event-stream')
        response['Cache-Control'] = 'no-cache'
        
        # return the resultant JSON to the caller
        return response
    else:
        # head over to the login page
        return login(request, template_name='core/login.html')    
        