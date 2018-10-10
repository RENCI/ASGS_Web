-- wipe everything
-- delete from "ASGS_Mon_instance";
-- delete from "ASGS_Mon_event_group";
-- delete from "ASGS_Mon_event";

-- select * from "ASGS_Mon_instance"
-- select * from "ASGS_Mon_event_group"
-- select * from "ASGS_Mon_event_group" where instance_id = (select max(instance_id) from "ASGS_Mon_instance" where site_id=0 and process_id=1)
-- select * from "ASGS_Mon_event"
-- update "ASGS_Mon_instance" set inst_state_type_id=2 where id=8
-- update "ASGS_Mon_event_group" set state_type_id=2 where id=8


-- insert intial "ASGS_Mon_instance" for renci cluster
INSERT INTO "ASGS_Mon_instance" (process_id, site_id, inst_state_type_id, start_ts, run_params, instance_name) VALUES (1, 0, 1, now(), 'run params 1', 'instance1');

-- insert an event group
INSERT INTO "ASGS_Mon_event_group" (instance_id, state_type_id, event_group_ts, storm_name, storm_number, advisory_id, final_product) VALUES ((select max(id) from "ASGS_Mon_instance" where site_id=0 and process_id=1), 1, now(), 'Alpha', '1', '1', 'product 1');

-- insert the events for site 0, instance 1 
-- first get max event group id for display purposes 
SELECT MAX(id) FROM "ASGS_Mon_event_group" where instance_id = (select max(id) from "ASGS_Mon_instance" where site_id=0 and process_id=1);

-- update the event group to running
UPDATE "ASGS_Mon_event_group" SET state_type_id = 1 where id = (SELECT MAX(ID) FROM "ASGS_Mon_event_group" where instance_id = (select max(id) from "ASGS_Mon_instance" where site_id=0 and process_id=1)); 

-- insert the actual events
INSERT INTO "ASGS_Mon_event" (site_id, event_group_id, event_type_id, event_ts, advisory_id, pct_complete, process, raw_data) VALUES (0, (SELECT MAX(id) FROM "ASGS_Mon_event_group" where instance_id = (select max(id) from "ASGS_Mon_instance" where site_id=0 and process_id=1)), 1, now(), 'advisory 1', 10, 'instance 1', 'event data 1-1');;
INSERT INTO "ASGS_Mon_event" (site_id, event_group_id, event_type_id, event_ts, advisory_id, pct_complete, process, raw_data) VALUES (0, (SELECT MAX(id) FROM "ASGS_Mon_event_group" where instance_id = (select max(id) from "ASGS_Mon_instance" where site_id=0 and process_id=1)), 1, now(), 'advisory 1', 20, 'instance 1', 'event data 1-2');;




-- additional "ASGS_Mon_instance" for renci cluster
INSERT INTO "ASGS_Mon_instance" (process_id, site_id, inst_state_type_id, start_ts, run_params, instance_name) VALUES (6, 0, 1, now(), 'run params 6', 'instance6');

-- insert an event group
INSERT INTO "ASGS_Mon_event_group" (instance_id, state_type_id, event_group_ts, storm_name, storm_number, advisory_id, final_product) VALUES ((select max(id) from "ASGS_Mon_instance" where site_id=0 and process_id=6), 1, now(), 'Alpha', '1', '1', 'product 6');

-- insert the events for site 0, instance 1 
-- first get max event group id for display purposes 
SELECT MAX(id) FROM "ASGS_Mon_event_group" where instance_id = (select max(id) from "ASGS_Mon_instance" where site_id=0 and process_id=6);

-- update the event group to running
UPDATE "ASGS_Mon_event_group" SET state_type_id = 1 where id = (SELECT MAX(ID) FROM "ASGS_Mon_event_group" where instance_id = (select max(id) from "ASGS_Mon_instance" where site_id=0 and process_id=6)); 

-- insert the actual events
INSERT INTO "ASGS_Mon_event" (site_id, event_group_id, event_type_id, event_ts, advisory_id, pct_complete, process, raw_data) VALUES (0, (SELECT MAX(id) FROM "ASGS_Mon_event_group" where instance_id = (select max(id) from "ASGS_Mon_instance" where site_id=0 and process_id=6)), 1, now(), 'advisory 1', 10, 'process 6', 'event data 6-1');;
INSERT INTO "ASGS_Mon_event" (site_id, event_group_id, event_type_id, event_ts, advisory_id, pct_complete, process, raw_data) VALUES (0, (SELECT MAX(id) FROM "ASGS_Mon_event_group" where instance_id = (select max(id) from "ASGS_Mon_instance" where site_id=0 and process_id=6)), 1, now(), 'advisory 1', 20, 'process 6', 'event data 6-2');;

INSERT INTO "ASGS_Mon_event" (site_id, event_group_id, event_type_id, event_ts, advisory_id, pct_complete, process, raw_data) VALUES (0, (SELECT MAX(id) FROM "ASGS_Mon_event_group" where instance_id = (select max(id) from "ASGS_Mon_instance" where site_id=0 and process_id=6)), 2, now(), 'advisory 1', 30, 'process 6', 'event data 6-3');;
INSERT INTO "ASGS_Mon_event" (site_id, event_group_id, event_type_id, event_ts, advisory_id, pct_complete, process, raw_data) VALUES (0, (SELECT MAX(id) FROM "ASGS_Mon_event_group" where instance_id = (select max(id) from "ASGS_Mon_instance" where site_id=0 and process_id=6)), 2, now(), 'advisory 1', 40, 'process 6', 'event data 6-4');;





-- "ASGS_Mon_instance" for TACC cluster
INSERT INTO "ASGS_Mon_instance" (process_id, site_id, inst_state_type_id, start_ts, run_params, instance_name) VALUES (2, 1, 1, now(), 'run params 2', 'instance2');

-- insert an event group
INSERT INTO "ASGS_Mon_event_group" (instance_id, state_type_id, event_group_ts, storm_name, storm_number, advisory_id, final_product) VALUES ((select max(id) from "ASGS_Mon_instance" where site_id=1 and process_id=2), 1, now(), 'Beta', '2', '2', 'product 2');

-- insert the events for site 0, instance 1 
-- first get max event group id for display purposes 
SELECT MAX(id) FROM "ASGS_Mon_event_group" where instance_id = (select max(id) from "ASGS_Mon_instance" where site_id=1 and process_id=2);

-- update the event group to running
UPDATE "ASGS_Mon_event_group" SET state_type_id = 1 where id = (SELECT MAX(ID) FROM "ASGS_Mon_event_group" where instance_id = (select max(id) from "ASGS_Mon_instance" where site_id=1 and process_id=2)); 

-- insert the actual events
INSERT INTO "ASGS_Mon_event" (site_id, event_group_id, event_type_id, event_ts, advisory_id, pct_complete, process, raw_data) VALUES (0, (SELECT MAX(id) FROM "ASGS_Mon_event_group" where instance_id = (select max(id) from "ASGS_Mon_instance" where site_id=1 and process_id=2)), 1, now(), 'advisory 2', 10, 'process 2', 'event data 2-1');;
INSERT INTO "ASGS_Mon_event" (site_id, event_group_id, event_type_id, event_ts, advisory_id, pct_complete, process, raw_data) VALUES (0, (SELECT MAX(id) FROM "ASGS_Mon_event_group" where instance_id = (select max(id) from "ASGS_Mon_instance" where site_id=1 and process_id=2)), 1, now(), 'advisory 2', 20, 'process 2', 'event data 2-2');;

INSERT INTO "ASGS_Mon_event" (site_id, event_group_id, event_type_id, event_ts, advisory_id, pct_complete, process, raw_data) VALUES (0, (SELECT MAX(id) FROM "ASGS_Mon_event_group" where instance_id = (select max(id) from "ASGS_Mon_instance" where site_id=1 and process_id=2)), 2, now(), 'advisory 2', 30, 'process 2', 'event data 2-3');;
INSERT INTO "ASGS_Mon_event" (site_id, event_group_id, event_type_id, event_ts, advisory_id, pct_complete, process, raw_data) VALUES (0, (SELECT MAX(id) FROM "ASGS_Mon_event_group" where instance_id = (select max(id) from "ASGS_Mon_instance" where site_id=1 and process_id=2)), 2, now(), 'advisory 2', 40, 'process 2', 'event data 2-4');;

INSERT INTO "ASGS_Mon_event" (site_id, event_group_id, event_type_id, event_ts, advisory_id, pct_complete, process, raw_data) VALUES (0, (SELECT MAX(id) FROM "ASGS_Mon_event_group" where instance_id = (select max(id) from "ASGS_Mon_instance" where site_id=1 and process_id=2)), 3, now(), 'advisory 2', 30, 'process 2', 'event data 3-5');;
INSERT INTO "ASGS_Mon_event" (site_id, event_group_id, event_type_id, event_ts, advisory_id, pct_complete, process, raw_data) VALUES (0, (SELECT MAX(id) FROM "ASGS_Mon_event_group" where instance_id = (select max(id) from "ASGS_Mon_instance" where site_id=1 and process_id=2)), 3, now(), 'advisory 2', 40, 'process 2', 'event data 3-6');;
