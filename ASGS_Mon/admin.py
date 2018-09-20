from django.contrib import admin

from .models import Site_lu, Event_type_lu, Event, Event_group, State_type_lu,Instance_state_type_lu,Instance

admin.site.register(State_type_lu)
admin.site.register(Instance_state_type_lu)
admin.site.register(Event_type_lu)
admin.site.register(Site_lu)
admin.site.register(Instance)
admin.site.register(Event_group)
admin.site.register(Event)
