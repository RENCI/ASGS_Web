import re
import psycopg2
import datetime
import logging
import time


class ASGS_DB:
    def __init__(self, ASGSConstants_inst, parser, logger=None):
        # load the config
        self.logger = logger or logging.getLogger(__name__)

        self.ASGSConstants_inst = ASGSConstants_inst

        self.logger.info("Initializing ASGS_DB")

        self.conn_str = "host={0} port={1} dbname={2} user={3} password={4}".format(parser.get('postgres', 'host'), parser.get('postgres', 'port'), parser.get('postgres', 'database'), parser.get('postgres', 'username'), parser.get('postgres', 'password'))

        # init the DB connection objects
        self.conn = None
        self.cursor = None

        # get a db connection and cursor
        self.get_db_connection()

        self.logger.info("ASGS_DB initialized.")

    def get_db_connection(self):
        """
        Gets a connection to the DB. performs a check to continue trying until
        a connection is made

        :return:
        """
        # init the connection status indicator
        good_conn = False

        # until forever
        while not good_conn:
            # check the DB connection
            good_conn = self.check_db_connection()

            try:
                # do we have a good connection
                if not good_conn:
                    # connect to the DB
                    self.conn = psycopg2.connect(self.conn_str)

                    # insure records are updated immediately
                    self.conn.autocommit = True

                    # create the connection cursor
                    self.cursor = self.conn.cursor()

                    # check the DB connection
                    good_conn = self.check_db_connection()

                    # is the connection ok now?
                    if good_conn:
                        # ok to continue
                        return
                else:
                    # ok to continue
                    return
            except (Exception, psycopg2.DatabaseError):
                good_conn = False

            self.logger.error(f'DB Connection failed. Retrying...')
            time.sleep(5)

    def check_db_connection(self) -> bool:
        """
        checks to see if there is a good connection to the DB

        :return: boolean
        """
        # init the return value
        ret_val = None

        try:
            # is there a connection
            if not self.conn or not self.cursor:
                ret_val = False
            else:
                # get the DB version
                self.cursor.execute("SELECT version()")

                # get the value
                db_version = self.cursor.fetchone()

                # did we get a value
                if db_version:
                    # update the return flag
                    ret_val = True

        except (Exception, psycopg2.DatabaseError):
            # connect failed
            ret_val = False

        # return to the caller
        return ret_val

    def __del__(self):
        self.logger.info("ASGS_DB closing the DB connection")
        
        # close up the DB
        try:          
            self.cursor.close()
            self.conn.close()

            self.logger.info("ASGS_DB shutdown complete")
        except Exception as e:
            self.logger.error("FAILURE - Error closing DB connection. error {0}".format(str(e)))

    def exec_sql(self, sql_stmt, b_fetch=False):
        """
        executes a sql statement, returns the first row

        :param sql_stmt:
        :param b_fetch:
        :return:
        """
        try:        
            self.logger.debug("sql_stmt: {0}, bFetch {1}".format(sql_stmt, b_fetch))
            
            # execute the sql
            self.cursor.execute(sql_stmt)
            
            self.logger.debug("sql_stmt executed.")

            # get the returned value
            if b_fetch:
                self.logger.debug("sql_stmt fetching")
                ret_val = self.cursor.fetchone()
                self.logger.debug("sql_stmt fetched {0}".format(ret_val))

                if ret_val is None or ret_val[0] is None:
                    self.logger.debug("sql_stmt nothing fetched")
                    ret_val = -1
                else:
                    ret_val = ret_val[0]
                    
            else:
                ret_val = -1
            
            return ret_val
        except Exception as e:
            self.logger.error("FAILURE - DB issue: {0}".format(e))
            return -1

    ##########################################
    # just a check to see if there are any event groups defined for this site yet
    ##########################################
    def get_existing_event_group_id(self, instance_id, advisory_id):
        self.logger.debug("instance_id: {0}, advisory_id {1}".format(instance_id, advisory_id))
    
        # see if there are any event groups yet that have this instance_id
        # this could be caused by a new install that does not have any data in the DB yet
        sql_stmt = 'SELECT id FROM "ASGS_Mon_event_group" WHERE instance_id={0} AND advisory_id=\'{1}\' ORDER BY id DESC'.format(instance_id, advisory_id)
        
        group = self.exec_sql(sql_stmt, True)
        
        if group is not None:
            existing_group_id = group
        else:
            existing_group_id = -1
            
        self.logger.debug("existing_group_id: {0}".format(existing_group_id))
        
        return existing_group_id
        
    ##########################################
    # just a check to see if there are any instances defined for this site yet
    ##########################################
    def get_existing_instance_id(self, site_id, msg_obj):
        self.logger.debug("site_id: {0}".format(site_id))
    
        # get the instance name
        instance_name = msg_obj.get("instance_name", "N/A") if (msg_obj.get("instance_name", "N/A") != "") else "N/A"
    
        # get the process id
        process_id = int(msg_obj.get("uid", "0")) if (msg_obj.get("uid", "0") != "") else 0
    
        # see if there are any instances yet that have this site_id and instance_name
        # this could be caused by a new install that does not have any data in the DB yet
        sql_stmt = 'SELECT id FROM "ASGS_Mon_instance" WHERE site_id={0} AND process_id={1} AND instance_name=\'{2}\' AND inst_state_type_id!=9 ORDER BY id DESC'.format(site_id, process_id, instance_name)
                                                     
        # TODO +++++++++++++++FIX THIS++++++++++++++++++++Add query to get correct stat id for Defunct++++++++++++++++++++++++
        # TODO +++++++++++++++FIX THIS++++++++++++++++++++Add day to query too? (to account for rollover of process ids)++++++++++++++++++++++++
        
        inst = self.exec_sql(sql_stmt, True)

        if inst is not None:
            existing_instance_id = inst
        else:
            existing_instance_id = -1
        
        self.logger.debug("existing_instance_id {0}".format(existing_instance_id))
                
        return existing_instance_id

    def get_instance_id(self, start_ts, site_id, process_id, instance_name):
        """
        gets the instance id for a process
        :param start_ts:
        :param site_id:
        :param process_id:
        :param instance_name:
        :return:
        """
        self.logger.debug("start_ts: {0}, site_id: {1}, process_id: {2}, instance_name:{3}".format(start_ts, site_id, process_id, instance_name))
           
        sql_stmt = 'SELECT id FROM "ASGS_Mon_instance" WHERE CAST(start_ts as DATE)=\'{0}\' AND site_id={1} AND process_id={2} AND instance_name=\'{3}\''.format(start_ts[:10], site_id, process_id, instance_name)
                                                 
        inst = self.exec_sql(sql_stmt, True)
   
        if inst is not None:
            _id = inst
        else:
            _id = -1
        
        self.logger.debug("returning id: {0}".format(_id))
        
        return id   

    def update_event_group(self, state_id, event_group_id, msg_obj):
        """
        update the event group

        :param state_id:
        :param event_group_id:
        :param msg_obj:
        :return:
        """
        # get the storm name
        storm_name = msg_obj.get("storm", "N/A") if (msg_obj.get("storm", "N/A") != "") else "N/A"
    
        # get the advisory id
        advisory_id = msg_obj.get("advisory_number", "N/A") if (msg_obj.get("advisory_number", "N/A") != "") else "N/A"
    
        sql_stmt = 'UPDATE "ASGS_Mon_event_group" SET state_type_id ={0}, storm_name=\'{1}\', advisory_id=\'{2}\' WHERE id={3}'.format(state_id, storm_name, advisory_id, event_group_id)
        
        self.exec_sql(sql_stmt)

    def update_instance(self, state_id, site_id, instance_id, msg_obj):
        """
        update instance with latest state_type_id

        :param state_id:
        :param site_id:
        :param instance_id:
        :param msg_obj:
        :return:
        """
        # get a default time stamp, use it if necessary
        now = datetime.datetime.now()
        ts = now.strftime("%Y-%m-%d %H:%M")
        end_ts = msg_obj.get("date-time", ts) if (msg_obj.get("date-time", ts) != "") else ts
    
        # get the run params
        run_params = msg_obj.get("run_params", "N/A") if (msg_obj.get("run_params", "N/A") != "") else "N/A"
    
        sql_stmt = 'UPDATE "ASGS_Mon_instance" SET inst_state_type_id = {0}, end_ts = \'{1}\', run_params = \'{2}\' WHERE site_id = {3} AND id={4}'.format(state_id, end_ts, run_params, site_id, instance_id)
                                                   
        self.exec_sql(sql_stmt)
   
    ##########################################
    # saves the raw message
    ##########################################
    def save_raw_msg(self, msg):
        self.logger.debug("msg: {0}".format(msg))
    
        sql_stmt = 'INSERT INTO "ASGS_Mon_json" (data) VALUES (\'{0}\''.format(msg)
        
        self.exec_sql(sql_stmt)
        
    ##########################################
    # insert an event
    ##########################################
    def insert_event(self, site_id, event_group_id, event_type_id, msg_obj):
        # get a default time stamp, use it if necessary
        now = datetime.datetime.now()
        ts = now.strftime("%Y-%m-%d %H:%M")
        event_ts = msg_obj.get("date-time", ts) if (msg_obj.get("date-time", ts) != "") else ts
        
        # get the event advisory data
        advisory_id = msg_obj.get("advisory_number", "N/A") if (msg_obj.get("advisory_number", "N/A") != "") else "N/A"
    
        # get the process data
        process = msg_obj.get("process", "N/A") if (msg_obj.get("process", "N/A") != "") else "N/A"
    
        # get the percent complete from a LU lookup
        pct_complete = self.ASGSConstants_inst.getLuId(str(event_type_id), "pct_complete")

        # get the sub percent complete from the message object
        sub_pct_complete = msg_obj.get("subpctcomplete", pct_complete)

        # if there was a message included parse and add it
        if msg_obj.get("message") is not None and len(msg_obj["message"]) > 0:
            # get rid of any special chars that might mess up postgres
            # backslashes, quote, abd double quote for now
            msg_line = re.sub('\\\|\'|\"', '', msg_obj["message"])
    
            raw_data_col = ", raw_data"
            msg_line = ", '{0}'".format(msg_line)
        else:
            raw_data_col = ''
            msg_line = ''
        
        # create the fields
        sql_stmt = 'INSERT INTO "ASGS_Mon_event" (site_id, event_group_id, event_type_id, event_ts, advisory_id, pct_complete, sub_pct_complete, process{0}) VALUES ({1}, {2}, {3}, \'{4}\', \'{5}\', {6}, {7}, \'{8}\'{9})'.format(raw_data_col, site_id, event_group_id, event_type_id, event_ts, advisory_id, pct_complete, sub_pct_complete, process, msg_line)
    
        self.exec_sql(sql_stmt)
        
    ##########################################
    # inserts an event group
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

        group = self.exec_sql(sql_stmt, True)

        self.logger.debug("group {0}".format(group))

        return group
    
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
        # instance_id = get_instance_id(start_ts, site_id, process_id, instance_name)
        # if (instance_id < 0):
    
        sql_stmt = 'INSERT INTO "ASGS_Mon_instance" (site_id, process_id, start_ts, end_ts, run_params, instance_name, inst_state_type_id) VALUES ({0}, {1}, \'{2}\', \'{3}\', \'{4}\', \'{5}\', {6}) RETURNING id'.format(site_id, process_id, start_ts, end_ts, run_params, instance_name, state_id)
    
        inst = self.exec_sql(sql_stmt, True)

        self.logger.debug("inst {0}".format(inst))

        return inst
        
    def insert_config_items(self, instance_id, param_list):
        """
        Inserts the configuration parameters into the database
        """
        # remove all records that may already exist
        self.exec_sql('DELETE FROM public."ASGS_Mon_config_item" WHERE instance_id = {0}'.format(instance_id))
        
        # create the baseline sql statement
        sql_stmt = 'INSERT INTO public."ASGS_Mon_config_item" (instance_id, key, value) VALUES '

        for item in param_list:
            sql_stmt += "({0}, '{1}', '{2}'),".format(instance_id, item[0], item[1])
            
        # finally add a record for supervisor job status
        sql_stmt += "({0}, '{1}', '{2}'),".format(instance_id, "supervisor_job_status", "new")
            
        # remove the trailing comma
        sql_stmt = sql_stmt[:-1]
        
        self.logger.debug("sql_stmt {0}".format(sql_stmt))
        
        # execute the sql
        self.exec_sql(sql_stmt)
        
        
