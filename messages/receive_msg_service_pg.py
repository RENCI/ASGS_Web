import re
import sys
import pika
import psycopg2
import json
import datetime
from random import randint
import logging
from configparser import ConfigParser

# set up logging
logfile = "rcv_msg_svc.log"
logging.basicConfig(filename=logfile, format='%(asctime)s %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p', level=logging.INFO)
logging.info("Started receive_msg_service")

# retrieve configuration settings
parser = ConfigParser()
parser.read('msg_settings.ini')

# set up AMQP credentials and connect to asgs queue
credentials = pikadatabase.PlainCredentials(parser.get('pika', 'username'),
                                            parser.get('pika', 'password'))
parameters = pika.ConnectionParameters(parser.get('pika', 'host'),
                                       parser.get('pika', 'port'),
                                       '/',
                                       credentials,
                                       socket_timeout=2)
connection = pika.BlockingConnection(parameters)
channel = connection.channel()

channel.queue_declare(queue='asgs_queue')


# get the correct percent complete for an event type
def get_pctcomplete(conn, event_type_id):

        query = "SELECT pct_complete FROM ASGS_Mon_event_type_lu WHERE id=" + str(event_type_id)
        cur = conn.cursor()
        cur.execute(query)
        event_lu = cur.fetchone()
        pct_complete  = event_lu[0]
       
        return pct_complete
    

def insert_event(conn, site_id, event_group_id, event_type_id, state_type, msg_obj):

        sql_fields = "INSERT INTO ASGS_Mon_event ("
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

        if ((state_type =="CMPL") or (int(pct_complete) < 20)):
            sql_values += str(pct_complete) + ", "
        else: #this should still be the previous pct amount - 20 less - until completion of the event
            sql_values += str(int(pct_complete)-20) + ", "
                
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
            # get rid of any special chars that might mess up sqlite
            # backslashes, quote, abd double quote for now
            msg_line = re.sub('\\\|\'|\"', '', msg_obj["message"])

            sql_fields += "raw_data, "
            sql_values += "'" + msg_line + "', "


        # for now just stick "host_start_file" 
        sql_fields += "host_start_file)"
        sql_values += "'start_file')"
   

        # add to message table
        sql_stmt = sql_fields + sql_values
        conn.execute(sql_stmt)
   
        logging.info(" Inserted event record: " + sql_stmt)


def insert_event_group(conn, site_id, state_id, msg_obj):

        sql_fields = "INSERT INTO ASGS_Mon_event_group ("
        sql_values = " VALUES ("

        # now construct SQL INSERT statement for the event table
        sql_fields += "site_id, "
        sql_values += str(site_id) + ", "

        sql_fields += "state_type_id, "
        sql_values += str(state_id) + ", "

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
        cur = conn.cursor()
        cur.execute(sql_stmt)

        logging.info(" Inserted event group record: " + sql_stmt)

        return cur.lastrowid

def db_connect():
        conn_str = "host=" + parser.get('postgres', 'host') +
                   " port=" + parser.get('postgres', 'port') +
                   " dbname=" + parser.get('postgres', 'database') +
                   " user=" + parser.get('postgres', 'username') +
                   " password=" + parser.get('postgres', 'password')
        conn = psycopg2.connect(conn_str)

        return conn


def callback(ch, method, properties, body):
    #print(" [x] Received %r" % body)
    logging.info(" [x] Received %r" % body)

    try:
        msg_obj = json.loads(body)

        #open ASGS_Web django db
        conn = db_connect()

        # get site id from site name
        site_name = ""
        if (msg_obj.get("physical_location") is not None and len(msg_obj["physical_location"]) > 0):
            site_name = msg_obj["physical_location"]
        else:
            logging.error("NO SITE NAME PROVIDED - must drop message!")
            return
        query = "SELECT id FROM ASGS_Mon_site_lu where name='" + site_name + "'"
        cur = conn.cursor()
        cur.execute(query)
        site_lu = cur.fetchone()
        site_id = site_lu[0]

        # get event_type_id from event_name
        event_name = ""
        if (msg_obj.get("event_type") is not None and len(msg_obj["event_type"]) > 0):
            event_name = msg_obj["event_type"]
        else:
            logging.error("NO EVENT TYPE PROVIDED - must drop message!")
            return
        query = "SELECT id FROM ASGS_Mon_event_type_lu WHERE name='" + event_name + "'"
        cur = conn.cursor()
        cur.execute(query)
        event_lu = cur.fetchone()
        event_type_id = event_lu[0]

        state_name = ""
        if (msg_obj.get("state") is not None and len(msg_obj["state"]) > 0):
            state_name = msg_obj["state"]
        else:
            logging.error("NO STATE TYPE PROVIDED - must drop message!")
            return
        
        event_group_id = -1
        state_id = -1
        # if this is the start of a group of Events, create a new event_group record
        # qualifying group initiation: event type = RSTR
        # STRT & HIND do not belong to any event group??
        # For now it is required that every event belong to an event group, so I will add those as well.

        # ***********THIS SHOULD CHANGE LATER***************
        # get run state id from state name
        query = "SELECT id FROM ASGS_Mon_state_type_lu WHERE name='" + state_name + "'"
        cur = conn.cursor()
        cur.execute(query)
        state = cur.fetchone()
        state_id = state[0]

        if((event_name == "STRT") and (state_name == "INIT")):
            # get run state id from state name
            #query = "SELECT id FROM ASGS_Mon_state_type_lu WHERE name='" + state_name + "'"
            #cur = conn.cursor()
            #cur.execute(query)
            #state = cur.fetchone()
            #state_id = state[0]
            event_group_id = insert_event_group(conn, site_id, state_id, msg_obj)
        else:
            # don't need a new event group
            # get last message from this site in order to retrieve current event group id
            query = "SELECT max(id) AS id, event_group_id FROM ASGS_Mon_event e WHERE e.site_id=" + str(site_id)
            cur = conn.cursor()
            cur.execute(query)
            event = cur.fetchone()
            event_group_id = event[1] 
            # update event group with this latest state
            sql_stmt = "UPDATE ASGS_Mon_event_group SET state_type_id = " + str(state_id) + " WHERE id = " + str(event_group_id)
            conn.execute(sql_stmt)

        # update site with latest state_type_id
        sql_stmt = "UPDATE ASGS_Mon_site_lu SET state_type_id = " + str(state_id) + " WHERE id = " + str(site_id)
        conn.execute(sql_stmt)


        # now insert message into the event table
        insert_event(conn, site_id, event_group_id, event_type_id, state_name, msg_obj)
     
        # now commit and save
        conn.commit()
        cur.close()
        conn.close()
    except:
        e = sys.exc_info()[0]
        logging.warn("FAILURE - SQLite DB insert for message: " + json.dumps(msg_obj) + " ERROR: " + str(e))

channel.basic_consume(callback,
                      queue='asgs_queue',
                      no_ack=True)

#print(' [*] Waiting for messages. To exit press CTRL+C')
logging.info(' [*] Waiting for messages ...')
channel.start_consuming()
