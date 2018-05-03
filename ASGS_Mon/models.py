from django.db import models

class Site_lu(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length = 50)
    description = models.CharField(max_length = 100)
    cluster_name = models.CharField(max_length = 100)
    nodes = models.IntegerField()
    tech_contact = models.CharField(max_length = 100)
    location = models.CharField(max_length = 100)
    
class Event_type_lu(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length = 50)
    description = models.CharField(max_length = 100)

class Message_type_lu(models.Model):    
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length = 50)
    description = models.CharField(max_length = 100)

class Message(models.Model):
    id = models.AutoField(primary_key=True)
    message_type = models.ForeignKey(Message_type_lu, on_delete=models.PROTECT)
    advisory_id = models.CharField(max_length = 50)
    storm_name = models.CharField(max_length = 50)
    storm_number = models.CharField(max_length = 50)
    message = models.CharField(max_length = 250)
    other = models.CharField(max_length = 250)
    
class Event(models.Model):
    id = models.AutoField(primary_key=True)
    site = models.ForeignKey(Site_lu, on_delete=models.PROTECT)
    event_type = models.ForeignKey(Event_type_lu, on_delete=models.PROTECT)
    message = models.ForeignKey(Message, on_delete=models.PROTECT)
    event_ts = models.DateTimeField()
    nodes_in_use = models.IntegerField()
    nodes_available = models.IntegerField()
    raw_data = models.CharField(max_length = 4000)

