from django.contrib import admin

from .models import Site_lu, Event_type_lu, Message_type_lu, Message, Event 

admin.site.register(Site_lu)
admin.site.register(Event_type_lu)
admin.site.register(Message_type_lu)
admin.site.register(Message)
admin.site.register(Event)
