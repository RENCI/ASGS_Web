import sys
import json
from warnings import catch_warnings

from ASGSConstants import ASGSConstants
from ASGS_DB import ASGS_DB

class ASGS_Queue_callback:
    def __init__(self, logger, parser):
        # save the reference to the logger
        self.logger = logger
        
        # save the reference to the configuration params
        self.parser = parser
        
        # define and init the object used to handle ASGS constant conversions
        self.ASGSConstants_inst = ASGSConstants(self.logger)
        
        # define and init the object that will handle ASGS DB operations
        self.ASGS_DB_inst = ASGS_DB(self.logger, self.ASGSConstants_inst, self.parser)

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
                # get the percent complete from a LU lookup
                pct_complete = self.ASGSConstants_inst.getLuId(str(event_type_id), "pct_complete")
    
                event_group_id = self.ASGS_DB_inst.insert_event_group(state_id, instance_id, pct_complete, msg_obj)
            except:
                e = sys.exc_info()[0]
                self.logger.error("FAILURE - Cannot insert event group. error {0}".format(str(e)))
                return
        else:
            # don't need a new event group
            self.logger.debug("Reusing event_group_id: {0}".format(event_group_id))
    
            # update event group with this latest state
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
    
        # if we got this far commit all outstanding DB queries    
        self.ASGS_DB_inst.db_commit()
