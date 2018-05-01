
select 'ASGS', e.*, m.*, s.name, et.name, mt.name
from ASGS_Mon_event e 
join ASGS_Mon_message m on m.id=e.message_id
join ASGS_Mon_message_type_lu mt on mt.id=m.message_type_id
join ASGS_Mon_site_lu s on s.id=e.site_id
join ASGS_Mon_event_type_lu et on et.id=e.event_type_id

/*
INSERT 
INTO ASGS_Mon_event (id, event_ts, nodes_in_use, nodes_available, raw_data, event_type_id, message_id, site_id) 
VALUES (0, date('now'), 100, 200, 'this is raw_data', 0, 0, 0);

INSERT 
INTO ASGS_Mon_message (id, advisory_id, storm_name, storm_number, message, other, message_type_id) 
VALUES (0, 'Advisory 1', 'TheBigOne', '1', 'This is a big storm', '', 0);
*/
