#!/bin/bash
echo "Sleeping $1 second(s) to give the queue time to initialize"
sleep $1
echo "Starting message handlers..."
python receive_msg_service_pg.py &
python receive_cfg_msg_service_pg.py &
while true; do sleep 600; done;
