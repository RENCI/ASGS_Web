/*
delete from ASGS_Mon_event_group;
delete from ASGS_Mon_event;

select * from ASGS_Mon_event_group;
select * from ASGS_Mon_event;

-- example event group inserts
INSERT INTO ASGS_Mon_event_group (event_group_ts, storm_name, storm_number, advisory_id, final_product, site_id, state_type_id) VALUES (datetime(), 'Alpha', '1', '1', 'product', 0, 0);
INSERT INTO ASGS_Mon_event_group (event_group_ts, storm_name, storm_number, advisory_id, final_product, site_id, state_type_id) VALUES (datetime(), 'Beta', '2', '2', 'product', 1, 0);
INSERT INTO ASGS_Mon_event_group (event_group_ts, storm_name, storm_number, advisory_id, final_product, site_id, state_type_id) VALUES (datetime(), 'Charlie', '3', '3', 'product', 2, 0);
INSERT INTO ASGS_Mon_event_group (event_group_ts, storm_name, storm_number, advisory_id, final_product, site_id, state_type_id) VALUES (datetime(), 'Delta', '4', '4', 'product', 3, 0);
INSERT INTO ASGS_Mon_event_group (event_group_ts, storm_name, storm_number, advisory_id, final_product, site_id, state_type_id) VALUES (datetime(), 'Echo', '5', '5', 'product', 4, 0);
*/

--------------------------------------------------------------
-- performing a typical run on the renci cluster...
--
-- sequence of events for a typical run are:
--		represent a new advisory has landed by:
--			update the state of the site to indicate running
-- 			insert a new event group record for the site (save this ID or get the max(id) for the site)
--			insert an event to indicate the process has started
--		subsequent updates for each stage of the process are done by inserting event records based on cluster run status
--		end of run state is done by:
--			sending final event to indicate complete
--			updating the event group to pending another job
--			updating the cluster state to idle
--------------------------------------------------------------

-- initiate a new run. update the site to RUNN and create a new event group
UPDATE ASGS_Mon_site_lu SET state_type_id = 1 where id = 0; 
INSERT INTO ASGS_Mon_event_group (event_group_ts, storm_name, storm_number, advisory_id, final_product, site_id, state_type_id) VALUES (datetime(), 'Alpha', '1', '1', 'product', 0, 0);

-- use this to determine the last event group id for the site. all event records must use this for the entirety of the run
SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 0;

-- create the initial event to start the run. only now will something appear on the UI for the site
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 10, 'a host start file', 'Run start', 7, 1, 0);

-- create an event that indicates PRE1 is complete
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 20, 'a host start file', 'Running', 7, 2, 0);

-- create an event that indicates NOWC has started
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 30, 'a host start file', 'Running', 7, 2, 0);

-- create an event that indicates NOWC has ended
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 40, 'a host start file', 'Running', 7, 3, 0);

-- create an event that indicates PRE2 has started
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 50, 'a host start file', 'Running', 7, 3, 0);

-- create an event that indicates PRE2 has ended
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 60, 'a host start file', 'Running', 7, 4, 0);

-- create an event that indicates FDRC has started
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 70, 'a host start file', 'Running', 7, 4, 0);

-- create an event that indicates FDRC has ended
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 80, 'a host start file', 'Running', 7, 5, 0);

-- create an event that indicates FDRC has ended
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 90, 'a host start file', 'Running', 7, 5, 0);

-- create an event that indicates run has ended
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 100, 'a host start file', 'Running', 7, 6, 0);

-- set the event group state to pending next run
UPDATE ASGS_Mon_event_group SET state_type_id = 2 where id = 7;

-- set the site state to idle
UPDATE ASGS_Mon_site_lu SET state_type_id = 5 where id = 0; 


--------------------------------------------------------------
-- perform a run on the TACC cluster
-- update the site cluster to running and start with a event that indicates the start
--------------------------------------------------------------
UPDATE ASGS_Mon_site_lu SET state_type_id = 1 where id = 1; 
INSERT INTO ASGS_Mon_event_group (event_group_ts, storm_name, storm_number, advisory_id, final_product, site_id, state_type_id) VALUES (datetime(), 'Beta', '2', '2', 'product', 1, 0);
SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 1;
UPDATE ASGS_Mon_event_group SET state_type_id = 1 where id = 11; 
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '2', 'the process', 10, 'a host start file', 'Run start', 11, 1, 1);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '2', 'the process', 20, 'a host start file', 'Run start', 11, 2, 1);

-- next create an event that indicates pre 1 done, now c has started
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '2', 'the process', 30, 'a host start file', 'Running', 11, 2, 1);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '2', 'the process', 40, 'a host start file', 'Running', 11, 3, 1);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '2', 'the process', 50, 'a host start file', 'Running', 11, 3, 1);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '2', 'the process', 60, 'a host start file', 'Running', 11, 4, 1);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '2', 'the process', 70, 'a host start file', 'Running', 11, 4, 1);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '2', 'the process', 80, 'a host start file', 'Running', 11, 5, 1);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '2', 'the process', 90, 'a host start file', 'Running', 11, 5, 1);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '2', 'the process', 100, 'a host start file', 'Running', 11, 6, 1);
UPDATE ASGS_Mon_event_group SET state_type_id = 1 where id = 11; 
UPDATE ASGS_Mon_site_lu SET state_type_id = 5 where id = 1; 

--------------------------------------------------------------
-- perform a run on the LSU cluster
-- update the site cluster to running and start with a event that indicates the start
--------------------------------------------------------------
UPDATE ASGS_Mon_site_lu SET state_type_id = 1 where id = 2; 
INSERT INTO ASGS_Mon_event_group (event_group_ts, storm_name, storm_number, advisory_id, final_product, site_id, state_type_id) VALUES (datetime(), 'Charlie', '3', '3', 'product', 2, 0);
SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 2;
UPDATE ASGS_Mon_event_group SET state_type_id = 1 where id = 12; 
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '3', 'the process', 10, 'a host start file', 'Run start', 12, 1, 2);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '3', 'the process', 20, 'a host start file', 'Run start', 12, 2, 2);

-- next create an event that indicates pre 1 done, now c has started
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '3', 'the process', 30, 'a host start file', 'Running', 12, 2, 2);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '3', 'the process', 40, 'a host start file', 'Running', 12, 3, 2);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '3', 'the process', 50, 'a host start file', 'Running', 12, 3, 2);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '3', 'the process', 60, 'a host start file', 'Running', 12, 4, 2);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '3', 'the process', 70, 'a host start file', 'Running', 12, 4, 2);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '3', 'the process', 80, 'a host start file', 'Running', 12, 5, 2);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '3', 'the process', 90, 'a host start file', 'Running', 12, 5, 2);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '3', 'the process', 100, 'a host start file', 'Running', 12, 6, 2);
UPDATE ASGS_Mon_event_group SET state_type_id = 3 where id = 12; 
UPDATE ASGS_Mon_site_lu SET state_type_id = 3 where id = 2; 

--------------------------------------------------------------
-- perform a run on the UCF cluster
-- update the site cluster to running and start with a event that indicates the start
--------------------------------------------------------------
UPDATE ASGS_Mon_site_lu SET state_type_id = 1 where id = 3; 
INSERT INTO ASGS_Mon_event_group (event_group_ts, storm_name, storm_number, advisory_id, final_product, site_id, state_type_id) VALUES (datetime(), 'Delta', '4', '4', 'product', 3, 0);
SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 3;
UPDATE ASGS_Mon_event_group SET state_type_id = 1 where id = 13; 
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '4', 'the process', 10, 'a host start file', 'Run start', 13, 1, 3);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '4', 'the process', 20, 'a host start file', 'Run start', 13, 2, 3);

-- next create an event that indicates pre 1 done, now c has started
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '4', 'the process', 30, 'a host start file', 'Running', 13, 2, 3);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '4', 'the process', 40, 'a host start file', 'Running', 13, 3, 3);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '4', 'the process', 50, 'a host start file', 'Running', 13, 3, 3);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '4', 'the process', 60, 'a host start file', 'Running', 13, 4, 3);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '4', 'the process', 70, 'a host start file', 'Running', 13, 4, 3);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '4', 'the process', 80, 'a host start file', 'Running', 13, 5, 3);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '4', 'the process', 90, 'a host start file', 'Running', 13, 5, 3);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '4', 'the process', 100, 'a host start file', 'Running', 13, 6, 3);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '4', 'the process', 100, 'a host start file', 'Running', 13, 6, 3);
UPDATE ASGS_Mon_event_group SET state_type_id = 4 where id = 13; 
UPDATE ASGS_Mon_site_lu SET state_type_id = 4 where id = 3; 

--------------------------------------------------------------
-- perform a run on the GM cluster
-- update the site cluster to running and start with a event that indicates the start
--------------------------------------------------------------
UPDATE ASGS_Mon_site_lu SET state_type_id = 1 where id = 4; 
INSERT INTO ASGS_Mon_event_group (event_group_ts, storm_name, storm_number, advisory_id, final_product, site_id, state_type_id) VALUES (datetime(), 'Echo', '5', '5', 'product', 4, 0);
SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 4;
UPDATE ASGS_Mon_event_group SET state_type_id = 1 where id = 14; 
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '5', 'the process', 10, 'a host start file', 'Run start', 14, 1, 4);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '5', 'the process', 20, 'a host start file', 'Run start', 14, 2, 4);

-- next create an event that indicates pre 1 done, now c has started
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '5', 'the process', 30, 'a host start file', 'Running', 14, 2, 4);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '5', 'the process', 40, 'a host start file', 'Running', 14, 3, 4);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '5', 'the process', 50, 'a host start file', 'Running', 14, 3, 4);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '5', 'the process', 60, 'a host start file', 'Running', 14, 4, 4);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '5', 'the process', 70, 'a host start file', 'Running', 14, 4, 4);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '5', 'the process', 80, 'a host start file', 'Running', 14, 5, 4);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '5', 'the process', 90, 'a host start file', 'Running', 14, 5, 4);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '5', 'the process', 100, 'a host start file', 'Running', 14, 6, 4);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '5', 'the process', 100, 'a host start file', 'Running', 14, 6, 4);
UPDATE ASGS_Mon_event_group SET state_type_id = 4 where id = 14; 
UPDATE ASGS_Mon_site_lu SET state_type_id = 4 where id = 4; 

*/
