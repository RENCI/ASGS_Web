import re
import sys
import pika
import psycopg2
import json
import datetime
import thread
import logging
#from threading import thread
from configparser import ConfigParser

# set up logging
logfile = "rcv_cfg_svc.log"
logging.basicConfig(filename=logfile, format='%(asctime)s %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p', level=logging.INFO)
logging.info("Started receive config service")

# retrieve configuration settings
parser = ConfigParser()
parser.read('/srv/django/ASGS_Web/messages/msg_settings.ini')

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

channel.queue_declare(queue='asgs_config')


def db_connect():
    logging.debug("Connecting to DB: " + parser.get('postgres', 'database'))
    conn_str = "host=" + parser.get('postgres', 'host') + \
               " port=" + parser.get('postgres', 'port') + \
               " dbname=" + parser.get('postgres', 'database') + \
               " user=" + parser.get('postgres', 'username') + \
               " password=" + parser.get('postgres', 'password')
    conn = psycopg2.connect(conn_str)

    return conn


def get_site_id(conn, msg_obj):
    site_name = ""
    if (msg_obj.get("physical_location") is not None and len(msg_obj["physical_location"]) > 0):
        site_name = msg_obj["physical_location"]
    else:
        logging.error("NO SITE NAME PROVIDED - must drop message!")
        return
    query = 'SELECT id FROM "ASGS_Mon_site_lu" where name=' + "'" + site_name + "'"
    logging.debug("query=" + query)
    cur = conn.cursor()
    cur.execute(query)
    site_lu = cur.fetchone()
    site_id = site_lu[0]
    logging.info("SITE_NAME=" + site_name + " SITE_ID=" + str(site_id))

    return site_id


# ++++++++++++++++WORRY++++++++++++++++++++++++++++++++++++++++
# there may be a problem with timing when an instance gets created and when an instance config message is sent
# does this mean that a create instance for regular messages always creates an empty instance config record, and the this process
# just updates the config message field?? Need to think about this
# SOLVED WITH THREADING!!!
# This thread will keep check for an existing instance id until a given timeout is reached
# then the insert will be abandoned, and the error will be logged

def process_msg_thread(logging, conn, site_id, msg_obj, timeout=30):
    from time import time, sleep

    logging.debug("In process_msg_thread: site_id=" + str(site_id))
    # set up a timeout - give on on this instance config
    # if the instance does not get created with a specific time

    time_started = time() 

    while True:

        if (time() > (time_started + timeout)):
            logging.error("FAILURE - THREAD TIMEOUT: msg_obj=" + str(msg_obj))
            return

        # look for this instance id
        instance_name = "N/A"
        if (msg_obj.get("instance_name") is not None and len(str(msg_obj["instance_name"])) > 0):
            instance_name = str(msg_obj["instance_name"])

        process_id = 0
        if (msg_obj.get("uid") is not None and len(str(msg_obj["uid"])) > 0):
            process_id = int(msg_obj["uid"])

        # see if there are any instances yet that have this site_id and instance_name
        query = 'SELECT id FROM "ASGS_Mon_instance" WHERE site_id=' + str(site_id) + \
                                                 " AND process_id=" + str(process_id) + \
                                                 " AND instance_name='" + instance_name + "'" + \
                                                 " AND inst_state_type_id!=9" + \
                                                 " ORDER BY id DESC"
# TODO +++++++++++++++FIX THIS++++++++++++++++++++Add query to get correct stat id for Defunct++++++++++++++++++++++++
# TODO +++++++++++++++FIX THIS++++++++++++++++++++Add day to query too? (to account for rollover of process ids)++++++++++++++++++++++++
        
        logging.debug("query: " + query)
        cur = conn.cursor()
        cur.execute(query)
        
        # has this instance been created yet??
        instance = cur.fetchone()
        if (instance is not None):
            instance_id = instance[0]
            logging.debug("insert_instance_config: instance_id=" + str(instance_id))

            # now insert this intance config record for the found instance id
            sql_fields = 'INSERT INTO "ASGS_Mon_instance_config" ('
            sql_values = " VALUES ("
    
            sql_fields += "instance_id, "
            sql_values += str(instance_id) + ", "

            config_type = ""
            if (msg_obj.get("name") is not None and len(msg_obj["name"]) > 0):
                config_type = msg_obj.get("name")

            if (config_type == "asgs"):
                sql_fields += "asgs_config"
            else:
                sql_fields += "adcirc_config"
    
            if (msg_obj.get("message") is not None and len(msg_obj["message"]) > 0):
                sql_values += "'" + msg_obj["message"] + "'"
            else:
                sql_values += "'N/A'"

            sql_stmt = sql_fields + sql_values
            sql_stmt += " RETURNING id"

            logging.debug("About to insert instance config record: " + sql_stmt)
            cur = conn.cursor()
            cur.execute(sql_stmt)

            # now commit and save
            try:
                conn.commit()
                cur.close()
                conn.close()
            except:
                e = sys.exc_info()[0]
                logging.warn("FAILURE - Cannot commit and save to DB" + str(e))

            logging.debug(" Inserted instance config record")

            # Done! thread finished task
            return

        else:
            # wait a little bit and try again
            sleep(1)


def fix_message_param(msg_body):

    logging.debug("Fixing message variable in msg body: " + str(msg_body))

    value_start = msg_body.find(', "message":', 0)
    value_start += 14
    value_end = msg_body.find('", "date-time":', value_start) 
    value_str = msg_body[value_start : value_end]

    tmp_value = value_str.replace('"', '\\"')
    new_value = tmp_value.replace("'", "\\'")
    new_msg_body = msg_body.replace(value_str, new_value)

    return new_msg_body


def callback(ch, method, properties, body):
    #print(" [x] Received %r" % body)
    logging.info(" [x] Received %r" % body)

    try:
        # for now the message variable of this dict contains some
        # char sequences that json cannot parse - this temp funct 
        # fixes that by adding some back slashes
        new_body = fix_message_param(body)
        msg_obj = json.loads(new_body)

        #open ASGS_Web django db
        conn = db_connect()
    except:
        e = sys.exc_info()[0]
        logging.error("FAILURE - Cannot connect to DB: " + str(e))
        return

    # get site_id for this msg site
    site_id = get_site_id(conn, msg_obj)

    # if no valid site found, ignore message
    if (site_id < 0):
      return

    # launch thread to check for the existance of this instance
    thread.start_new_thread(process_msg_thread, (logging, conn, site_id, msg_obj) )


channel.basic_consume(callback,
                      queue='asgs_config',
                      no_ack=True)

#print(' [*] Waiting for messages. To exit press CTRL+C')
logging.info(' [*] Waiting for messages ...')
channel.start_consuming()
