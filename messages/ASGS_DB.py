import sys
import re
import psycopg2
import datetime

class ASGS_DB:
    def __init__(self, logger, ASGSConstants_inst, parser):
        self.logger = logger#.getLogger('ASGS_DB')
        
        try:
            self.ASGSConstants_inst = ASGSConstants_inst
            
            self.logger.debug("Connecting to DB: {0}".format(parser.get('postgres', 'database')))
            
            conn_str = "host={0} port={1} dbname={2} user={3} password={4}".format(parser.get('postgres', 'host'), parser.get('postgres', 'port'), parser.get('postgres', 'database'), parser.get('postgres', 'username'), parser.get('postgres', 'password'))
    
            self.conn = psycopg2.connect(conn_str)
            
            self.logger.debug("Got a connection to the DB")
    
            self.cursor = self.conn.cursor
                    
            self.logger.debug("ASGS_DB initialized")
        except:
            e = sys.exc_info()[0]
            self.logger.warn("FAILURE initializing. error {0}".format(str(e)))

    def __del__(self):
        # now commit and save
        try:
            self.logger.debug("Closing the connection")
            
            if self.conn.open:
                self.conn.close()

            self.logger.debug("DB shutdown complete")
        except:
            e = sys.exc_info()[0]
            self.logger.warn("FAILURE - Error closing DB connection. error {0}".format(str(e)))
   