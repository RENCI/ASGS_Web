import sys
import re
import psycopg2
import datetime

class ASGS_DB:
    def __init__(self, logger, ASGSConstants_inst, parser):
        self.logger = logger
        self.ASGSConstants_inst = ASGSConstants_inst
        self.parser = parser

        # open a persistent DB connection
        try:    
            #open ASGS_Web django db
            self.conn = self.db_connect()
        except:
            e = sys.exc_info()[0]
            logger.error("FAILURE - Cannot connect to DB. error: {0}".format(str(e)))
            raise Exception('Error getting connection to the database')
        
        logger.debug("ASGS_DB initialized")

    def __del__(self):
        # now commit and save
        try:
            self.conn.close()
        except:
            e = sys.exc_info()[0]
            self.logger.warn("FAILURE - Error closing DB connection. error {0}".format(str(e)))

    ##########################################
    # just a check to see if there are any event groups defined for this site yet
    ##########################################
    def get_existing_event_group_id(self, instance_id, advisory_id):
        self.logger.debug("instance_id: {0}, advisory_id {1}".format(instance_id, advisory_id))
    
        # see if there are any event groups yet that have this instance_id
        # this could be caused by a new install that does not have any data in the DB yet
        query = 'SELECT id FROM "ASGS_Mon_event_group" WHERE instance_id={0} AND advisory_id=\'{1}\' ORDER BY id DESC'.format(instance_id, advisory_id)
        
        self.logger.debug("query: {0}".format(query))
        
        cur = self.conn.cursor()
        cur.execute(query)
        
        group = cur.fetchone()
        
        if (group is not None):
            existing_group_id = group[0]
        else:
            existing_group_id = -1
            
        self.logger.debug("existing_group_id: {0}".format(existing_group_id))
        
        return existing_group_id
    
    
    ##########################################
    # just a check to see if there are any instances defined for this site yet
    ##########################################
    def get_existing_instance_id(self, site_id , msg_obj):
        self.logger.debug("site_id: {0}".format(site_id))
    
        # get the instance name
        instance_name = msg_obj.get("instance_name", "N/A") if (msg_obj.get("instance_name", "N/A") != "") else "N/A"
    
        # get the process id
        process_id = int(msg_obj.get("uid", "0")) if (msg_obj.get("uid", "0") != "") else 0
    
        # see if there are any instances yet that have this site_id and instance_name
        # this could be caused by a new install that does not have any data in the DB yet
        query = 'SELECT id FROM "ASGS_Mon_instance" WHERE site_id={0} AND process_id={1} AND instance_name=\'{2}\' AND inst_state_type_id!=9 ORDER BY id DESC'.format(site_id, process_id, instance_name)
                                                 
    # TODO +++++++++++++++FIX THIS++++++++++++++++++++Add query to get correct stat id for Defunct++++++++++++++++++++++++
    # TODO +++++++++++++++FIX THIS++++++++++++++++++++Add day to query too? (to account for rollover of process ids)++++++++++++++++++++++++
    
        self.logger.debug("query: {0}".format(query))
        
        cur = self.conn.cursor()
        cur.execute(query)
        inst = cur.fetchone()
        
        if (inst is not None):
            existing_instance_id = inst[0]
        else:
            existing_instance_id = -1
    
        self.logger.debug("existing_instance_id {0}".format(existing_instance_id))
        
        return existing_instance_id
    
    
    ##########################################
    # gets the instance id for a process
    ##########################################
    def get_instance_id(self, start_ts, site_id, process_id, instance_name):
        self.logger.debug("start_ts: {0}, site_id: {1}, process_id: {2}, instance_name:{3}".format(start_ts, site_id, process_id, instance_name))
        
    
        query = 'SELECT id FROM "ASGS_Mon_instance" WHERE CAST(start_ts as DATE)=\'{0}\' AND site_id={1} AND process_id={2} AND instance_name=\'{3}\''.format(start_ts[:10], site_id, process_id, instance_name)
                                                 
        self.logger.debug("query: " + query)
        cur = self.conn.cursor()
        cur.execute(query)
        inst = cur.fetchone()
    
        if (inst is not None):
            _id = inst[0]
        else:
            _id = -1
        
        self.logger.debug("returning id: {0}".format(_id))
        
        return id   
    
    
    ##########################################
    ##########################################
    def update_event_group(self, state_id, event_group_id, msg_obj):
        # get the storm name
        storm_name = msg_obj.get("storm", "N/A") if (msg_obj.get("storm", "N/A") != "") else "N/A"
    
        # get the advisory id
        advisory_id = msg_obj.get("advisory_number", "N/A") if (msg_obj.get("advisory_number", "N/A") != "") else "N/A"
    
        sql_stmt = 'UPDATE "ASGS_Mon_event_group" SET state_type_id ={0}, storm_name=\'{1}\', advisory_id=\'{2}\' WHERE id={3}'.format(state_id, storm_name, advisory_id, event_group_id)
        
        self.logger.debug("sql_stmt: {0}".format(sql_stmt))
                     
        cur = self.conn.cursor()
        cur.execute(sql_stmt)
    
    
    ##########################################
    # update instance with latest state_type_id
    ##########################################
    def update_instance(self, state_id, site_id, instance_id, msg_obj):
        # get a default time stamp, use it if necessary
        now = datetime.datetime.now()
        ts = now.strftime("%Y-%m-%d %H:%M")
        end_ts = msg_obj.get("date-time", ts) if (msg_obj.get("date-time", ts) != "") else ts
    
        # get the run params
        run_params = msg_obj.get("run_params", "N/A") if (msg_obj.get("run_params", "N/A") != "") else "N/A"
    
        sql_stmt = 'UPDATE "ASGS_Mon_instance" SET inst_state_type_id = {0}, end_ts = \'{1}\', run_params = \'{2}\' WHERE site_id = {3} AND id={4}'.format(state_id, end_ts, run_params, site_id, instance_id)
                                                   
        self.logger.debug("sql: {0}".format(sql_stmt))
        
        cur = self.conn.cursor()
        cur.execute(sql_stmt)
    
    ##########################################
    ##########################################
    def save_raw_msg(self, msg):
        self.logger.debug("msg: {0}".format(msg))
    
        sql_stmt = 'INSERT INTO "ASGS_Mon_json" (data) VALUES (\'{0}\''.format(msg)
        
        self.logger.debug("sql: {0}".format(sql_stmt))
        
        cur = self.conn.cursor()
        cur.execute(sql_stmt)
        
    ##########################################
    ##########################################
    def insert_event(self, site_id, event_group_id, event_type_id, pct_complete, msg_obj):
        # get a default time stamp, use it if necessary
        now = datetime.datetime.now()
        ts = now.strftime("%Y-%m-%d %H:%M")
        event_ts = msg_obj.get("date-time", ts) if (msg_obj.get("date-time", ts) != "") else ts
        
        # get the event advisory data
        advisory_id = msg_obj.get("advisory_number", "N/A") if (msg_obj.get("advisory_number", "N/A") != "") else "N/A"
    
        # get the process data
        process = msg_obj.get("process", "N/A") if (msg_obj.get("process", "N/A") != "") else "N/A"
    
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
    
        self.logger.debug("About to insert event record: {0}".format(sql_stmt))
        
        cur = self.conn.cursor()
        cur.execute(sql_stmt)
       
        self.logger.debug("Inserted event record: {0}".format(sql_stmt))
    
    ##########################################
    ##########################################
    def insert_event_group(self, state_id, instance_id, msg_obj):
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
         
        sql_stmt = 'INSERT INTO "ASGS_Mon_event_group" (state_type_id, instance_id, event_group_ts, storm_name, storm_number, advisory_id, final_product) VALUES ({0}, {1}, \'{2}\', \'{3}\', \'{4}\', \'{5}\', \'product\') RETURNING id'.format(state_id, instance_id, event_group_ts, storm_name, storm_number, advisory_id)
        
        self.logger.debug("About to insert event group record: {0}".format(sql_stmt))
        
        cur = self.conn.cursor()
        cur.execute(sql_stmt)
    
        self.logger.debug(" Inserted event group record: {0}".format(sql_stmt))
    
        return cur.fetchone()[0]
    
    
    ##########################################
    # id | process_id | start_ts | end_ts | run_params | inst_state_type_id | site_id  | instance_name
    ##########################################
    def insert_instance(self, state_id, site_id, msg_obj):
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
        #instance_id = get_instance_id(start_ts, site_id, process_id, instance_name)
        #if (instance_id < 0): 
    
        sql_stmt = 'INSERT INTO "ASGS_Mon_instance" (site_id, process_id, start_ts, end_ts, run_params, instance_name, inst_state_type_id) VALUES ({0}, {1}, \'{2}\', \'{3}\', \'{4}\', \'{5}\', {6}) RETURNING id'.format(site_id, process_id, start_ts, end_ts, run_params, instance_name, state_id)
    
        self.logger.debug("About to insert instance record: " + sql_stmt)
        cur = self.conn.cursor()
        cur.execute(sql_stmt)
    
        self.logger.debug(" Inserted instance record: " + sql_stmt)
        return cur.fetchone()[0]
    
    ##########################################
    # gets a connection to the DB
    ##########################################
    def db_connect(self):
        self.logger.debug("Connecting to DB: {0}".format(self.parser.get('postgres', 'database')))
        
        conn_str = "host={0} port={1} dbname={2} user={3} password={4}".format(self.parser.get('postgres', 'host'), self.parser.get('postgres', 'port'), self.parser.get('postgres', 'database'), self.parser.get('postgres', 'username'), self.parser.get('postgres', 'password'))
                   
        self.conn = psycopg2.connect(conn_str)
        
    ##########################################
    # commits all outstanding DB queries
    ##########################################
    def db_commit(self):
        self.conn.commit()

    