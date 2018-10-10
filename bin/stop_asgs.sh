#/usr/bin/bash

# stop ASGS Monitor message receive process first
PID=`cat ../ASGS_Web/.msg_pidfile`
kill -- -$PID
[ $? -eq 0 ] && echo "Stopped DJango ASGS-Monitor mesg receive process" || echo "Failed to successfully stop JDango ASGS-Monitor mesg receive process"

PID=`cat ../ASGS_Web/.django_pidfile`
kill -- -$PID
[ $? -eq 0 ] && echo "Stopped DJango ASGS-Monitor service" || echo "Failed to successfully stop JDango ASGS-Monitor service"
