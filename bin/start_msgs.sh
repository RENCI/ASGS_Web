# /usr/bin/bash

#get in the right place
cd ../

# start the receive messages process
# this will get asgs messages off of the Rabbit MQ (queue: asgs_queue) and write them into the ASGS Monitor DB
setsid python messages/receive_msg_service_pg.py > /dev/null 2>&1 &
RETVAL=$?
PID=$!
[ $RETVAL -eq 0 ] && echo $PID > .msg_pidfile && echo "Started ASGS-Monitor receive mesg process" || echo "Failed to successfully start receive mesg ASGS-Monitor process"

# start the receive messages process
# this will get asgs config messages off of the Rabbit MQ (queue: asgs_config) and write them into the ASGS Monitor DB
setsid python messages/receive_msg__configs_ervice_pg.py > /dev/null 2>&1 &
RETVAL=$?
PID=$!
[ $RETVAL -eq 0 ] && echo $PID > .cfgmsg_pidfile && echo "Started ASGS-Monitor receive config mesg process" || echo "Failed to successfully start receive configmesg ASGS-Monitor process"
