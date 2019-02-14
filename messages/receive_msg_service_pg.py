import re
import sys
import pika
import psycopg2
import json
import datetime
from configparser import ConfigParser
from ASGSConstants import ASGSConstants

import logging
import log

# initialize the logging
logger = log.setup('The_log', log_level=logging.DEBUG)

# define the constants used in here
ASGSConstants_inst = ASGSConstants(logger)

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

channel.queue_declare(queue='asgs_queue')

logger.info("Started receive_msg_service")

# just a check to see if there are any event groups defined for this site yet
def get_existing_event_group_id(conn, inst_id):
    logger.debug("get_existing_event_group_id: inst_id=" + str(inst_id))

    existing_group_id = -1

    # see if there are any event groups yet that have this instance_id
    # this could be caused by a new install that does not have any data in the DB yet
    query = 'SELECT id FROM "ASGS_Mon_event_group" WHERE instance_id=' + str(inst_id) + ' ORDER BY id DESC'
    logger.debug("query=" + query)
    cur = conn.cursor()
    cur.execute(query)
    group = cur.fetchone()
    if (group is not None):
        existing_group_id = group[0]

    logger.debug("existing_group_id=" + str(existing_group_id))
    return existing_group_id


# just a check to see if there are any instances defined for this site yet
def get_existing_instance_id(conn, site_id , msg_obj):
    logger.debug("get_existing_instance_id: site_id=" + str(site_id))

    existing_instance_id = -1

    instance_name = "N/A"
    if (msg_obj.get("instance_name") is not None and len(str(msg_obj["instance_name"])) > 0):
        instance_name = str(msg_obj["instance_name"])

    process_id = 0
    if (msg_obj.get("uid") is not None and len(str(msg_obj["uid"])) > 0):
        process_id = int(msg_obj["uid"])

    # see if there are any instances yet that have this site_id and instance_name
    # this could be caused by a new install that does not have any data in the DB yet
    query = 'SELECT id FROM "ASGS_Mon_instance" WHERE site_id=' + str(site_id) + \
                                             " AND process_id=" + str(process_id) + \
                                             " AND instance_name='" + instance_name + "'" + \
                                             " AND inst_state_type_id!=9" + \
                                             " ORDER BY id DESC"
                                             
# TODO +++++++++++++++FIX THIS++++++++++++++++++++Add query to get correct stat id for Defunct++++++++++++++++++++++++
# TODO +++++++++++++++FIX THIS++++++++++++++++++++Add day to query too? (to account for rollover of process ids)++++++++++++++++++++++++

    logger.debug("query=" + query)
    cur = conn.cursor()
    cur.execute(query)
    inst = cur.fetchone()
    if (inst is not None):
        existing_instance_id = inst[0]

    logger.debug("existing_instance_id=" + str(existing_instance_id))
    return existing_instance_id


# gets the instance id for a process

def get_instance_id(conn, start_ts, site_id, process_id, instance_name):
    logger.debug("get_instance_id: start_ts=" + str(start_ts) + " site_id=" + str(site_id) + \
                                 " process_id=" + str(process_id) + " instance_name=" + instance_name)
    id = -1

    query = 'SELECT id FROM "ASGS_Mon_instance" WHERE CAST(start_ts as DATE)=' + "'" + start_ts[:10] + \
                                             "' AND site_id=" + str(site_id) + \
                                             " AND process_id=" + str(process_id) + \
                                             " AND instance_name='" + str(instance_name) + "'"
    logger.debug("About to find existing instance: " + query)
    cur = conn.cursor()
    cur.execute(query)
    inst = cur.fetchone()

    logger.debug("After query")

    if (inst is not None):
        id = inst[0]

    logger.debug("returning id=" + str(id))
    return id   


def update_event_group(conn, state_id, event_group_id, msg_obj):
    logger.debug("update_event_group: state_id=" + str(state_id) + " event_group_id=" + str(event_group_id))

    storm_name = "N/A"
    if (msg_obj.get("storm") is not None and len(str(msg_obj["storm"])) > 0):
        storm_name = str(msg_obj["storm"])

    advisory_id = "N/A"
    if (msg_obj.get("advisory_number") is not None and len(str(msg_obj["advisory_number"])) > 0):
        advisory_id = str(msg_obj["advisory_number"])

    sql_stmt = 'UPDATE "ASGS_Mon_event_group" SET state_type_id =' + str(state_id) + \
                                            ", storm_name='" + storm_name + "'" + \
                                            ", advisory_id='" + str(advisory_id) + "'" + \
                                            " WHERE id=" + str(event_group_id)
    logger.debug("sql_stmt=" + sql_stmt)
    cur = conn.cursor()
    cur.execute(sql_stmt)


# update instance with latest state_type_id
def update_instance(conn, state_id, site_id, inst_id, msg_obj):
    logger.debug("update_instance: state_id=" + str(state_id) + " site_id=" + str(site_id) + " inst_id=" + str(inst_id))

    now = datetime.datetime.now()
    end_ts = now.strftime("%Y-%m-%d %H:%M")
    if (msg_obj.get("date-time") is not None and len(str(msg_obj["date-time"])) > 0):
        end_ts =  str(msg_obj["date-time"])

    run_params = "N/A"
    if (msg_obj.get("run_params") is not None and len(str(msg_obj["run_params"])) > 0):
        run_params = str(msg_obj["run_params"])

    sql_stmt = 'UPDATE "ASGS_Mon_instance" SET inst_state_type_id = ' + str(state_id) + \
                                               ", end_ts = '" + str(end_ts) + "'" \
                                               ", run_params = '" + str(run_params) + "'" \
                                               " WHERE site_id = " + str(site_id) + " AND id=" + str(inst_id)
    logger.debug("About to update instance: " + sql_stmt)
    cur = conn.cursor()
    cur.execute(sql_stmt)


# get the correct percent complete for an event type
def get_pctcomplete(conn, event_type_id):
    logger.debug("get_pctcomplete: event_type_id=" + str(event_type_id))

    query = 'SELECT pct_complete FROM "ASGS_Mon_event_type_lu" WHERE id=' + str(event_type_id)
    logger.debug("query=" + query)
    cur = conn.cursor()
    cur.execute(query)
    event_lu = cur.fetchone()
    pct_complete  = event_lu[0]
       
    return pct_complete

def save_raw_msg(conn, msg):
    logger.debug("save_raw_msg: msg=" + msg)

    sql_stmt = 'INSERT INTO "ASGS_Mon_json" (data) VALUES(' + msg + "')"
    logger.debug("query to insert raw message=" + sql_stmt)
    cur = conn.cursor()
    cur.execute(sql_stmt)
    

def insert_event(conn, site_id, event_group_id, event_type_id, state_type, msg_obj):
    logger.debug("insert_event: site_id=" + str(site_id) + " event_group_id=" + str(event_group_id) + \
                              " event_type_id=" + str(event_type_id) + " state_type=" + str(state_type))

    sql_fields = 'INSERT INTO "ASGS_Mon_event" ('
    sql_values = " VALUES ("

    # now construct SQL INSERT statement for the event table
    sql_fields += "site_id, "
    sql_values += str(site_id) + ", "

    sql_fields += "event_group_id, "
    sql_values += str(event_group_id) + ", "

    sql_fields += "event_type_id, "
    sql_values += str(event_type_id) + ", "

    sql_fields += "event_ts, "
    if (msg_obj.get("date-time") is not None and len(msg_obj["date-time"]) > 0):
        sql_values += "'" + msg_obj["date-time"] + "', "
    else:
        sql_values += "'N/A', "

    sql_fields += "advisory_id, "
    if (msg_obj.get("advisory_number") is not None and len(str(msg_obj["advisory_number"])) > 0):
        sql_values += "'" + str(msg_obj["advisory_number"]) + "', "
    else:
        sql_values += "'N/A', "


    # for now (until detail page is developed)
    # ignore intermediary cluster job completion percentage
    sql_fields += "pct_complete, "
    pct_complete = get_pctcomplete(conn, event_type_id)
    sql_values += str(pct_complete) + ", "

    #if ((state_type =="CMPL") or (int(pct_complete) < 20)):
        #sql_values += str(pct_complete) + ", "
    #else: #this should still be the previous pct amount - 20 less - until completion of the event
        #sql_values += str(int(pct_complete)-20) + ", "
                
    #pctcomplete = "0"
    #if (msg_obj.get("pctcomplete") is not None and len(msg_obj["pctcomplete"]) > 0):
        #pctcomplete = msg_obj["pctcomplete"]
        #sql_values += pctcomplete + ", "


    sql_fields += "process, "
    if (msg_obj.get("process") is not None and len(msg_obj["process"]) > 0):
        sql_values += "'" + msg_obj["process"] + "', "
    else:
        sql_values += "'N/A', "

    if (msg_obj.get("message") is not None and len(msg_obj["message"]) > 0):
        # get rid of any special chars that might mess up postgres
        # backslashes, quote, abd double quote for now
        msg_line = re.sub('\\\|\'|\"', '', msg_obj["message"])

        logger.debug("msg_line=" + msg_line)

        sql_fields += "raw_data)"
        sql_values += "'" + msg_line + "') "

    # add to message table
    sql_stmt = sql_fields + sql_values

    logger.debug("About to insert event record:" + sql_stmt)
    cur = conn.cursor()
    cur.execute(sql_stmt)
   
    logger.debug(" Inserted event record: " + sql_stmt)


def insert_event_group(conn, state_id, inst_id, msg_obj):
    logger.debug("insert_event_group: state_id=" + str(state_id) + " inst_id=" + str(inst_id))

    sql_fields = 'INSERT INTO "ASGS_Mon_event_group" ('
    sql_values = " VALUES ("

    sql_fields += "state_type_id, "
    sql_values += str(state_id) + ", "

    sql_fields += "instance_id, "
    sql_values += str(inst_id) + ", "

    sql_fields += "event_group_ts, "
    if (msg_obj.get("date-time") is not None and len(msg_obj["date-time"]) > 0):
        sql_values += "'" + msg_obj["date-time"] + "', "
    else:
        sql_values += "'N/A', "
 
    sql_fields += "storm_name, "
    if (msg_obj.get("storm") is not None and len(msg_obj["storm"]) > 0):
        sql_values += "'" + msg_obj["storm"] + "', "
    else:
        sql_values += "'N/A', "

    sql_fields += "storm_number, "
    if (msg_obj.get("storm_number") is not None and len(str(msg_obj["storm_number"])) > 0):
        sql_values += "'" + str(msg_obj["storm_number"]) + "', "
    else:
        sql_values += "'N/A', "

    sql_fields += "advisory_id, "
    if (msg_obj.get("advisory_number") is not None and len(str(msg_obj["advisory_number"])) > 0):
        sql_values += "'" + str(msg_obj["advisory_number"]) + "', "
    else:
        sql_values += "'N/A', "

    # for now just stick "final_product" on end
    sql_fields += "final_product)"
    sql_values += "'product')"

    sql_stmt = sql_fields + sql_values
    sql_stmt += " RETURNING id"
       
    logger.debug("About to insert event group record: " + sql_stmt)
    cur = conn.cursor()
    cur.execute(sql_stmt)

    logger.debug(" Inserted event group record: " + sql_stmt)

    return cur.fetchone()[0]


# id | process_id | start_ts | end_ts | run_params | inst_state_type_id | site_id  | instance_name
def insert_instance(conn, state_id, site_id, msg_obj):
    logger.debug("insert_instance: state_id=" + str(state_id) + " site_id=" + str(site_id))

    start_ts = "2018-10-09 15:33:14"
    if (msg_obj.get("date-time") is not None and len(str(msg_obj["date-time"])) > 0):
        start_ts = str(msg_obj["date-time"])
    logger.debug("got start_ts")

    process_id = "0"
    if (msg_obj.get("uid") is not None and len(str(msg_obj["uid"])) > 0):
        process_id = str(msg_obj["uid"])
    logger.debug("got process_id")

    instance_name = "N/A"
    if (msg_obj.get("instance_name") is not None and len(str(msg_obj["instance_name"])) > 0):
        instance_name = str(msg_obj["instance_name"])

    logger.debug("got prelim values")
    # check to make sure this instance doesn't already exists before adding a new one
    #instance_id = get_instance_id(conn, start_ts, site_id, process_id, instance_name)
    #if (instance_id < 0): 

    sql_fields = 'INSERT INTO "ASGS_Mon_instance" ('
    sql_values = " VALUES ("

    # now construct SQL INSERT statement for the event table
    sql_fields += "site_id, "
    sql_values += str(site_id) + ", "

    sql_fields += "process_id, "
    sql_values += process_id + ", "

    sql_fields += "start_ts, "
    sql_values += "'" + start_ts + "', "

    sql_fields += "end_ts, "
    if (msg_obj.get("date-time") is not None and len(str(msg_obj["date-time"])) > 0):
        sql_values += "'" + str(msg_obj["date-time"]) + "', "
    else:
        sql_values += "'2018-10-09 15:33:14', "

    sql_fields += "run_params, "
    if (msg_obj.get("run_params") is not None and len(str(msg_obj["run_params"])) > 0):
        sql_values += "'" + str(msg_obj["run_params"]) + "', "
    else:
        sql_values += "'N/A', "

    sql_fields += "instance_name, "
    sql_values += "'" + instance_name + "', "

    sql_fields += "inst_state_type_id)"
    sql_values += str(state_id) + ")"

    sql_stmt = sql_fields + sql_values
    sql_stmt += " RETURNING id"

    logger.debug("About to insert instance record: " + sql_stmt)
    cur = conn.cursor()
    cur.execute(sql_stmt)

    logger.debug(" Inserted instance record: " + sql_stmt)
    return cur.fetchone()[0]


def db_connect():
    logger.debug("Connecting to DB: " + parser.get('postgres', 'database'))
    conn_str = "host=" + parser.get('postgres', 'host') + \
               " port=" + parser.get('postgres', 'port') + \
               " dbname=" + parser.get('postgres', 'database') + \
               " user=" + parser.get('postgres', 'username') + \
               " password=" + parser.get('postgres', 'password')
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
        logger.error("FAILURE - Cannot connect to DB: " + str(e))
        return

    try:
        # get the site id from the name in the message
        site_id, site_name = ASGSConstants_inst.getLuIdFromMsg(msg_obj, "physical_location", ASGSConstants.site_lu)
        
        if site_id < 0:
            return
        
        # get the 3vent type if from the event name in the message
        event_type_id, event_name = ASGSConstants_inst.getLuIdFromMsg(msg_obj, "event_type", ASGSConstants.event_type_lu)
        
        if event_type_id < 0:
            return
    
        # get the 3vent type if from the event name in the message
        state_id, state_name = ASGSConstants_inst.getLuIdFromMsg(msg_obj, "state", ASGSConstants.state_type_lu)
        
        if state_id < 0:
            return
    except:
        e = sys.exc_info()[0]
        logger.error("FAILURE - Cannot get asgs constants: " + str(e))
        return

    # check to see if there are any instances for this site_id yet
    # this might happen if we start up this process in the middle of a model run
    try:
        inst_id = get_existing_instance_id(conn, site_id, msg_obj)
    except:
        e = sys.exc_info()[0]
        logger.error("FAILURE - Cannot retrieve instance id: " + str(e))
        return
    
    # if this is a STRT event, create a new instance
    if ((inst_id < 0) or (event_name == "STRT" and state_name == "RUNN")):
        logger.debug("create_new_inst is True - creating new inst")
        
        try:
            inst_id = insert_instance(conn, state_id, site_id, msg_obj)
        except:
            e = sys.exc_info()[0]
            logger.error("FAILURE - Cannot insert instance: " + str(e))
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
        logger.error("FAILURE - Cannot retrieve existing event group: " + str(e))
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
            logger.error("FAILURE - Cannot insert event group: " + str(e))
            return
    else:
        # don't need a new event group
        logger.info("event_group_id=" + str(event_group_id))

        # update event group with this latest state
        try:
            update_event_group(conn, state_id, event_group_id, msg_obj)
        except:
            e = sys.exc_info()[0]
            logger.error("FAILURE - Cannot update event group: " + str(e))
            return


    # now insert message into the event table
    try:
        insert_event(conn, site_id, event_group_id, event_type_id, state_name, msg_obj)
    except:
        e = sys.exc_info()[0]
        logger.error("FAILURE - Cannot update event group: " + str(e))
        return
     
    # now commit and save
    try:
        conn.commit()
        conn.close()
    except:
        e = sys.exc_info()[0]
        logger.warn("FAILURE - Cannot commit and save to DB" + str(e))

channel.basic_consume(callback,
                      queue='asgs_queue',
                      no_ack=True)

#print(' [*] Waiting for messages. To exit press CTRL+C')
logger.info(' [*] Waiting for messages ...')
channel.start_consuming()
