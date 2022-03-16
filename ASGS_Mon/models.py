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
    id = models.AutoField(primary_key=True)
    data = models.CharField(max_length = 4000)

class User_pref(models.Model):
    id = models.AutoField(primary_key=True)
    username = models.CharField(max_length = 150)
    home_site = models.IntegerField(null = True)
    filter_site = JSONField(null = True)

class Chat(models.Model):
    id = models.AutoField(primary_key=True)
    username = models.CharField(max_length = 150)
    message = models.CharField(max_length = 150)
    msg_ts = models.DateTimeField()
    
class Config_item(models.Model):
    id = models.AutoField(primary_key=True)
    instance = models.ForeignKey(Instance, on_delete=models.PROTECT)
    key = models.CharField(max_length = 255)
    value = models.CharField(max_length = 1024)

# Values for now:
# staging
# hazus
# hazus-singleton
# obs-mod
# run-geo-tiff,
# compute-mbtiles-0-10
# compute-mbtiles-11
# compute-mbtiles-12
# load-geo-server
# final-staging
class Supervisor_job_type_lu(models.Model):
    #id = models.CharField(max_length=50, primary_key=True)
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=50)
    description = models.CharField(max_length=100)

# Values for now:
# renci
# aws
class Supervisor_job_location_lu(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=50)
    description = models.CharField(max_length=100)

class Supervisor_config(models.Model):
    id = models.AutoField(primary_key=True)
    job_type = models.ForeignKey(Supervisor_job_type_lu, related_name='job_types', on_delete=models.PROTECT)
    next_job_type = models.ForeignKey(Supervisor_job_type_lu, related_name='next_job_types', on_delete=models.PROTECT)
    job_name = models.CharField(max_length=50)
    job_location = models.ForeignKey(Supervisor_job_location_lu, on_delete=models.PROTECT)
    data_volume_name = models.CharField(max_length=50)   #EX:  "staging-volume-data-",
    ssh_volume_name = models.CharField(max_length=50)    #EX:  "staging-volume-ssh-",
    image = models.CharField(max_length=50)              #EX:   "renciorg/stagedata:0.0.1",
    command_line = models.CharField(max_length=300)       #EX:  ["python", "stage_data.py"],
    command_matrix = models.CharField(max_length=300)     #EX:  [""],
    data_mount_path = models.CharField(max_length=50)    #EX:  "/data",
    ssh_mount_path = models.CharField(max_length=50)     #EX:  "/root/.ssh"
    sub_path = models.CharField(max_length=50)           #EX:  "/input",
    additional_path = models.CharField(max_length=50)    #EX:  "/",
    memory = models.CharField(max_length=50)             #EX:  "10M",
    node_type = models.CharField(max_length=50)          #EX:  "large"
    cpus = models.CharField(null=True, max_length=10)     #EX:  "10000m"
