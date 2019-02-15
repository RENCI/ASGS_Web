import re
import sys
import pika
import psycopg2
import json
import datetime
from configparser import ConfigParser
from ASGSConstants import ASGSConstants

import logging.config

# load the config
logging.config.fileConfig('/srv/django/ASGS_Web/messages/logging.conf') #

# create logger
logger = logging.getLogger('receive_msg_service_pg')

logger.debug("Starting receive_msg_service")

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

connection = pika.BlockingConnection(parameters)

channel = connection.channel()

channel.queue_declare(queue='asgs_queue')

logger.debug("Receive_msg_service started")

# define and init the object used to handle ASGS constant conversions
ASGSConstants_inst = ASGSConstants(logger)

# just a check to see if there are any event groups defined for this site yet
def get_existing_event_group_id(conn, inst_id):
    logger.debug("inst_id: {0}".format(inst_id))

    # see if there are any event groups yet that have this instance_id
    # this could be caused by a new install that does not have any data in the DB yet
    query = 'SELECT id FROM "ASGS_Mon_event_group" WHERE instance_id={0} ORDER BY id DESC'.format(inst_id)
    
    logger.debug("query: {0}".format(query))
    
    cur = conn.cursor()
    cur.execute(query)
    
    group = cur.fetchone()
    
    if (group is not None):
        existing_group_id = group[0]
    else:
        existing_group_id = -1
        
    logger.debug("existing_group_id: {0}".format(existing_group_id))
    
    return existing_group_id


# just a check to see if there are any instances defined for this site yet
def get_existing_instance_id(conn, site_id , msg_obj):
    logger.debug("site_id: {0}".format(site_id))

    # get the instance name
    instance_name = msg_obj.get("instance_name", "N/A") if (msg_obj.get("instance_name", "N/A") != "") else "N/A"

    # get the process id
    process_id = int(msg_obj.get("uid", "0")) if (msg_obj.get("uid", "0") != "") else 0

    # see if there are any instances yet that have this site_id and instance_name
    # this could be caused by a new install that does not have any data in the DB yet
    query = 'SELECT id FROM "ASGS_Mon_instance" WHERE site_id={0} AND process_id={1} AND instance_name=\'{2}\' AND inst_state_type_id!=9 ORDER BY id DESC'.format(site_id, process_id, instance_name)
                                             
# TODO +++++++++++++++FIX THIS++++++++++++++++++++Add query to get correct stat id for Defunct++++++++++++++++++++++++
# TODO +++++++++++++++FIX THIS++++++++++++++++++++Add day to query too? (to account for rollover of process ids)++++++++++++++++++++++++

    logger.debug("query: {0}".format(query))
    
    cur = conn.cursor()
    cur.execute(query)
    inst = cur.fetchone()
    
    if (inst is not None):
        existing_instance_id = inst[0]
    else:
        existing_instance_id = -1

    logger.debug("existing_instance_id {0}".format(existing_instance_id))
    
    return existing_instance_id


# gets the instance id for a process

def get_instance_id(conn, start_ts, site_id, process_id, instance_name):
    logger.debug("start_ts: {0}, site_id: {1}, process_id: {2}, instance_name:{3}".format(start_ts, site_id, process_id, instance_name))
    
    id = -1

    query = 'SELECT id FROM "ASGS_Mon_instance" WHERE CAST(start_ts as DATE)=\'{0}\' AND site_id={1} AND process_id={2} AND instance_name=\'{3}\''.format(start_ts[:10], site_id, process_id, instance_name)
                                             
    logger.debug("query: " + query)
    cur = conn.cursor()
    cur.execute(query)
    inst = cur.fetchone()

    if (inst is not None):
        id = inst[0]

    logger.debug("returning id: {0}".format(id))
    
    return id   


def update_event_group(conn, state_id, event_group_id, msg_obj):
    # get the storm name
    storm_name = msg_obj.get("storm", "N/A") if (msg_obj.get("storm", "N/A") != "") else "N/A"

    # get the advisory id
    advisory_id = msg_obj.get("advisory_number", "N/A") if (msg_obj.get("advisory_number", "N/A") != "") else "N/A"

    sql_stmt = 'UPDATE "ASGS_Mon_event_group" SET state_type_id ={0}, storm_name=\'{1}\', advisory_id=\'{2}\' WHERE id={3}'.format(state_id, storm_name, advisory_id, event_group_id)
    
    logger.debug("sql_stmt: {0}".format(sql_stmt))
                 
    cur = conn.cursor()
    cur.execute(sql_stmt)


# update instance with latest state_type_id
def update_instance(conn, state_id, site_id, inst_id, msg_obj):
    # get a default time stamp, use it if necessary
    now = datetime.datetime.now()
    ts = now.strftime("%Y-%m-%d %H:%M")
    end_ts = msg_obj.get("date-time", ts) if (msg_obj.get("date-time", ts) != "") else ts

    # get the run params
    run_params = msg_obj.get("run_params", "N/A") if (msg_obj.get("run_params", "N/A") != "") else "N/A"

    sql_stmt = 'UPDATE "ASGS_Mon_instance" SET inst_state_type_id = {0}, end_ts = \'{1}\', run_params = \'{2}\' WHERE site_id = {3} AND id={4}'.format(state_id, end_ts, run_params, site_id, inst_id)
                                               
    logger.debug("sql: {0}".format(sql_stmt))
    
    cur = conn.cursor()
    cur.execute(sql_stmt)

def save_raw_msg(conn, msg):
    logger.debug("msg: {0}".format(msg))

    sql_stmt = 'INSERT INTO "ASGS_Mon_json" (data) VALUES (\'{0}\''.format(msg)
    
    logger.debug("sql: {0}".format(sql_stmt))
    
    cur = conn.cursor()
    cur.execute(sql_stmt)
    

def insert_event(conn, site_id, event_group_id, event_type_id, state_type, msg_obj):
    # get a default time stamp, use it if necessary
    now = datetime.datetime.now()
    ts = now.strftime("%Y-%m-%d %H:%M")
    event_ts = msg_obj.get("date-time", ts) if (msg_obj.get("date-time", ts) != "") else ts
    
    # get the event advisory data
    advisory_id = msg_obj.get("advisory_number", "N/A") if (msg_obj.get("advisory_number", "N/A") != "") else "N/A"

    # get the process data
    process = msg_obj.get("process", "N/A") if (msg_obj.get("process", "N/A") != "") else "N/A"

    # get the percent complete from a LU lookup
    pct_complete = ASGSConstants_inst.getLuId(str(event_type_id), "pct_complete")

    # if there was a message included parse and add it
    if (msg_obj.get("message") is not None and len(msg_obj["message"]) > 0):
        # get rid of any special chars that might mess up postgres
        # backslashes, quote, abd double quote for now
        msg_line = re.sub('\\\|\'|\"', '', msg_obj["message"])

        rawDataCol = ", raw_data"
        msg_line = ", '{0}'".format(msg_line)
    else:
        rawDataCol = ''
        msg_line = ''
    
    # create the fields
    sql_stmt = 'INSERT INTO "ASGS_Mon_event" (site_id, event_group_id, event_type_id, event_ts, advisory_id, pct_complete, process{0}) VALUES ({1}, {2}, {3}, \'{4}\', \'{5}\', {6}, \'{7}\'{8})'.format(rawDataCol, site_id, event_group_id, event_type_id, event_ts, advisory_id, pct_complete, process, msg_line)

    logger.debug("About to insert event record: {0}".format(sql_stmt))
    
    cur = conn.cursor()
    cur.execute(sql_stmt)
   
    logger.debug("Inserted event record: {0}".format(sql_stmt))


def insert_event_group(conn, state_id, inst_id, msg_obj):
    # get a default time stamp, use it if necessary
    now = datetime.datetime.now()
    ts = now.strftime("%Y-%m-%d %H:%M")
    event_group_ts = msg_obj.get("date-time", ts) if (msg_obj.get("date-time", ts) != "") else ts

    # get the storm name
    storm_name = msg_obj.get("storm", "N/A") if (msg_obj.get("storm", "N/A") != "") else "N/A"

    # get the storm number
    storm_number = msg_obj.get("storm_number", "N/A") if (msg_obj.get("storm_number", "N/A") != "") else "N/A"

    # get the event advisory data
    advisory_id = msg_obj.get("advisory_number", "N/A") if (msg_obj.get("advisory_number", "N/A") != "") else "N/A"
     
    sql_stmt = 'INSERT INTO "ASGS_Mon_event_group" (state_type_id, instance_id, event_group_ts, storm_name, storm_number, advisory_id, final_product) VALUES ({0}, {1}, \'{2}\', \'{3}\', \'{4}\', \'{5}\', \'product\') RETURNING id'.format(state_id, inst_id, event_group_ts, storm_name, storm_number, advisory_id)
    
    logger.debug("About to insert event group record: {0}".format(sql_stmt))
    
    cur = conn.cursor()
    cur.execute(sql_stmt)

    logger.debug(" Inserted event group record: {0}".format(sql_stmt))

    return cur.fetchone()[0]


# id | process_id | start_ts | end_ts | run_params | inst_state_type_id | site_id  | instance_name
def insert_instance(conn, state_id, site_id, msg_obj):
    # get a default time stamp, use it if necessary
    now = datetime.datetime.now()
    ts = now.strftime("%Y-%m-%d %H:%M")
    start_ts = end_ts = msg_obj.get("date-time", ts) if (msg_obj.get("date-time", ts) != "") else ts

    # get the run params
    run_params = msg_obj.get("run_params", "N/A") if (msg_obj.get("run_params", "N/A") != "") else "N/A"

    # get the instance name
    instance_name = msg_obj.get("instance_name", "N/A") if (msg_obj.get("instance_name", "N/A") != "") else "N/A"
    
    # get the process id
    process_id = int(msg_obj.get("uid", "0")) if (msg_obj.get("uid", "0") != "") else 0

    # check to make sure this instance doesn't already exists before adding a new one
    #instance_id = get_instance_id(conn, start_ts, site_id, process_id, instance_name)
    #if (instance_id < 0): 

    sql_stmt = 'INSERT INTO "ASGS_Mon_instance" (site_id, process_id, start_ts, end_ts, run_params, instance_name, inst_state_type_id) VALUES ({0}, {1}, \'{2}\', \'{3}\', \'{4}\', \'{5}\', {6}) RETURNING id'.format(site_id, process_id, start_ts, end_ts, run_params, instance_name, state_id)

    logger.debug("About to insert instance record: " + sql_stmt)
    cur = conn.cursor()
    cur.execute(sql_stmt)

    logger.debug(" Inserted instance record: " + sql_stmt)
    return cur.fetchone()[0]

def db_connect():
    logger.debug("Connecting to DB: {0}".format(parser.get('postgres', 'database')))
    
    conn_str = "host={0} port={1} dbname={2} user={3} password={4}".format(parser.get('postgres', 'host'), parser.get('postgres', 'port'), parser.get('postgres', 'database'), parser.get('postgres', 'username'), parser.get('postgres', 'password'))
               
    conn = psycopg2.connect(conn_str)

    return conn
 
#   
# main worker that operates on the incoming message from the queue
#
def callback(ch, method, properties, body):
    #print(" [x] Received %r" % body)
    logger.info("Received %r" % body)
    
    try:
        msg_obj = json.loads(body)

        #open ASGS_Web django db
        conn = db_connect()
    except:
        e = sys.exc_info()[0]
        logger.error("FAILURE - Cannot connect to DB. error: {0}".format(str(e)))
        return

    # get the site id from the name in the message
    site_id, site_name = ASGSConstants_inst.getLuIdFromMsg(msg_obj, "physical_location", "site")
    
    # get the 3vent type if from the event name in the message
    event_type_id, event_name = ASGSConstants_inst.getLuIdFromMsg(msg_obj, "event_type", "event_type")

    # get the 3vent type if from the event name in the message
    state_id, state_name = ASGSConstants_inst.getLuIdFromMsg(msg_obj, "state", "state_type")
    
    # did we get everything needed
    if site_id < 0 or event_type_id < 0 or state_id < 0:
        logger.error("FAILURE - Cannot retrieve site, event type or state type ids.")
        return

    # check to see if there are any instances for this site_id yet
    # this might happen if we start up this process in the middle of a model run
    try:
        inst_id = get_existing_instance_id(conn, site_id, msg_obj)
    except:
        e = sys.exc_info()[0]
        logger.error("FAILURE - Cannot retrieve instance id. error {0}".format(str(e)))
        return
    
    # if this is a STRT event, create a new instance
    if ((inst_id < 0) or (event_name == "STRT" and state_name == "RUNN")):
        logger.debug("create_new_inst is True - creating new inst")
        
        try:
            inst_id = insert_instance(conn, state_id, site_id, msg_obj)
        except:
            e = sys.exc_info()[0]
            logger.error("FAILURE - Cannot insert instance. error {0}".format(str(e)))
            return
    else: # just update instance
        logger.debug("create_new_inst is False - updating inst")
        
        try:
            update_instance(conn, state_id, site_id, inst_id, msg_obj)
        except:
            e = sys.exc_info()[0]
            logger.error("FAILURE - Cannot update instance: " + str(e))
            return


    # check to see if there are any event groups for this site_id and inst yet
    # this might happen if we start up this process in the middle of a model run
    try:
        event_group_id = get_existing_event_group_id(conn, inst_id)
    except:
        e = sys.exc_info()[0]
        logger.error("FAILURE - Cannot retrieve existing event group. error {0}".format(str(e)))
        return

    # if this is the start of a group of Events, create a new event_group record
    # qualifying group initiation: event type = RSTR
    # STRT & HIND do not belong to any event group??
    # For now it is required that every event belong to an event group, so I will add those as well.
    # create a new event group if none exist for this site & instance yet or if starting a new cycle

    # +++++++++++++++++++++++++TODO++++++++++Figure out how to stop creating a second event group
    #   after creating first one, when very first RSTR comes for this instance+++++++++++++++++++

    if ((event_group_id < 0) or (event_name == "RSTR")):
        try:
            event_group_id = insert_event_group(conn, state_id, inst_id, msg_obj)
        except:
            e = sys.exc_info()[0]
            logger.error("FAILURE - Cannot insert event group. error {0}".format(str(e)))
            return
    else:
        # don't need a new event group
        logger.info("event_group_id: {0}".format(event_group_id))

        # update event group with this latest state
        try:
            update_event_group(conn, state_id, event_group_id, msg_obj)
        except:
            e = sys.exc_info()[0]
            logger.error("FAILURE - Cannot update event group. error {0}".format(str(e)))
            return


    # now insert message into the event table
    try:
        insert_event(conn, site_id, event_group_id, event_type_id, state_name, msg_obj)
    except:
        e = sys.exc_info()[0]
        logger.error("FAILURE - Cannot update event group. error {0}".format(str(e)))
        return
     
    # now commit and save
    try:
        conn.commit()
        conn.close()
    except:
        e = sys.exc_info()[0]
        logger.warn("FAILURE - Cannot commit and save to DB. error {0}".format(str(e)))

channel.basic_consume(callback, queue='asgs_queue', no_ack=True)

#print(' [*] Waiting for messages. To exit press CTRL+C')
logger.info(' [*] Waiting for messages ...')

channel.start_consuming()
