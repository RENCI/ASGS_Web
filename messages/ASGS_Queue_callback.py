import sys
import json
import logging

from SlackMsgs import SlackMsgs
from ASGSConstants import ASGSConstants
from ASGS_DB import ASGS_DB

class ASGS_Queue_callback:
    def __init__(self, parser, logger=None):
        # load the config
        self.logger = logger or logging.getLogger(__name__)

        self.logger.info("Initializing ASGS_Queue_callback")
        
        # save the reference to the configuration params
        self.parser = parser
        
        # define and init the object used to handle ASGS constant conversions
        self.ASGSConstants_inst = ASGSConstants()
        
        # define and init the object that will handle ASGS DB operations
        self.ASGS_DB_inst = ASGS_DB(self.ASGSConstants_inst, self.parser)

        # create object to send errors to apsviz-issues slack channel
        self.slack_msg = SlackMsgs()

        self.logger.info("ASGS_Queue_callback initialization complete")
        
    ##########################################
    # main worker that operates on the incoming message from the queue
    ##########################################
    def callback(self, ch, method, properties, body):
        #print(" [x] Received %r" % body)
        self.logger.info("Received %r" % body)
        
        # load the message
        msg_obj = json.loads(body)
    
        # get the site id from the name in the message
        site_id = self.ASGSConstants_inst.getLuIdFromMsg(msg_obj, "physical_location", "site")
        
        # get the 3vent type if from the event name in the message
        event_type_id, event_name = self.ASGSConstants_inst.getLuIdFromMsg(msg_obj, "event_type", "event_type")
    
        # get the 3vent type if from the event name in the message
        state_id, state_name = self.ASGSConstants_inst.getLuIdFromMsg(msg_obj, "state", "state_type")
        
            # get the event advisory data
        advisory_id = msg_obj.get("advisory_number", "N/A") if (msg_obj.get("advisory_number", "N/A") != "") else "N/A"
    
        # did we get everything needed
        if site_id[0] < 0 or event_type_id < 0 or state_id < 0 or advisory_id =='N/A':
            self.logger.error("FAILURE - Cannot retrieve advisory number, site, event type or state type ids.")
            return
    
        # check to see if there are any instances for this site_id yet
        # this might happen if we start up this process in the middle of a model run
        try:
            instance_id = self.ASGS_DB_inst.get_existing_instance_id(site_id[0], msg_obj)
        except:
            e = sys.exc_info()[0]
            self.logger.error("FAILURE - Cannot retrieve instance id. error {0}".format(str(e)))
            return
        
        # if this is a STRT event, create a new instance
        if ((instance_id < 0) or (event_name == "STRT" and state_name == "RUNN")):
            self.logger.debug("create_new_inst is True - creating new inst")
            
            try:
                instance_id = self.ASGS_DB_inst.insert_instance(state_id, site_id[0], msg_obj)
            except:
                e = sys.exc_info()[0]
                self.logger.error("FAILURE - Cannot insert instance. error {0}".format(str(e)))
                return
        else: # just update instance
            self.logger.debug("create_new_inst is False - updating inst")
            
            try:
                self.ASGS_DB_inst.update_instance(state_id, site_id[0], instance_id, msg_obj)
            except:
                e = sys.exc_info()[0]
                self.logger.error("FAILURE - Cannot update instance: " + str(e))
                return
    
    
        # check to see if there are any event groups for this site_id and inst yet
        # this might happen if we start up this process in the middle of a model run
        try:
            event_group_id = self.ASGS_DB_inst.get_existing_event_group_id(instance_id, advisory_id)
        except:
            e = sys.exc_info()[0]
            self.logger.error("FAILURE - Cannot retrieve existing event group. error {0}".format(str(e)))
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
                event_group_id = self.ASGS_DB_inst.insert_event_group(state_id, instance_id, msg_obj)
            except:
                e = sys.exc_info()[0]
                self.logger.error("FAILURE - Cannot insert event group. error {0}".format(str(e)))
                return
        else:
            # don't need a new event group
            self.logger.debug("Reusing event_group_id: {0}".format(event_group_id))
    
            # update event group with this latest state
            # added 3/6/19 - will set status to EXIT if this is a FEND or REND event_type
            # will hardcode this state id for now, until I get my messaging refactor delivered
            if (event_name == 'FEND') or (event_name == 'REND'):
                state_id = 9
                self.logger.debug("Got FEND event type: setting state_id to " + str(state_id))
            try:
                self.ASGS_DB_inst.update_event_group(state_id, event_group_id, msg_obj)
            except:
                e = sys.exc_info()[0]
                self.logger.error("FAILURE - Cannot update event group. error {0}".format(str(e)))
                return
    
    
        # now insert message into the event table
        try:
            self.ASGS_DB_inst.insert_event(site_id[0], event_group_id, event_type_id, msg_obj)
        except:
            e = sys.exc_info()[0]
            self.logger.error("FAILURE - Cannot update event group. error {0}".format(str(e)))
            return

    def cfg_callback(self, ch, method, properties, body):
        """
        The callback function for things that land on the configuration queue
        
        """
        ret_msg = None

        #print(" [x] Received %r" % body)
        self.logger.info("Received cfg msg %r" % body)
        context = "Config Message Queue callback function"
        
        # load the message
        try:
            msg_obj = json.loads(body)
            self.logger.info("msg_obj: " + str(msg_obj))
        except:
            e = sys.exc_info()[0]
            err = "ERROR loading json from the config message queue. Error:{0]".format(str(e))
            self.logger.error(err)
            # send a message to slack
            self.slack_msg.send_slack_msg(context, err)
            return
        
        # get the site id from the name in the message
        site_id = self.ASGSConstants_inst.getLuIdFromMsg(msg_obj, "physical_location", "site")

        if(site_id is None or site_id[0] < 0):
            err = f'ERROR Unknown physical location: {msg_obj.get("physical_location", "")}. Ignoring message'
            self.logger.error(err)
            # send a message to slack
            self.slack_msg.send_slack_msg(context, err)
            return

        self.logger.info("site_id: " + str(site_id))

        # filter out handing - accept runs for all locations, except UCF and George Mason runs for now
        renci = self.ASGSConstants_inst.getLuId('RENCI', 'site')
        tacc = self.ASGSConstants_inst.getLuId('TACC', 'site')
        lsu = self.ASGSConstants_inst.getLuId('LSU', 'site')
        penguin = self.ASGSConstants_inst.getLuId('Penguin', 'site')
        loni = self.ASGSConstants_inst.getLuId('LONI', 'site')
        seahorse = self.ASGSConstants_inst.getLuId('Seahorse', 'site')
        qb2 = self.ASGSConstants_inst.getLuId('QB2', 'site')
        cct = self.ASGSConstants_inst.getLuId('CCT', 'site')
        psc = self.ASGSConstants_inst.getLuId('PSC', 'site')

        if (
            (site_id[0] == renci) or
            (site_id[0] == tacc) or
            (site_id[0] == lsu) or
            (site_id[0] == penguin) or
            (site_id[0] == loni) or
            (site_id[0] == seahorse) or
            (site_id[0] == qb2) or
            (site_id[0] == cct) or
            (site_id[0] == psc)
        ):
            try:
                # get the instance id
                instance_id = self.ASGS_DB_inst.get_existing_instance_id(site_id[0], msg_obj)
                self.logger.info("instance_id: " + str(instance_id))
            except:
                e = sys.exc_info()[0]
                self.logger.error("FAILURE - Cannot retrieve instance id. error {0}".format(str(e)))
                # send a message to slack
                self.slack_msg.send_slack_msg(context, f'Incorrect or missing instance id in message: {msg_obj.get("instance_name", "N/A")}. Ignoring message')
                return

            # we must have an existing instance id
            if (instance_id > 0):
                # get the configuration params
                param_list = msg_obj.get("param_list")
            else:
                self.logger.error("FAILURE - Cannot find instance. Ignoring message")
                # send a message to slack
                self.slack_msg.send_slack_msg(context, f'Instance provided in message: {msg_obj.get("instance_name", "N/A")} does not exist. Ignoring message')
                return

            if (param_list is not None):
                # insert the records
                ret_msg = self.ASGS_DB_inst.insert_config_items(site_id, instance_id, param_list)
            else:
                err = "ERROR - Invalid message - 'param_list' key is missing from the message. Ignoring message"
                self.logger.error(err)
                # send a message to slack
                self.slack_msg.send_slack_msg(context, err)
                return
            if(ret_msg is not None):
                err = "ERROR - DB insert for message failed: {0}. Ignoring message".format(ret_msg)
                self.logger.error(err)
                # send a message to slack
                self.slack_msg.send_slack_msg(context, err)

        else:
            err = "The sites UFC and George Mason are not currently supported. Ignoring message."
            self.logger.info(err)
            # send a message to slack
            self.slack_msg.send_slack_msg(context, err)
