-- FUNCTION: public.get_init_json()

-- DROP FUNCTION public.get_init_json();

CREATE OR REPLACE FUNCTION public.get_init_json(
	)
    RETURNS TABLE(document json) 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

BEGIN
  -- gather the records and return them in json format
	RETURN QUERY

	SELECT json_agg(json_build_object
	(
		'instance_id', i.id,
		'process_id', i.process_id,
		'run_params', i.run_params,
		'title', s.name,
		'subtitle', s.cluster_name,
		'message', '',
		'ranges', ARRAY[100],
		'measures', ARRAY[0],
		'markers', ARRAY[0]
	))
	FROM
		"ASGS_Mon_instance" i
	JOIN
		"ASGS_Mon_site_lu" s ON s.id=i.site_id
	;
END;

$BODY$;

ALTER FUNCTION public.get_init_json()
    OWNER TO asgstest;

GRANT EXECUTE ON FUNCTION public.get_init_json() TO asgstest;

GRANT EXECUTE ON FUNCTION public.get_init_json() TO PUBLIC;

COMMENT ON FUNCTION public.get_init_json()
    IS 'Returns a recordset (json) of the running ASGS cluster instances.';

    
-- FUNCTION: public.get_event_json()

-- DROP FUNCTION public.get_event_json();

CREATE OR REPLACE FUNCTION public.get_event_json(
	)
    RETURNS TABLE(document json) 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

BEGIN
  -- gather the records and return them in json format
	RETURN QUERY

	SELECT json_agg(json_build_object 
	(
		'title', s.name,
		'instance_id', i.id,
		'process_id', i.process_id,
		'cluster_name', s.cluster_name,
		'cluster_state', istlu.description, 
		'cluster_state_id', istlu.id, 

		'ranges', ARRAY[100],
		'measures', ARRAY[etl.pct_complete], 
		'markers', ARRAY[0],
		
		'eg_id', eg.id, 
		'group_state', stlgrp.description, 
		'group_state_id', stlgrp.id,
		
		'type', etl.name, 
		'event_message', 'Storm ' || etl.description || ': ' || etl.description || ' for advisory number ' || eg.advisory_id, 
		'pct_complete', e.pct_complete, 
		'datetime', to_char(e.event_ts, 'YYYY-MM-DD HH24:MI:SS'), 
		'message', etl.description,
		'storm', eg.storm_name, 
		'storm_number', eg.storm_number, 
		'advisory_number', eg.advisory_id
	))
	FROM "ASGS_Mon_instance" i
	JOIN "ASGS_Mon_site_lu" s ON s.id=i.site_id
	JOIN "ASGS_Mon_event_group" eg ON eg.instance_id=i.id
	JOIN "ASGS_Mon_event" e on e.event_group_id=eg.id
	JOIN "ASGS_Mon_event_type_lu" etl ON etl.id=e.event_type_id
	JOIN "ASGS_Mon_state_type_lu" stlgrp ON stlgrp.id=eg.state_type_id
	JOIN "ASGS_Mon_instance_state_type_lu" istlu ON istlu.id=i.inst_state_type_id
	INNER JOIN (SELECT max(id) AS id from "ASGS_Mon_event" group by event_group_id) AS meid ON meid.id=e.id
	INNER JOIN (SELECT max(id) AS id, instance_id from "ASGS_Mon_event_group" group by instance_id) AS megid ON megid.id=e.event_group_id AND megid.instance_id=i.id	
	;
END;

$BODY$;

ALTER FUNCTION public.get_event_json()
    OWNER TO asgstest;

GRANT EXECUTE ON FUNCTION public.get_event_json() TO asgstest;

GRANT EXECUTE ON FUNCTION public.get_event_json() TO PUBLIC;

COMMENT ON FUNCTION public.get_event_json()
    IS 'Returns a recordset (json) of the active cluster events.';
