import sys
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
    logger = logging.getLogger(__name__)

    try:         
        logger.info("Initializing receive_msg_queue handler.")
           
        # retrieve configuration settings
        parser = ConfigParser()
        parser.read('/srv/django/ASGS_Web/messages/msg_settings.ini')#
    
        # set up AMQP credentials and connect to asgs queue
        credentials = pika.PlainCredentials(parser.get('pika', 'username'), parser.get('pika', 'password'))
        
        parameters = pika.ConnectionParameters(parser.get('pika', 'host'), parser.get('pika', 'port'), '/', credentials, socket_timeout=2)
        
        connection = pika.BlockingConnection(parameters)
        
        channel = connection.channel()    
        
        channel.queue_declare(queue='asgs_queue')
        
        logger.info("receive_msg_queue channel and queue declared.")
        
        # get an instance to the callback handler
        Queue_callback_inst = ASGS_Queue_callback(parser)
        
        channel.basic_consume(Queue_callback_inst.callback, queue='asgs_queue', no_ack=True)
        
        logger.info('receive_msg_queue configured and waiting for messages...')
        
        channel.start_consuming()
    except:
        e = sys.exc_info()[0]
        logger.error("FAILURE - Problems initiating receive_msg_queue. error {0}".format(str(e)))

    
    