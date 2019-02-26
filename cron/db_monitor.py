import psycopg2
from psycopg2 import Error
import logging
from configparser import ConfigParser
from datetime import datetime, timedelta, tzinfo

# set up logging
logfile = "/srv/django/ASGS_Web/cron/db_monitor.log"
logging.basicConfig(filename=logfile, format='%(asctime)s %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p', level=logging.INFO)
logging.info("started db-monitor")

# retrieve configuration settings
parser = ConfigParser()
parser.read('/srv/django/ASGS_Web/cron/db_settings.ini')

def db_connect():
    logging.debug("Connecting to DB: " + parser.get('postgres', 'database'))
    conn_str = "host=" + parser.get('postgres', 'host') + \
               " port=" + parser.get('postgres', 'port') + \
               " dbname=" + parser.get('postgres', 'database') + \
               " user=" + parser.get('postgres', 'username') + \
               " password=" + parser.get('postgres', 'password')
    conn = psycopg2.connect(conn_str)

    return conn


def get_state_id_from_name(cursor, name):
    state_type_id = -1

    query_str = 'select id from "ASGS_Mon_instance_state_type_lu"' + " where name='" + name + "'"
    cursor.execute(query_str)
    state_type = cursor.fetchone()
    state_type_id = state_type[0]

    logging.debug("get_state_id_from_name: name=" + name + "  id=" + str(state_type_id))
    return state_type_id


def find_stalled(cursor):
    try:
    
        # get the list of instances that may need to marked as stalled
        # exclude certain states: FAIL, EXIT, and already STALLED

        # first get ids for these states to exclude
        stalled_state_id = get_state_id_from_name(cursor, 'STALLED')
        exit_state_id = get_state_id_from_name(cursor, 'EXIT')
        fail_state_id = get_state_id_from_name(cursor, 'FAIL')
        query_str = 'select id from "ASGS_Mon_instance" WHERE ' + \
                               'inst_state_type_id!=' + str(stalled_state_id) + ' AND ' + \
                               'inst_state_type_id!=' + str(exit_state_id) + ' AND ' + \
                               'inst_state_type_id!=' + str(fail_state_id)
        cursor.execute(query_str)
        result = cursor.fetchall()

        # now for each instance, get the latest active event group
        for id in result:
            query_str = 'select id from "ASGS_Mon_event_group" where instance_id=' + str(id[0]) + ' order by id DESC limit 1'
            cursor.execute(query_str)
            event_grp_id = cursor.fetchone()

            # for this event group, find the latest event received
            query_str = 'SELECT max(event_ts) as max_ts FROM "ASGS_Mon_event" WHERE event_group_id=' + str(event_grp_id[0])
            cursor.execute(query_str)
            event_ts = cursor.fetchone()

            # date returned from DB looks like this: 2019-02-05 20:13:21+00:00
            # need to convert the DB date to timezone naive in order to compare to current utc time
            event_ts_naive = event_ts[0].replace(tzinfo=None)

            # compare current datetime with the last time this instance was updated
            # if it is more than 3 hours, mark it as 'stalled'
            current_time_utc = datetime.utcnow()
            expiration = timedelta(hours=3)

            if ((current_time_utc - event_ts_naive) > expiration): 
                # update the instance and event group state types to 'STALLED'
                logging.info("find_stalled: updating state to stalled for instance:" + str(id[0]) + ", event grp:" + str(event_grp_id[0]))

                # 02/26/19 Discussion with Phil - do not mark Instances as stalled - only groups
                # also change expiration time from 6 to 3 hours
                # update_str = 'update "ASGS_Mon_instance" set inst_state_type_id=' + str(stalled_state_id) + " WHERE id=" + str(id[0])
                # cursor.execute(update_str);
                update_str = 'update "ASGS_Mon_event_group" set state_type_id=' + str(stalled_state_id) + " WHERE id=" + str(event_grp_id[0])
                cursor.execute(update_str);

    except (Exception, psycopg2.DatabaseError) as error :
        raise (error)
    

# main process
connection = None
try:

    connection = db_connect()
    cursor = connection.cursor()

    find_stalled(cursor)

except (Exception) as error :
    logging.error("Error while trying to find stalled asgs instances:", error)
    
finally:
    # closing database connection.
    if(connection):
        connection.commit()
        cursor.close()
        connection.close()
        logging.info("postgreSQL connection is closed : exitting db-monitor.py")
