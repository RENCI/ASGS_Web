import pika
import logging.config
from configparser import ConfigParser

from ASGS_Queue_callback import ASGS_Queue_callback


###################################
# main entry point
###################################
if __name__ == "__main__":   
    # load the config
    logging.config.fileConfig('/srv/django/ASGS_Web/messages/logging.conf')#
    
    # create a logger
    logger = logging.getLogger('receive_msg_service_pg')
                
    # retrieve configuration settings
    parser = ConfigParser()
    parser.read('/srv/django/ASGS_Web/messages/msg_settings.ini')

    # set up AMQP credentials and connect to asgs queue
    credentials = pika.PlainCredentials(parser.get('pika', 'username'), parser.get('pika', 'password'))
    
    parameters = pika.ConnectionParameters(parser.get('pika', 'host'),
                                           parser.get('pika', 'port'),
                                           '/',
                                           credentials,
                                           socket_timeout=2)
    
    logger.debug("Configuring ASGS queue receive_msg_service")

    connection = pika.BlockingConnection(parameters)
    
    channel = connection.channel()    
    
    channel.queue_declare(queue='asgs_queue')
    
    logger.debug("ASGS queue declared")
    
    # get an instance to the callback handler
    Queue_callback_inst = ASGS_Queue_callback(logger, parser)
    
    channel.basic_consume(Queue_callback_inst.callback, queue='asgs_queue', no_ack=True)
    
    #print(' [*] Waiting for messages. To exit press CTRL+C')
    logger.info('ASGS queue configured and waiting for messages...')
    
    channel.start_consuming()
