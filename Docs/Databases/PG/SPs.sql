--- FUNCTION: public.get_event_msgs_by_group_json(integer)

-- DROP FUNCTION public.get_event_msgs_by_group_json(integer);

CREATE OR REPLACE FUNCTION public.get_event_msgs_by_group_json(
	_event_group_id integer
	)
    RETURNS TABLE(document jsonb) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

BEGIN
  -- gather the records and return them in json format
	RETURN QUERY
	
	SELECT jsonb_agg(r)
	FROM (
		SELECT (to_char(e.event_ts, 'Mon DD, HH24:MI:SS') || ' - ' || e.raw_data) AS event_summary
		FROM public."ASGS_Mon_event" e
		WHERE e.event_group_id=_event_group_id
		GROUP BY id 
		ORDER BY id DESC
		LIMIT 7) r;
END;

$BODY$;

ALTER FUNCTION public.get_event_msgs_by_group_json(integer)
    OWNER TO powen;

GRANT EXECUTE ON FUNCTION public.get_event_msgs_by_group_json(integer) TO powen;

GRANT EXECUTE ON FUNCTION public.get_event_msgs_by_group_json(integer) TO asgs;

GRANT EXECUTE ON FUNCTION public.get_event_msgs_by_group_json(integer) TO PUBLIC;

COMMENT ON FUNCTION public.get_event_msgs_by_group_json(integer)
    IS 'Returns a recordset (json) of the last 7 event messages for a group.';

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
		'instance_status', i.inst_state_type_id,

		'ranges', ARRAY[100],
		'measures', ARRAY[etl.pct_complete], 
		'markers', ARRAY[0],
		
		'eg_id', eg.id, 
		'group_state', stlgrp.description, 
		'group_state_id', stlgrp.id,
		
		'type', etl.name, 
		'event_operation', 'Storm ' || eg.storm_name || ': ' || etl.description || ' for advisory number ' || eg.advisory_id, 
		'event_raw_msgs', (SELECT public.get_event_msgs_by_group_json(eg.id)),
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
	WHERE inst_state_type_id < CASE WHEN end_ts + INTERVAL '1 day' > now() THEN inst_state_type_id+1 ELSE 9 END;

END;

$BODY$;

ALTER FUNCTION public.get_event_json()
    OWNER TO powen;

GRANT EXECUTE ON FUNCTION public.get_event_json() TO powen;

GRANT EXECUTE ON FUNCTION public.get_event_json() TO asgs;

GRANT EXECUTE ON FUNCTION public.get_event_json() TO PUBLIC;

COMMENT ON FUNCTION public.get_event_json()
    IS 'Returns a recordset (json) of the active cluster events.';

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
		'instance_name', i.instance_name,
		'instance_status', i.inst_state_type_id,
		'instance_start', i.start_ts,
		'process_id', i.process_id,
		'run_params', i.run_params,
		'title', s.name,
		'subtitle', s.cluster_name,
		'message', '',
		'ranges', ARRAY[100],
		'measures', ARRAY[0],
		'markers', ARRAY[0],
		'event_raw_msgs', (SELECT public.get_event_msgs_by_group_json(eg.id))
	))
	FROM
		"ASGS_Mon_instance" i
	JOIN "ASGS_Mon_site_lu" s ON s.id=i.site_id
	JOIN "ASGS_Mon_event_group" eg ON eg.instance_id=i.id
	INNER JOIN (SELECT max(id) AS id, instance_id from "ASGS_Mon_event_group" group by instance_id) AS megid ON megid.id=eg.id AND megid.instance_id=i.id	
	WHERE 
		inst_state_type_id < CASE WHEN end_ts + INTERVAL '1 day' > now() THEN inst_state_type_id+1 ELSE 9 END;
END;

$BODY$;

ALTER FUNCTION public.get_init_json()
    OWNER TO powen;

GRANT EXECUTE ON FUNCTION public.get_init_json() TO powen;

GRANT EXECUTE ON FUNCTION public.get_init_json() TO asgs;

GRANT EXECUTE ON FUNCTION public.get_init_json() TO PUBLIC;

COMMENT ON FUNCTION public.get_init_json()
    IS 'Returns a recordset (json) of the running ASGS cluster instances.';
