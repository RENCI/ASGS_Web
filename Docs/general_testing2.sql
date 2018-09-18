-- insert instances
INSERT INTO Instance (epoch, run_params, inst_state_type, site) VALUES (1, 'run params 1', 1, 0);
--INSERT INTO Instance (epoch, run_params, inst_state_type, site) VALUES (2, 'run params 2', 1, 1);
--INSERT INTO Instance (epoch, run_params, inst_state_type, site) VALUES (3, 'run params 3', 1, 2);
--INSERT INTO Instance (epoch, run_params, inst_state_type, site) VALUES (4, 'run params 4', 1, 3);
--INSERT INTO Instance (epoch, run_params, inst_state_type, site) VALUES (5, 'run params 5', 1, 4);
-- additional instance for renci cluster
--INSERT INTO Instance (epoch, run_params, inst_state_type, site) VALUES (6, 'run params 6', 1, 0);

-- insert an event group
INSERT INTO ASGS_Mon_event_group (instance, state_type, event_group_ts, storm_name, storm_number, advisory_id, final_product) VALUES (1, 1, datetime(), 'Alpha', '1', '1', 'product 1', 0, 0);
--INSERT INTO ASGS_Mon_event_group (instance, state_type, event_group_ts, storm_name, storm_number, advisory_id, final_product) VALUES (2, 2, datetime(), 'Beta', '1', '1', 'product 2', 0, 0);
--INSERT INTO ASGS_Mon_event_group (instance, state_type, event_group_ts, storm_name, storm_number, advisory_id, final_product) VALUES (3, 3, datetime(), 'Charlie', '1', '1', 'product 3', 0, 0);
--INSERT INTO ASGS_Mon_event_group (instance, state_type, event_group_ts, storm_name, storm_number, advisory_id, final_product) VALUES (4, 4, datetime(), 'Delta', '1', '1', 'product 4', 0, 0);
--INSERT INTO ASGS_Mon_event_group (instance, state_type, event_group_ts, storm_name, storm_number, advisory_id, final_product) VALUES (5, 5, datetime(), 'Echo', '1', '1', 'product 5', 0, 0);
-- event for additional renci instance 
--INSERT INTO ASGS_Mon_event_group (instance, state_type, event_group_ts, storm_name, storm_number, advisory_id, final_product) VALUES (6, 6, datetime(), 'Fox Trot', '1', '1', 'product 6', 0, 0);

-- insert the events for site 0, instance 1 
-- first get max event group id for display purposes 
SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 0;
-- update the event group to running
UPDATE ASGS_Mon_event_group SET state_type_id = 1 where id = (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 0 and instance = 1); 
-- insert the actual event
INSERT INTO ASGS_Mon_event (site, event_group, event_type, event_ts, advisory_id, pct_complete, process, raw_data) VALUES (0, (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 0 and instance = 1), 1, datetime(), 'adv 1', 10, 'proc 1', 'raw data 1');;
INSERT INTO ASGS_Mon_event (site, event_group, event_type, event_ts, advisory_id, pct_complete, process, raw_data) VALUES (0, (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 0 and instance = 1), 1, datetime(), 'adv 1', 20, 'proc 1', 'raw data 1');;


