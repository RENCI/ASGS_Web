select i.id AS 'id', s.name AS 'site_name', s.cluster_name AS 'cluster_name'
from ASGS_Mon_instance i
join ASGS_Mon_site_lu s ON s.id=i.site_id
where i.inst_state_type_id = 1

select e.id AS 'id', s.name AS 'site_name', eg.id AS 'eg_id', etl.name AS 'event_type_name', e.event_ts AS 'ts', s.cluster_name AS 'cluster_name', eg.advisory_id AS 'advisory_id'
      , etl.description AS 'message_text', etl.pct_complete AS 'def_pct_complete', e.pct_complete AS 'pct_complete', stlgrp.description AS 'group_state', stlgrp.id AS 'group_state_id', istlu.description AS 'cluster_state'
      , istlu.id AS 'cluster_state_id', eg.storm_name AS 'storm_name', eg.storm_number AS 'storm_number', etl.name AS 'event_type_name', e.process as 'process'             
      
--select *          
from ASGS_Mon_instance i
join ASGS_Mon_site_lu s ON s.id=i.site_id
join ASGS_Mon_event_group eg ON eg.instance_id=i.id
join ASGS_Mon_event e on e.event_group_id=eg.id
join ASGS_Mon_event_type_lu etl ON etl.id=e.event_type_id
join ASGS_Mon_state_type_lu stlgrp ON stlgrp.id=eg.state_type_id
join ASGS_Mon_instance_state_type_lu istlu ON istlu.id=i.inst_state_type_id
inner join (select max(id) AS id from ASGS_Mon_event group by event_group_id) AS meid ON meid.id=e.id
inner join (select max(id) AS id, instance_id from ASGS_Mon_event_group group by instance_id) AS megid ON megid.id=e.event_group_id AND megid.instance_id=i.id
