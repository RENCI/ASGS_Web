from django.db import models
from django.contrib.postgres.fields import JSONField

class State_type_lu(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length = 50)
    description = models.CharField(max_length = 100)

class Instance_state_type_lu(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length = 50)
    description = models.CharField(max_length = 100)
    
class Event_type_lu(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length = 50)
    description = models.CharField(max_length = 100)
    pct_complete = models.IntegerField()
    
class Site_lu(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length = 50)
    description = models.CharField(max_length = 100)
    cluster_name = models.CharField(max_length = 100)
    tech_contact = models.CharField(max_length = 100)
    phys_location = models.CharField(max_length = 100)
    
class Instance(models.Model):
    id = models.AutoField(primary_key=True)
    process_id = models.BigIntegerField()
    site = models.ForeignKey(Site_lu, on_delete=models.PROTECT)
    inst_state_type = models.ForeignKey(Instance_state_type_lu, on_delete=models.PROTECT)
    start_ts = models.DateTimeField()
    end_ts = models.DateTimeField(null = True)
    run_params = models.CharField(max_length = 100)
    instance_name = models.CharField(max_length = 100)

    class Meta:
        unique_together = (('id', 'process_id'))
    
class Event_group(models.Model):    
    id = models.AutoField(primary_key=True)
    instance = models.ForeignKey(Instance, on_delete=models.PROTECT)
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
    pct_complete = models.IntegerField()
    sub_pct_complete = models.IntegerField()
    process = models.CharField(max_length = 100)
    raw_data = models.CharField(max_length = 4000)


class Instance_config(models.Model):
    id = models.AutoField(primary_key=True)
    instance = models.ForeignKey(Instance, on_delete=models.PROTECT)
    adcirc_config = models.TextField()
    asgs_config = models.TextField()

class Json(models.Model):
    data = models.CharField(max_length = 4000)

class User_pref(models.Model):
    id = models.AutoField(primary_key=True)
    username = models.CharField(max_length = 150)
    home_site = models.IntegerField()
    filter_site = JSONField()
