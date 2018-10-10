# /usr/bin/bash

#get in the right place
cd ../

# start the receive messages process
# this will get asgs messages off of the Rabbit MQ and write them into the ASGS Monitor DB
setsid python messages/receive_msg_service_pg.py > /dev/null 2>&1 &
RETVAL=$?
PID=$!
[ $RETVAL -eq 0 ] && echo $PID > .msg_pidfile && echo "Started ASGS-Monitor receive mesg process" || echo "Failed to successfully start receive mesg ASGS-Monitor process"

# now run the DJango server with ASGS Monitor website
setsid /bin/python3 manage.py runserver 0.0.0.0:8000 > /dev/null 2>&1 &
RETVAL=$?
PID=$!
[ $RETVAL -eq 0 ] && echo $PID > .django_pidfile && echo "Started JDango ASGS-Monitor service" || echo "Failed to successfully start JDango ASGS-Monitor service"

