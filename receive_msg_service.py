import re
import sys
import pika
import sqlite3
import json
import datetime
from random import randint
import logging

# set up logging
logfile = "rcv_msg_svc.log"
logging.basicConfig(filename=logfile, format='%(asctime)s %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p', level=logging.INFO)
logging.info("Started receive_msg_service")

# set up AMQP credentials and connect to asgs queue
credentials = pika.PlainCredentials('user', 'pswd')
parameters = pika.ConnectionParameters('localhost', 5672, '/', credentials, socket_timeout=2)
connection = pika.BlockingConnection(parameters)
channel = connection.channel()

channel.queue_declare(queue='asgs_queue')

def callback(ch, method, properties, body):
    #print(" [x] Received %r" % body)
    logging.info(" [x] Received %r" % body)

    try:
        msg_obj = json.loads(body)

        sql_fields = "INSERT INTO ASGS_Mon_message ("
        sql_values = " VALUES ("

    # ****************NEED TO CHANGE DB TO MAKE NULL VALUES ALLOWABLE FOR THESE ??
        sql_fields += "advisory_id, "
        if (msg_obj.get("advisory_id") is not None and len(msg_obj["advisory_id"]) > 0):
            sql_values += "'" + msg_obj["advisory_id"] + "', "
        else:
            sql_values += "'N/A', "

        sql_fields += "storm_name, "
        if (msg_obj.get("storm_name") is not None and len(msg_obj["storm_name"]) > 0):
            sql_values += "'" + msg_obj["storm_name"] + "', "
        else:
            sql_values += "'N/A', "

        sql_fields += "storm_number, "
        if (msg_obj.get("storm_number") is not None and len(msg_obj["storm_number"]) > 0):
            sql_values += "'" + msg_obj["storm_number"] + "', "        
        else:
            sql_values += "'N/A', "

        if (msg_obj.get("message") is not None and len(msg_obj["message"]) > 0):
            # get rid of any special chars that might mess up sqlite
            # backslashes, quote, abd double quote for now
            msg_line = re.sub('\\\|\'|\"', '', msg_obj["message"])

            sql_fields += "message, "
            sql_values += "'" + msg_line + "', "

        sql_fields += "process, "
        if (msg_obj.get("process") is not None and len(msg_obj["process"]) > 0):
            sql_values += "'" + msg_obj["process"] + "', "
        else:
            sql_values += "'N/A', "

        sql_fields += "state, "
        if (msg_obj.get("state") is not None and len(msg_obj["state"]) > 0):
            sql_values += "'" + msg_obj["state"] + "', "
        else:
            sql_values += "'N/A', "

        sql_fields += "pctcomplete, "
        pctcomplete = "0"
        if (msg_obj.get("pctcomplete") is not None and len(msg_obj["pctcomplete"]) > 0):
            pctcomplete = msg_obj["pctcomplete"]
        sql_values += pctcomplete + ", "

        # for now just stick "other" and message_type_id on end
        sql_fields += "other, message_type_id)"
        sql_values += "'', 0)"
   
        #open ASGS_Web django db - TODO - get this info from a config file
        conn = sqlite3.connect("/home/asgs/new_ASGS_Web/db.sqlite3")

        # first add to message table
        sql_stmt = sql_fields + sql_values
        conn.execute(sql_stmt)

        # then update event table 
        #conn.execute("UPDATE ASGS_Mon_event " +
                 #"SET event_ts='" + msg_obj["date-time"] + "', message_id=(SELECT MAX(id) " +
                 #"FROM ASGS_Mon_message), nodes_in_use=" + str(randint(0,1024)) + ", nodes_available=" + str(randint(0,1024)) + " WHERE site_id=0")


        # then update event table 
        # Try out using it as a progress bar
        if (msg_obj.get("date-time") is None and len(msg_obj["date-time"]) > 0):
            the_date = datetime.datetime.now().replace(microsecond=0).isoformat()
        else:
            the_date = msg_obj["date-time"]

        nodes_avail = 4000
        nodes_used = (nodes_avail * float(pctcomplete)) / 100

        conn.execute("UPDATE ASGS_Mon_event " +
                 "SET event_ts='" + the_date + "', message_id=(SELECT MAX(id) " +
                 "FROM ASGS_Mon_message), nodes_in_use=" + str(nodes_used) + ", nodes_available=" + str(4000) + " WHERE site_id=0")

        # now commit and save
        conn.commit()
        conn.close()
    except:
        e = sys.exc_info()[0]
        logging.warn("FAILURE - SQLite DB insert for message: " + json.dumps(msg_obj) + "ERROR: " + str(e))

channel.basic_consume(callback,
                      queue='asgs_queue',
                      no_ack=True)

#print(' [*] Waiting for messages. To exit press CTRL+C')
logging.info(' [*] Waiting for messages ...')
channel.start_consuming()
