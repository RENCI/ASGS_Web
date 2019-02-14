import logging
import logging.handlers

def setup(name, log_file="rcv_msg_svc.log", log_level=logging.INFO, toConsole=False):
    # logger settings
    log_file = "rcv_msg_svc.log"
    log_num_backups = 7
    log_format = "%(asctime)s [%(levelname)s]: (%(funcName)s:%(lineno)s) >> %(message)s"
    log_date_format = "%m/%d/%Y %I:%M:%S %p"
    log_filemode = "w" # w: overwrite; a: append
    
    # setup logger
    logging.basicConfig(filename=log_file, datefmt=log_date_format, format=log_format, filemode=log_filemode ,level=log_level)
    
    # Add the log message handler to the logger
    handler = logging.handlers.TimedRotatingFileHandler(log_file, when="d", interval=1, backupCount=log_num_backups)

    logger = logging.getLogger(name)
    logger.addHandler(handler)

    # print log messages to console
    if toConsole == True:
        consoleHandler = logging.StreamHandler()
        logFormatter = logging.Formatter(log_format)
        consoleHandler.setFormatter(logFormatter)
        logger.addHandler(consoleHandler)

    return logger

# source: https://docs.python.org/2/howto/logging.html
# logger.debug("")      // Detailed information, typically of interest only when diagnosing problems.
# logger.info("")       // Confirmation that things are working as expected.
# logger.warning("")    // An indication that something unexpected happened, or indicative of some problem in the near future
# logger.error("")      // Due to a more serious problem, the software has not been able to perform some function.
# logger.critical("")   // A serious error, indicating that the program itself may be unable to continue running.