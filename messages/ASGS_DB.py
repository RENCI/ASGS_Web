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
            
#            if self.conn.open:
#                self.conn.close()

            self.logger.debug("DB shutdown complete")
        except:
            e = sys.exc_info()[0]
            self.logger.warn("FAILURE - Error closing DB connection. error {0}".format(str(e)))

    
    ###########################################
    # executes a sql statement, returns the first row
    ###########################################
    
    def exec_sql(self, sql_stmt):
        try:        
            self.logger.debug("sql_stmt: {0}".format(sql_stmt))
            
            #self.cursor.execute(sql_stmt)
            
            #retVal = self.cursor.fetchone()
            
            self.logger.debug("sql_stmt executed")

            #self.cursor.commit()
            
            return 1#retVal[0]
        except:
            e = sys.exc_info()[0]
            self.logger.error("FAILURE - DB issue: " + str(e))
            return

    ##########################################
    # just a check to see if there are any event groups defined for this site yet
    ##########################################
    def get_existing_event_group_id(self, instance_id, advisory_id):
        self.logger.debug("instance_id: {0}, advisory_id {1}".format(instance_id, advisory_id))
    
        # see if there are any event groups yet that have this instance_id
        # this could be caused by a new install that does not have any data in the DB yet
        sql_stmt = 'SELECT id FROM "ASGS_Mon_event_group" WHERE instance_id={0} AND advisory_id=\'{1}\' ORDER BY id DESC'.format(instance_id, advisory_id)
        
        group = self.exec_sql(sql_stmt)
        
        if (group is not None):
            existing_group_id = group
        else:
            existing_group_id = -1
            
        self.logger.debug("existing_group_id: {0}".format(existing_group_id))
        
        return existing_group_id
    
   