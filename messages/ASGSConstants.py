import logging

#######################
# class to transform a ASGS LU constant from a name to a ID
#
# SQL to generate the constant ArraySubclass
# SELECT 
#    'pct_complete_lu = {' || array_to_string(ARRAY (SELECT '''' || id || ''':' || pct_complete FROM public."ASGS_Mon_event_type_lu" order by id), ','::text) || '}' as c1,
#    'site_lu = {' || array_to_string(ARRAY (SELECT '''' || name || ''':' || id FROM public."ASGS_Mon_site_lu" order by id), ','::text) || '}' as c2 ,
#    'event_type_lu = {' || array_to_string(ARRAY (SELECT '''' || name || ''':' || id FROM public."ASGS_Mon_event_type_lu" order by id), ','::text) || '}' as c3,
#    'state_type_lu = {' || array_to_string(ARRAY (SELECT '''' || name || ''':' || id FROM public."ASGS_Mon_state_type_lu" order by id), ','::text) || '}' as c4,
#    'instance_state_type_lu = {' || array_to_string(ARRAY (SELECT '''' || name || ''':' || id FROM public."ASGS_Mon_instance_state_type_lu" order by id), ','::text) || '}' as c5
#######################
class ASGSConstants:
    
    # define the LU constants
    pct_complete_lu = {'0':0,'1':5,'2':20,'3':40,'4':60,'5':90,'6':100,'7':0,'8':0,'9':0,'10':40,'11':90}
    site_lu = {'RENCI':0,'TACC':1,'LSU':2,'UCF':3,'George Mason':4,'Penguin':5,'LONI':6,'Seahorse':7,'QB2':8,'CCT':9,'PSC':10}
    event_type_lu = {'RSTR':0,'PRE1':1,'NOWC':2,'PRE2':3,'FORE':4,'POST':5,'REND':6,'STRT':7,'HIND':8,'EXIT':9,'FSTR':10,'FEND':11,'PNOW':12}
    state_type_lu = {'INIT':0,'RUNN':1,'PEND':2,'FAIL':3,'WARN':4,'IDLE':5,'CMPL':6,'NONE':7,'WAIT':8,'EXIT':9,'STALLED':10}
    instance_state_type_lu = {'INIT':0,'RUNN':1,'PEND':2,'FAIL':3,'WARN':4,'IDLE':5,'CMPL':6,'NONE':7,'WAIT':8,'EXIT':9,'STALLED':10}

    # define string lookup of LU name array
    lus = {"pct_complete" : pct_complete_lu, "site":site_lu, "event_type":event_type_lu, "state_type":state_type_lu, "instance_state_type":instance_state_type_lu}

    def __init__(self, logger=None):
        # load the logger
        self.logger = logger or logging.getLogger(__name__)
   
        self.logger.info("ASGSConstants initialized")

    #
    # gets the id from a lookup table
    #
    def getLuIdFromMsg(self, msgObj, paramName, luName):         
        # get the name
        retName = msgObj.get(paramName, "")
        
        # get the ID
        retID = self.getLuId(retName, luName)
        
        # did we find something
        if retID >= 0:
            self.logger.debug("PASS - LU name: {0}, Param name: {1}, ID: {2}", luName, paramName, str(retID))
        else:
            self.logger.error("FAILURE - Invalid or no param name: {0} not found in: {1}", paramName, luName)
            
        #return to the caller
        return retID, retName

    #
    # gets the id from a lookup table
    #
    def getLuId(self, elementName, luName):                 
        # get the ID
        retID = self.lus[luName].get(elementName, -1)
        
        # did we find something
        if retID >= 0:
            self.logger.debug("PASS - LU name: {0}, element name: {1}, ID: {2}", luName, elementName, str(retID))
        else:
            self.logger.error("FAILURE - Invalid or no element name: {0} not found in: {1}", elementName, luName)
            
        #return to the caller
        return retID
