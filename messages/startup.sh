# /usr/bin/bash

python receive_msg_service_pg.py &
python receive_cfg_msg_service_pg.py &
while true; do sleep 600; done;