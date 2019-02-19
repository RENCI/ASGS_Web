import sys
import re
import psycopg2
import datetime

class ASGS_DB:
    def __init__(self, logger, ASGSConstants_inst, parser):
        self.logger = logger
        
        self.ASGSConstants_inst = ASGSConstants_inst
        
        self.parser = parser
        
        #self.conn = self.db_connect()
        
        #self.cursor = self.conn.cursor
        
        logger.debug("ASGS_DB initialized")

    def __del__(self):
        # now commit and save
        try:
            self.logger.debug("Closing the connection")
            #self.conn.close()

            self.logger.debug("DB shutdown complete")
        except:
            e = sys.exc_info()[0]
            self.logger.warn("FAILURE - Error closing DB connection. error {0}".format(str(e)))
   