-- FUNCTION: public.get_event_msgs_by_group_json(integer)

-- DROP FUNCTION public.get_event_msgs_by_group_json(integer);

CREATE OR REPLACE FUNCTION public.get_event_msgs_by_group_json(
	_event_group_id integer)
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

GRANT EXECUTE ON FUNCTION public.get_event_msgs_by_group_json(integer) TO asgs;

COMMENT ON FUNCTION public.get_event_msgs_by_group_json(integer)
    IS 'Returns a recordset (json) of the last 5 event messages for a group.';

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

	SELECT json_agg(items)
	FROM
		(SELECT
			s.name AS title,
			i.id AS instance_id,
			i.process_id AS process_id,
			s.cluster_name AS cluster_name,
			istlu.description AS cluster_state, 
			istlu.id AS cluster_state_id, 
			i.inst_state_type_id AS instance_status,

			ARRAY[100] AS ranges,
			ARRAY[e.pct_complete] AS measures, 
			ARRAY[0] AS markers,

			eg.id AS eg_id, 
			stlgrp.description AS group_state,
			stlgrp.id AS group_state_id,

			etl.name AS type,
			'Storm ' || eg.storm_name || ': ' || etl.description || ' for advisory number ' || eg.advisory_id AS event_operation, 
			(SELECT public.get_event_msgs_by_group_json(eg.id)) AS event_raw_msgs,
			e.pct_complete AS pct_complete,
			to_char(e.event_ts, 'YYYY-MM-DD HH24:MI:SS') AS datetime,
			etl.description AS message,
			eg.storm_name AS storm, 
			eg.storm_number AS storm_number,
			eg.advisory_id AS advisory_number													  

			FROM "ASGS_Mon_instance" i
			JOIN "ASGS_Mon_site_lu" s ON s.id=i.site_id
			JOIN "ASGS_Mon_event_group" eg ON eg.instance_id=i.id
			JOIN "ASGS_Mon_event" e on e.event_group_id=eg.id
			JOIN "ASGS_Mon_event_type_lu" etl ON etl.id=e.event_type_id
			JOIN "ASGS_Mon_state_type_lu" stlgrp ON stlgrp.id=eg.state_type_id
			JOIN "ASGS_Mon_instance_state_type_lu" istlu ON istlu.id=i.inst_state_type_id
			INNER JOIN (SELECT max(id) AS id from "ASGS_Mon_event" group by event_group_id) AS meid ON meid.id=e.id
			INNER JOIN (SELECT max(id) AS id, instance_id from "ASGS_Mon_event_group" group by instance_id) AS megid ON megid.id=e.event_group_id AND megid.instance_id=i.id	
			WHERE inst_state_type_id < CASE WHEN end_ts + INTERVAL '1 day' > now() THEN inst_state_type_id+1 ELSE 9 END
			ORDER BY i.id DESC
		) items;

END;

$BODY$;

GRANT EXECUTE ON FUNCTION public.get_event_json() TO asgs;

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

	SELECT json_agg(items)
		FROM
			(SELECT
				i.id AS instance_id,
				i.instance_name AS instance_name,
				i.inst_state_type_id AS instance_status,
				i.start_ts AS instance_start,
				i.process_id AS process_id,
				i.run_params AS run_params,
				s.name AS title,
				s.cluster_name AS subtitle,
				'' AS message,
				ARRAY[100] AS ranges,
				ARRAY[0] AS measures,
				ARRAY[0] AS markers,
				(SELECT public.get_event_msgs_by_group_json(eg.id)) AS event_raw_msgs				
			FROM "ASGS_Mon_instance" i
			JOIN "ASGS_Mon_site_lu" s ON s.id=i.site_id
			JOIN "ASGS_Mon_event_group" eg ON eg.instance_id=i.id
			INNER JOIN (SELECT max(id) AS id, instance_id from "ASGS_Mon_event_group" group by instance_id) AS megid ON megid.id=eg.id AND megid.instance_id=i.id	
			WHERE inst_state_type_id < CASE WHEN end_ts + INTERVAL '1 day' > now() THEN inst_state_type_id+1 ELSE 9 END
			ORDER BY i.id DESC
			) AS items;
END;

$BODY$;

GRANT EXECUTE ON FUNCTION public.get_init_json() TO asgs;

COMMENT ON FUNCTION public.get_init_json()
    IS 'Returns a recordset (json) of the running ASGS cluster instances.';
    