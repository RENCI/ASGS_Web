/* 
delete from ASGS_Mon_event_group;
delete from ASGS_Mon_event;

select * from ASGS_Mon_event_group
select * from ASGS_Mon_event

-- it all starts with an event group
INSERT INTO ASGS_Mon_event_group (event_group_ts, storm_name, storm_number, advisory_id, final_product, site_id, state_type_id) VALUES (datetime(), 'Alpha', '1', '1', 'product', 0, 0);
INSERT INTO ASGS_Mon_event_group (event_group_ts, storm_name, storm_number, advisory_id, final_product, site_id, state_type_id) VALUES (datetime(), 'Beta', '2', '2', 'product', 1, 0);
INSERT INTO ASGS_Mon_event_group (event_group_ts, storm_name, storm_number, advisory_id, final_product, site_id, state_type_id) VALUES (datetime(), 'Beta', '2', '2', 'product', 1, 3);

-- then the events flow in
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 0, 'a host start file', 'Run start', 1, 0, 0);
UPDATE ASGS_Mon_site_lu SET state_type_id = 1; 

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '2', 'the process', 0, 'a host start file', 'Run start', 2, 0, 1);
UPDATE ASGS_Mon_site_lu SET state_type_id = 1; 

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 0, 'a host start file', 'Pre 1', 1, 1, 0);


INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 0, 'a host start file', 'NowCast', 1, 2, 0);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 0, 'a host start file', 'Pre 2', 1, 3, 0);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 0, 'a host start file', 'Forecast', 1, 4, 0);
INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 0, 'a host start file', 'Post run', 1, 5, 0);

INSERT INTO ASGS_Mon_event (event_ts, advisory_id, process, pct_complete, host_start_file, raw_data, event_group_id, event_type_id, site_id) VALUES (datetime(), '1', 'the process', 0, 'a start file', 'Run end', 1, 6, 0);
UPDATE Site_lu SET state_type_id = 5; 
*/

/*
-- this query gets the latest event groups across all sites
select sl.name, stl.name, eg.* 
from ASGS_Mon_event_group eg 
join ASGS_Mon_state_type_lu stl on stl.id=eg.state_type_id 
join ASGS_Mon_site_lu sl on sl.id=eg.site_id
inner join (select max(id) as id, site_id from ASGS_Mon_event_group group by site_id) AS megid on megid.id=eg.id and megid.site_id=eg.site_id;
 
-- this query gets the latest event from the latest event group across all sites
select sl.name, eg.storm_name, etl.name,  e.* 
from ASGS_Mon_event e 
join ASGS_Mon_site_lu sl on sl.id=e.site_id 
join ASGS_Mon_event_group eg on eg.id=e.event_group_id 
join ASGS_Mon_event_type_lu etl on etl.id=e.event_type_id
inner join (select max(id) as id from ASGS_Mon_event group by site_id) AS meid on meid.id=e.id
inner join (select max(id) as id, site_id from ASGS_Mon_event_group group by site_id) AS megid on megid.id=e.event_group_id and megid.site_id=e.site_id;

*/