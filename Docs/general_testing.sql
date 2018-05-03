
select e.id AS 'id', s.name AS 'site_name', mt.name AS 'message_type_name', e.event_ts AS 'ts', s.cluster_name AS 'cluster_name'
                                ,m.advisory_id AS 'advisory_id', m.message AS 'message_text', m.storm_name AS 'storm_name'
                                ,m.storm_number AS 'storm_number', m.other AS 'other', et.name AS 'event_type_name'
                                from ASGS_Mon_event e
                                join ASGS_Mon_message m on m.id=e.message_id
                                join ASGS_Mon_message_type_lu mt on mt.id=m.message_type_id 
                                join ASGS_Mon_site_lu s on s.id=e.site_id 
                                join ASGS_Mon_event_type_lu et on et.id=e.event_type_id
                                
/*
delete from ASGS_Mon_event;
delete from ASGS_Mon_message;

INSERT 
INTO ASGS_Mon_event (id, event_ts, nodes_in_use, nodes_available, raw_data, event_type_id, message_id, site_id) 
VALUES (0, datetime(), 100, 200, 'raw_data 0', 0, 0, 0);

INSERT 
INTO ASGS_Mon_event (id, event_ts, nodes_in_use, nodes_available, raw_data, event_type_id, message_id, site_id) 
VALUES (1, datetime(), 100, 200, 'raw_data 1', 0, 1, 1);

INSERT 
INTO ASGS_Mon_event (id, event_ts, nodes_in_use, nodes_available, raw_data, event_type_id, message_id, site_id) 
VALUES (2, datetime(), 100, 200, 'raw_data 2', 0, 2, 2);

INSERT 
INTO ASGS_Mon_event (id, event_ts, nodes_in_use, nodes_available, raw_data, event_type_id, message_id, site_id) 
VALUES (3, datetime(), 100, 200, 'raw_data 3', 0, 3, 3);

INSERT 
INTO ASGS_Mon_event (id, event_ts, nodes_in_use, nodes_available, raw_data, event_type_id, message_id, site_id) 
VALUES (4, datetime(), 100, 200, 'raw_data 4', 0, 4, 4);


INSERT 
INTO ASGS_Mon_message (id, advisory_id, storm_name, storm_number, message, other, message_type_id) 
VALUES (0, 'Advisory 0', 'Alpha', '0', 'This is storm Alpha', '', 0);

INSERT 
INTO ASGS_Mon_message (id, advisory_id, storm_name, storm_number, message, other, message_type_id) 
VALUES (1, 'Advisory 1', 'Bravo', '1', 'This is storm Bravo', '', 1);

INSERT 
INTO ASGS_Mon_message (id, advisory_id, storm_name, storm_number, message, other, message_type_id) 
VALUES (2, 'Advisory 2', 'Charlie', '2', 'This is storm Charlie', '', 2);

INSERT 
INTO ASGS_Mon_message (id, advisory_id, storm_name, storm_number, message, other, message_type_id) 
VALUES (3, 'Advisory 3', 'Delta', '3', 'This is storm Delta', '', 3);

INSERT 
INTO ASGS_Mon_message (id, advisory_id, storm_name, storm_number, message, other, message_type_id) 
VALUES (4, 'Advisory 4', 'Echo', '4', 'This is storm Echo', '', 4);
*/
