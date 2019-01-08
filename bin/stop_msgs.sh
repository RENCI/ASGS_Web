#/usr/bin/bash

# stop ASGS Monitor message receive process first
PID=`cat ../.msg_pidfile`
kill -- -$PID
[ $? -eq 0 ] && echo "Stopped DJango ASGS-Monitor mesg receive process" || echo "Failed to successfully stop JDango ASGS-Monitor mesg receive process"

# stop ASGS Monitor config message receive process first
PID=`cat ../.cfgmsg_pidfile`
kill -- -$PID
[ $? -eq 0 ] && echo "Stopped DJango ASGS-Monitor config mesg receive process" || echo "Failed to successfully stop JDango ASGS-Monitor configi mesg receive process"
