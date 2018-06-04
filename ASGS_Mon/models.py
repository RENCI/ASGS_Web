from django.db import models

class State_type_lu(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length = 50)
    description = models.CharField(max_length = 100)
    view_order = models.IntegerField()
    
class Event_type_lu(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length = 50)
    description = models.CharField(max_length = 100)
    view_order = models.IntegerField()
    
class Site_lu(models.Model):
    id = models.AutoField(primary_key=True)
    state_type = models.ForeignKey(State_type_lu, on_delete=models.PROTECT)
    name = models.CharField(max_length = 50)
    description = models.CharField(max_length = 100)
    cluster_name = models.CharField(max_length = 100)
    tech_contact = models.CharField(max_length = 100)
    phys_location = models.CharField(max_length = 100)
    
class Event_group(models.Model):    
    id = models.AutoField(primary_key=True)
    site = models.ForeignKey(Site_lu, on_delete=models.PROTECT)
    state_type = models.ForeignKey(State_type_lu, on_delete=models.PROTECT)
    event_group_ts = models.DateTimeField()
    storm_name = models.CharField(max_length = 50)
    storm_number = models.CharField(max_length = 50)
    advisory_id = models.CharField(max_length = 50)
    final_product = models.CharField(max_length = 1000)


class Event(models.Model):
    id = models.AutoField(primary_key=True)
    site = models.ForeignKey(Site_lu, on_delete=models.PROTECT)
    event_group = models.ForeignKey(Event_group, on_delete=models.PROTECT)
    event_type = models.ForeignKey(Event_type_lu, on_delete=models.PROTECT)
    event_ts = models.DateTimeField()
    advisory_id = models.CharField(max_length = 50)
    pct_complete = models.FloatField()
    host_start_file = models.CharField(max_length = 1000)
    raw_data = models.CharField(max_length = 4000)

