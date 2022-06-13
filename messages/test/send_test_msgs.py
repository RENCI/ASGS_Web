import sys
import pika
import json
import os
import time
from configparser import ConfigParser

def queue_message(message):

    # set up AMQP credentials and connect to asgs queue
    credentials = pika.PlainCredentials(os.environ.get("RABBITMQ_USER"), os.environ.get("RABBITMQ_PW"))
    parameters = pika.ConnectionParameters(os.environ.get("RABBITMQ_HOST"), 5672, '/', credentials, socket_timeout=2)

    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()

    #channel.queue_declare(queue="asgs_queue")
    #channel.queue_declare(queue="asgs_props")

    #channel.basic_publish(exchange='',routing_key='asgs_queue',body=message)
    #channel.basic_publish(exchange='',routing_key='asgs_props',body=message)
    connection.close()

# retrieve configuration settings
# parser = ConfigParser()
# parser.read('./msg_settings.ini')

# open messages file
f = open('run.properties.json')
#f = open('message_log.txt')
#f = open('config_msg_example.txt')
#f = open('config_msg_example3.txt')

# while there are messages in the file
for line in f:
    msg_obj = line 
    queue_message(msg_obj)
    print(msg_obj)
    time.sleep(2)
