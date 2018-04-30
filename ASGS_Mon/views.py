from django.shortcuts import render

from django.http import HttpResponse
from random import randint

from time import gmtime, strftime

# main entry point
def index(request):
    return render(request, 'ASGS_Mon/index.html', {})

# client-side event request handler
def event(request):
    # compile the info to send back   
    data = \
    'data: {"sites" : \
                [{ \
                    "site" : "RENCI", \
                    "info" : \
                    { \
                        "rnd" : "' + str(randint(0,3)) + '", \
                        "name" : "RENCI", \
                        "type" : "weather | hurricane", \
                        "datetime" : "' + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + '", \
                        "hurricane" : \
                        { \
                            "advisory" : "123", \
                            "other" : "other" \
                        }, \
                        "weather" :  \
                        { \
                            "message" : "This message is to let you know that the ASGS has been ACTIVATED using NAM forcing on the GRIDFILE mesh." \
                        } \
                    } \
                }, \
                { \
                    "site" : "TACC", \
                    "info" : \
                    { \
                        "rnd" : "' + str(randint(0,3)) + '", \
                        "name" : "TACC", \
                        "type" : "weather | hurricane", \
                        "datetime" : "' + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + '", \
                        "hurricane" : \
                        { \
                            "advisory" : "765", \
                            "other" : "other" \
                        }, \
                        "weather" :  \
                        { \
                            "message" : "This message is to let you know that the ASGS has been ACTIVATED using NAM forcing on the GRIDFILE mesh." \
                        } \
                    } \
                }, \
                { \
                    "site" : "LSU", \
                    "info" : \
                    { \
                        "rnd" : "' + str(randint(0,3)) + '", \
                        "name" : "LSU", \
                        "type" : "weather | hurricane", \
                        "datetime" : "' + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + '", \
                        "hurricane" : \
                        { \
                            "advisory" : "65A", \
                            "other" : "other" \
                        }, \
                        "weather" :  \
                        { \
                            "message" : "This message is to let you know that the ASGS has been ACTIVATED using NAM forcing on the GRIDFILE mesh." \
                        } \
                    } \
                }, \
                { \
                    "site" : "UCF", \
                    "info" : \
                    { \
                        "rnd" : "' + str(randint(0,3)) + '", \
                        "name" : "UCF", \
                        "type" : "weather | hurricane", \
                        "datetime" : "' + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + '", \
                        "hurricane" : \
                        { \
                            "advisory" : "456", \
                            "other" : "other" \
                        }, \
                        "weather" :  \
                        { \
                            "message" : "This message is to let you know that the ASGS has been ACTIVATED using NAM forcing on the GRIDFILE mesh." \
                        } \
                    } \
                }, \
                { \
                    "site" : "George Mason", \
                    "info" : \
                    { \
                        "rnd" : "' + str(randint(0,3)) + '", \
                        "name" : "GM", \
                        "type" : "weather | hurricane", \
                        "datetime" : "' + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + '", \
                        "hurricane" : \
                        { \
                            "advisory" : "789", \
                            "other" : "other" \
                        }, \
                        "weather" :  \
                        { \
                            "message" : "This message is to let you know that the ASGS has been ACTIVATED using NAM forcing on the GRIDFILE mesh." \
                        } \
                    } \
                } \
                ] \
            } \n\n'
    
    # compile the response
    response = HttpResponse(data, content_type='text/event-stream')
    response['Cache-Control'] = 'no-cache'
    
    # return to the caller
    return response
