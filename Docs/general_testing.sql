/*
delete from ASGS_Mon_site_lu;
INSERT INTO ASGS_Mon_site_lu (id, name, description, cluster_name, tech_contact, phys_location, state_type_id) VALUES (0, 'RENCI', '', 'Hatteras', '', 'NC', 13);
INSERT INTO ASGS_Mon_site_lu (id, name, description, cluster_name, tech_contact, phys_location, state_type_id) VALUES (1, 'TACC', '', 'TACC cluster', '', 'TX', 13);
INSERT INTO ASGS_Mon_site_lu (id, name, description, cluster_name, tech_contact, phys_location, state_type_id) VALUES (2, 'LSU', '', 'LSU cluster', '', 'LA', 13);
INSERT INTO ASGS_Mon_site_lu (id, name, description, cluster_name, tech_contact, phys_location, state_type_id) VALUES (3, 'UCF', '', 'UCF cluster', '', 'FL', 13);
INSERT INTO ASGS_Mon_site_lu (id, name, description, cluster_name, tech_contact, phys_location, state_type_id) VALUES (4, 'George Mason', '', 'GM cluster', '', 'VA', 13);

delete from ASGS_Mon_event_type_lu;
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order, pct_complete) VALUES (0, 'RSTR', 'New run has started', 0, 0);
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order, pct_complete) VALUES (1, 'PRE1', 'Pre-run 1 operations in progress', 1, 20);
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order, pct_complete) VALUES (2, 'NOWC', 'NowCast operations in progress', 2, 40);
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order, pct_complete) VALUES (3, 'PRE2', 'Pre-run 2 operations in progress', 3, 60);
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order, pct_complete) VALUES (4, 'FDRC', 'Forcast operations in progress', 4, 80);
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order, pct_complete) VALUES (5, 'POST', 'Post-run operations in progress', 5, 90);
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order, pct_complete) VALUES (6, 'REND', 'Run has ended', 6, 100);
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order, pct_complete) VALUES (7, 'RDY', 'Ready for next run', 6, 0);


delete from ASGS_Mon_state_type_lu;
INSERT INTO ASGS_Mon_state_type_lu (id, name, description, view_order) VALUES (0, 'STRT', 'Operational.', 0);
INSERT INTO ASGS_Mon_state_type_lu (id, name, description, view_order) VALUES (1, 'RUNN', 'Running.', 1);
INSERT INTO ASGS_Mon_state_type_lu (id, name, description, view_order) VALUES (2, 'PEND', 'Pending.', 2);
INSERT INTO ASGS_Mon_state_type_lu (id, name, description, view_order) VALUES (3, 'FAIL', 'Error.', 3);
INSERT INTO ASGS_Mon_state_type_lu (id, name, description, view_order) VALUES (4, 'WARN', 'Warning.', 4);
INSERT INTO ASGS_Mon_state_type_lu (id, name, description, view_order) VALUES (5, 'IDLE', 'Idle.', 5);
INSERT INTO ASGS_Mon_state_type_lu (id, name, description, view_order) VALUES (6, 'EXIT', 'Shutdown.', 6);


-- use this to create python constants ready for cut/paste into the codebase
select d.const_name from 
(
        select id, '1' as 'theorder', 'CONST_SITE_' || UPPER(REPLACE(name, ' ', '') || ' = ' || id) as 'const_name' from ASGS_Mon_site_lu
        union
        select id, '2' as 'theorder', 'CONST_EVENT_TYPE_' ||  UPPER(REPLACE(name, ' ', '') || ' = ' || id) as 'const_name' from ASGS_Mon_event_type_lu
        union
        select id, '3' as 'theorder', 'CONST_STATE_' ||  UPPER(REPLACE(name, ' ', '') || ' = ' || id) as 'const_name' from ASGS_Mon_state_type_lu
) as d
order by d.theorder, d.id

*/

/*
-- this query gets the latest event groups across all sites
select sl.name, stl.name, eg.* 
from ASGS_Mon_event_group eg 
join ASGS_Mon_state_type_lu stl on stl.id=eg.state_type_id 
join ASGS_Mon_site_lu sl on sl.id=eg.site_id
inner join (select max(id) as id, site_id from ASGS_Mon_event_group group by site_id) AS megid on megid.id=eg.id and megid.site_id=eg.site_id;
 
-- this query gets the latest event from the latest event group across all sites
select sl.name,  e.*-- , eg.storm_name, etl.name
from ASGS_Mon_event e 
join ASGS_Mon_site_lu sl on sl.id=e.site_id 
join ASGS_Mon_event_group eg on eg.id=e.event_group_id 
join ASGS_Mon_event_type_lu etl on etl.id=e.event_type_id
inner join (select max(id) as id from ASGS_Mon_event group by site_id) AS meid on meid.id=e.id
inner join (select max(id) as id, site_id from ASGS_Mon_event_group group by site_id) AS megid on megid.id=e.event_group_id and megid.site_id=e.site_id;

*/


--delete from ASGS_Mon_event_group where id=64;
--delete from ASGS_Mon_event where event_group_id=64;

--select * from ASGS_Mon_event_group;
--select * from ASGS_Mon_event;
--select * from ASGS_Mon_site_lu;

-- it all starts with an event group. make one for every site
INSERT INTO ASGS_Mon_event_group (event_group_ts, storm_name, storm_number, advisory_id, final_product, site_id, state_type_id) VALUES (datetime(), 'Alpha', '1', '1', 'product', 0, 0);
INSERT INTO ASGS_Mon_event_group (event_group_ts, storm_name, storm_number, advisory_id, final_product, site_id, state_type_id) VALUES (datetime(), 'Beta', '2', '2', 'product', 1, 0);
INSERT INTO ASGS_Mon_event_group (event_group_ts, storm_name, storm_number, advisory_id, final_product, site_id, state_type_id) VALUES (datetime(), 'Charlie', '3', '3', 'product', 2, 0);
INSERT INTO ASGS_Mon_event_group (event_group_ts, storm_name, storm_number, advisory_id, final_product, site_id, state_type_id) VALUES (datetime(), 'Delta', '4', '4', 'product', 3, 0);
INSERT INTO ASGS_Mon_event_group (event_group_ts, storm_name, storm_number, advisory_id, final_product, site_id, state_type_id) VALUES (datetime(), 'Echo', '5', '5', 'product', 4, 0);

-- perform a run on the renci cluster
-- update the site cluster to running and start with a event that indicates the start
UPDATE ASGS_Mon_site_lu SET state_type_id = 1 where id = 0; 
INSERT INTO ASGS_Mon_event_group (event_group_ts, storm_name, storm_number, advisory_id, final_product, site_id, state_type_id) VALUES (datetime(), 'Alpha', '1', '1', 'product', 0, 0);
SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 0;
UPDATE ASGS_Mon_event_group SET state_type_id = 1 where id = (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 0); 
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 10, 'a host start file', 'Run start', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 0), 1, 0);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 20, 'a host start file', 'Run start', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 0), 2, 0);

-- next create an event that indicates pre 1 done, now c has started
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 30, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 0), 2, 0);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 40, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 0), 3, 0);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 50, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 0), 3, 0);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 60, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 0), 4, 0);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 70, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 0), 4, 0);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 80, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 0), 5, 0);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 90, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 0), 5, 0);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 100, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 0), 6, 0);
UPDATE ASGS_Mon_event_group SET state_type_id = 2 where id = 1; 
UPDATE ASGS_Mon_site_lu SET state_type_id = 2 where id = 0; 

-- perform a run on the TACC cluster
-- update the site cluster to running and start with a event that indicates the start
UPDATE ASGS_Mon_site_lu SET state_type_id = 1 where id = 1; 
INSERT INTO ASGS_Mon_event_group (event_group_ts, storm_name, storm_number, advisory_id, final_product, site_id, state_type_id) VALUES (datetime(), 'Beta', '2', '2', 'product', 1, 0);
SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 1;
UPDATE ASGS_Mon_event_group SET state_type_id = 1 where id = (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 1); 
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '2', 'the process', 10, 'a host start file', 'Run start', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 1), 1, 1);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '2', 'the process', 20, 'a host start file', 'Run start', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 1), 2, 1);

-- next create an event that indicates pre 1 done, now c has started
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '2', 'the process', 30, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 1), 2, 1);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '2', 'the process', 40, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 1), 3, 1);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '2', 'the process', 50, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 1), 3, 1);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '2', 'the process', 60, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 1), 4, 1);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '2', 'the process', 70, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 1), 4, 1);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '2', 'the process', 80, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 1), 5, 1);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '2', 'the process', 90, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 1), 5, 1);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '2', 'the process', 100, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 1), 6, 1);
UPDATE ASGS_Mon_event_group SET state_type_id = 2 where id = (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 1); 
UPDATE ASGS_Mon_site_lu SET state_type_id = 2 where id = 1; 

-- perform a run on the LSU cluster
-- update the site cluster to running and start with a event that indicates the start
UPDATE ASGS_Mon_site_lu SET state_type_id = 1 where id = 2; 
INSERT INTO ASGS_Mon_event_group (event_group_ts, storm_name, storm_number, advisory_id, final_product, site_id, state_type_id) VALUES (datetime(), 'Charlie', '3', '3', 'product', 2, 0);
SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 2;
UPDATE ASGS_Mon_event_group SET state_type_id = 1 where id = (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 2); 
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '3', 'the process', 10, 'a host start file', 'Run start', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 2), 1, 2);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '3', 'the process', 20, 'a host start file', 'Run start', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 2), 2, 2);

-- next create an event that indicates pre 1 done, now c has started
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '3', 'the process', 30, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 2), 2, 2);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '3', 'the process', 40, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 2), 3, 2);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '3', 'the process', 50, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 2), 3, 2);
--INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '3', 'the process', 60, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 2), 4, 2);

--INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '3', 'the process', 70, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 2), 4, 2);
--INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '3', 'the process', 80, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 2), 5, 2);

--INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '3', 'the process', 90, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 2), 5, 2);
--INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '3', 'the process', 100, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 2), 6, 2);
UPDATE ASGS_Mon_event_group SET state_type_id = 3 where id = (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 2); 
UPDATE ASGS_Mon_site_lu SET state_type_id = 3 where id = 2; 

-- perform a run on the UCF cluster
-- update the site cluster to running and start with a event that indicates the start
UPDATE ASGS_Mon_site_lu SET state_type_id = 1 where id = 3; 
INSERT INTO ASGS_Mon_event_group (event_group_ts, storm_name, storm_number, advisory_id, final_product, site_id, state_type_id) VALUES (datetime(), 'Delta', '4', '4', 'product', 3, 0);
SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 3;
UPDATE ASGS_Mon_event_group SET state_type_id = 1 where id = (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 3); 
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '4', 'the process', 10, 'a host start file', 'Run start', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 3), 1, 3);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '4', 'the process', 20, 'a host start file', 'Run start', 27, 2, 3);

-- next create an event that indicates pre 1 done, now c has started
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '4', 'the process', 30, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 3), 2, 3);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '4', 'the process', 40, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 3), 3, 3);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '4', 'the process', 50, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 3), 3, 3);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '4', 'the process', 60, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 3), 4, 3);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '4', 'the process', 70, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 3), 4, 3);
--INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '4', 'the process', 80, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 3), 5, 3);

--INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '4', 'the process', 90, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 3), 5, 3);
--INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '4', 'the process', 100, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 3), 6, 3);

--INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '4', 'the process', 100, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 3), 6, 3);
UPDATE ASGS_Mon_event_group SET state_type_id = 4 where id = (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 3); 
UPDATE ASGS_Mon_site_lu SET state_type_id = 5 where id = 3; 

-- perform a run on the GM cluster
-- update the site cluster to running and start with a event that indicates the start
UPDATE ASGS_Mon_site_lu SET state_type_id = 1 where id = 4; 
INSERT INTO ASGS_Mon_event_group (event_group_ts, storm_name, storm_number, advisory_id, final_product, site_id, state_type_id) VALUES (datetime(), 'Echo', '5', '5', 'product', 4, 0);
SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 4;
UPDATE ASGS_Mon_event_group SET state_type_id = 1 where id = (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 4); 
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '5', 'the process', 10, 'a host start file', 'Run start', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 4), 1, 4);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '5', 'the process', 20, 'a host start file', 'Run start', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 4), 2, 4);

-- next create an event that indicates pre 1 done, now c has started
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '5', 'the process', 30, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 4), 2, 4);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '5', 'the process', 40, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 4), 3, 4);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '5', 'the process', 50, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 4), 3, 4);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '5', 'the process', 60, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 4), 4, 4);

--INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '5', 'the process', 70, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 4), 4, 4);
--INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '5', 'the process', 80, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 4), 5, 4);

--INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '5', 'the process', 90, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 4), 5, 4);
--INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '5', 'the process', 100, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 4), 6, 4);

--INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '5', 'the process', 100, 'a host start file', 'Running', (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 4), 6, 4);
UPDATE ASGS_Mon_event_group SET state_type_id = 4 where id = (SELECT MAX(ID) FROM ASGS_Mon_event_group where site_id = 4); 
UPDATE ASGS_Mon_site_lu SET state_type_id = 4 where id = 4; 


/*
-- then the events flow in. 
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 40, 'a host start file', 'Run start', 1, 0, 0);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '2', 'the process', 10, 'a host start file', 'Run start', 2, 0, 1);
UPDATE ASGS_Mon_site_lu SET state_type_id = 1 where id = 1; 

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 10, 'a host start file', 'sfdhsdfgdsfgdgfsgsdfg  run', 1, 1, 0);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '2', 'the process', 0, 'a host start file', 'test run', 2, 0, 1);


INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 0, 'a host start file', 'NowCast', 1, 2, 0);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 0, 'a host start file', 'Pre 2', 1, 3, 0);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 0, 'a host start file', 'Forecast', 1, 4, 0);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 0, 'a host start file', 'Post run', 1, 5, 0);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 0, 'a start file', 'Run end', 1, 6, 0);
UPDATE Site_lu SET state_type_id = 5; 
*/