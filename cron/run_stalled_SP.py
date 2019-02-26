import psycopg2
from psycopg2 import Error
import logging
from configparser import ConfigParser
from datetime import datetime, timedelta, tzinfo

# set up logging
logfile = "/srv/django/ASGS_Web/cron/run_stalled_SP.log"
logging.basicConfig(filename=logfile, format='%(asctime)s %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p', level=logging.INFO)
logging.info("started run_stalled_SP")

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


# run Phil's stored procedure
def find_and_update_stalled(cursor):
    try:
    
        query_str = 'select * from handle_stalled_event_groups()'
        cursor.execute(query_str)
        total_rows_affected = cursor.fetchone()

        logging.info("SP handle_stalled_event_groups: updated " + str(total_rows_affected[0]) + " row(s)")


    except (Exception, psycopg2.DatabaseError) as error :
        raise (error)
    

# main process
connection = None
try:

    connection = db_connect()
    cursor = connection.cursor()

    find_and_update_stalled(cursor)

except (Exception) as error :
    logging.error("Error while trying to find stalled asgs instances:", error)
    
finally:
    # closing database connection.
    if(connection):
        connection.commit()
        cursor.close()
        connection.close()
        logging.info("postgreSQL connection is closed : exitting run_stalled_SP")
