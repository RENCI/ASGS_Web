import logging
import logging.handlers

############################
# logger setup 
############################
def setup(name, log_file="logs/rcv_msg_svc.log", log_level=logging.WARN, toConsole=False):
    # logger settings
    log_num_backups = 7
    log_format = "%(asctime)s [%(levelname)s]: (%(funcName)s:%(lineno)s) >> %(message)s"
    log_date_format = "%m/%d/%Y %I:%M:%S %p"
    log_filemode = "a" # w: overwrite; a: append
    
    # setup logger
    logging.basicConfig(datefmt=log_date_format, format=log_format, filemode=log_filemode)

    # Add the log message handler to the logger
    handler = logging.handlers.TimedRotatingFileHandler(log_file, when="d", interval=1, backupCount=log_num_backups)

    logger = logging.getLogger(name)
    logger.addHandler(handler)
    logger.setLevel(log_level)
    
    # print log messages to console
    if toConsole == True:
        consoleHandler = logging.StreamHandler()
        logFormatter = logging.Formatter(log_format)
        consoleHandler.setFormatter(logFormatter)
        logger.addHandler(consoleHandler)

    # return to the caller
    return logger
