import sys
import pika
import json
import time
from configparser import ConfigParser

def queue_message(message):

    # set up AMQP credentials and connect to asgs queue
    credentials = pika.PlainCredentials(parser.get('pika', 'username'),
                                                parser.get('pika', 'password'))
    parameters = pika.ConnectionParameters(parser.get('pika', 'host'),
                                           parser.get('pika', 'port'),
                                           '/',
                                           credentials,
                                           socket_timeout=2)
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()
    channel.queue_declare(queue="asgs_queue")
    channel.basic_publish(exchange='',routing_key='asgs_queue',body=message)
    connection.close()

# retrieve configuration settings
parser = ConfigParser()
parser.read('./msg_settings.ini')

# open messages file
f = open('message_log.txt')

# while there are messages in the file
for line in f:
    msg_obj = line 
    queue_message(msg_obj)
    print(msg_obj)
    time.sleep(2.5)
