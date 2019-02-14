#######################
# class to transform a ASGS LU constant from a name to a ID
#######################
class ASGSConstants:

    def __init__(self, logger):
        self.logger = logger

        # define the LU constants
        self.pct_complete_lu = {'0':0,'1':5,'2':20,'3':40,'4':60,'5':90,'6':100,'7':0,'8':0,'9':0,'10':40,'11':90}
        self.site_lu = {'RENCI':0,'TACC':1,'LSU':2,'UCF':3,'George Mason':4,'Penguin':5,'LONI':6}
        self.event_type_lu = {'RSTR':0,'PRE1':1,'NOWC':2,'PRE2':3,'FORE':4,'POST':5,'REND':6,'STRT':7,'HIND':8,'EXIT':9,'FSTR':10,'FEND':11}
        self.state_type_lu = {'INIT':0,'RUNN':1,'PEND':2,'FAIL':3,'WARN':4,'IDLE':5,'CMPL':6,'NONE':7,'WAIT':8,'EXIT':9,'STALLED':10}
        self.instance_state_type_lu = {'INIT':0,'RUNN':1,'PEND':2,'FAIL':3,'WARN':4,'IDLE':5,'CMPL':6,'NONE':7,'WAIT':8,'EXIT':9,'STALLED':10}

        logger.debug("ASGSConstants initialized")

    #
    # gets the id from a lookup
    #
    def getLuIdFromMsg(self, msgObj, paramName, luArr): 
        # get the name
        retName = msgObj.get(paramName, "")
        
        # get the ID
        retID = luArr.get(retName, -1)
        
        # did we find something
        if retID >= 0:
            self.logger.debug("PASS - Param name " + paramName + " is " + str(retID))
        else:
            self.logger.error("FAILURE - Invalid or no param name " + paramName + " found")
            
        #return to the caller
        return retID, retName
