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

*/
