-- FUNCTION: public.get_config_detail_json(integer)

-- DROP FUNCTION public.get_config_detail_json(integer);

CREATE OR REPLACE FUNCTION public.get_config_detail_json(
	_instance_id integer)
    RETURNS TABLE(document json) 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

BEGIN
  -- gather the records and return them in json format
        RETURN QUERY

        SELECT to_json(r)
        FROM (
                SELECT c.instance_id, i.instance_name, TO_CHAR(i.start_ts, 'Mon DD, HH24:MI:SS') AS start_ts, c.adcirc_config, REPLACE(REPLACE(REPLACE(c.asgs_config, '\"', '&quot;'), '''', '&apos;'), '\n', '</br>') AS asgs_config
                FROM public."ASGS_Mon_instance_config" c
                JOIN "ASGS_Mon_instance" i ON i.id=c.instance_id
                WHERE c.instance_id=_instance_id
                GROUP BY c.instance_id, i.instance_name, i.start_ts, c.adcirc_config, c.asgs_config
                ORDER BY c.instance_id DESC
                LIMIT 7) r;
END;

$BODY$;

ALTER FUNCTION public.get_config_detail_json(integer)
    OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.get_config_detail_json(integer) TO asgs;

GRANT EXECUTE ON FUNCTION public.get_config_detail_json(integer) TO postgres;

GRANT EXECUTE ON FUNCTION public.get_config_detail_json(integer) TO PUBLIC;



-- FUNCTION: public.get_config_list_json()

-- DROP FUNCTION public.get_config_list_json();

CREATE OR REPLACE FUNCTION public.get_config_list_json(
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
                SELECT c.instance_id, i.instance_name, TO_CHAR(i.start_ts, 'Mon DD, HH24:MI:SS') AS start_ts                                
                FROM public."ASGS_Mon_instance_config" c
                JOIN "ASGS_Mon_instance" i ON i.id=c.instance_id
                GROUP BY c.instance_id, i.instance_name, i.start_ts                                
                ORDER BY c.instance_id DESC
                LIMIT 7) r;
END;            

$BODY$;

ALTER FUNCTION public.get_config_list_json()
    OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.get_config_list_json() TO asgs;

GRANT EXECUTE ON FUNCTION public.get_config_list_json() TO postgres;

GRANT EXECUTE ON FUNCTION public.get_config_list_json() TO PUBLIC;




-- FUNCTION: public.get_event_json(boolean, date, text, text)

-- DROP FUNCTION public.get_event_json(boolean, date, text, text);

CREATE OR REPLACE FUNCTION public.get_event_json(
	_viewactive boolean,
	_since date DEFAULT to_date(
	'01/01/1970'::text,
	'MM/DD/YYYY'::text),
	_inactives text DEFAULT ''::text,
	_sites text DEFAULT ''::text)
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
			ARRAY[e.pct_complete] AS markers,

			eg.id AS eg_id, 
			stlgrp.description AS group_state,
			stlgrp.id AS group_state_id,

			etl.name AS type,
			'Storm ' || eg.storm_name || ': ' || etl.description || ' for advisory number ' || eg.advisory_id AS event_operation, 
			(SELECT public.get_event_msgs_by_group_json(eg.id, eg.advisory_id)) AS event_raw_msgs,
			e.pct_complete AS pct_complete,
			to_char(e.event_ts, 'YYYY-MM-DD HH24:MI:SS') AS datetime,
			etl.description AS message,
			eg.storm_name AS storm, 
			eg.storm_number AS storm_number,
			eg.advisory_id AS advisory_number													  

			FROM "ASGS_Mon_instance" i
			JOIN "ASGS_Mon_site_lu" s ON s.id=i.site_id
			JOIN "ASGS_Mon_event_group" eg ON eg.instance_id=i.id
			JOIN "ASGS_Mon_event" e ON e.event_group_id=eg.id
			JOIN "ASGS_Mon_event_type_lu" etl ON etl.id=e.event_type_id
			JOIN "ASGS_Mon_state_type_lu" stlgrp ON stlgrp.id=eg.state_type_id
			JOIN "ASGS_Mon_instance_state_type_lu" istlu ON istlu.id=i.inst_state_type_id
--			INNER JOIN (SELECT max(id) AS id, advisory_id FROM "ASGS_Mon_event" GROUP BY event_group_id, advisory_id) AS meid ON meid.id=e.id AND meid.advisory_id=eg.advisory_id
--			INNER JOIN LATERAL (SELECT max(id) AS id, e1.advisory_id FROM "ASGS_Mon_event" e1 where e1.event_group_id=e.event_group_id and e1.advisory_id=eg.advisory_id group by e1.event_group_id, e1.advisory_id) AS meid ON meid.id=e.id AND meid.advisory_id=eg.advisory_id
--			INNER JOIN (SELECT max(id) AS id, instance_id, advisory_id FROM "ASGS_Mon_event_group" GROUP BY instance_id, advisory_id) AS megid ON megid.id=eg.id AND megid.instance_id=i.id AND megid.advisory_id=eg.advisory_id	
--			INNER JOIN LATERAL (SELECT max(id) AS id, instance_id, advisory_id FROM "ASGS_Mon_event_group" eg2 where eg2.instance_id=eg.instance_id and eg2.advisory_id=eg.advisory_id GROUP BY instance_id, advisory_id) AS megid ON megid.id=eg.id AND megid.instance_id=i.id AND megid.advisory_id=eg.advisory_id	
			INNER JOIN LATERAL (SELECT id, e1.advisory_id FROM "ASGS_Mon_event" e1 where e1.event_group_id=eg.id and e1.advisory_id=eg.advisory_id ORDER BY 1 DESC LIMIT 1) AS meid ON meid.id=e.id AND meid.advisory_id=eg.advisory_id
			WHERE														
				(
					CASE WHEN _viewActive = true
						THEN i.inst_state_type_id IN (0, 1, 2, 4, 5, 8) AND eg.state_type_id IN (0, 1, 2, 4, 5, 8)
					END OR		
					CASE WHEN _inactives <> ''
						THEN i.inst_state_type_id = ANY (_inactives::int[]) OR eg.state_type_id = ANY (_inactives::int[])
					END
				) 
				AND
				(
					CASE WHEN _sites <> ''
						THEN s.id = ANY (_sites::int[])
						ELSE s.id = s.id
					END
				)
				AND	i.start_ts >= _since
				AND eg.advisory_id <> '0'
			ORDER BY i.start_ts DESC, eg.advisory_id DESC
			--LIMIT 50
		) items;

END;

$BODY$;

ALTER FUNCTION public.get_event_json(boolean, date, text, text)
    OWNER TO powen;

GRANT EXECUTE ON FUNCTION public.get_event_json(boolean, date, text, text) TO powen;

GRANT EXECUTE ON FUNCTION public.get_event_json(boolean, date, text, text) TO asgs;

GRANT EXECUTE ON FUNCTION public.get_event_json(boolean, date, text, text) TO PUBLIC;

COMMENT ON FUNCTION public.get_event_json(boolean, date, text, text)
    IS 'Returns a recordset (json) of the active cluster events.';

    
    
-- FUNCTION: public.get_event_msgs_by_group_json(integer, character varying)

-- DROP FUNCTION public.get_event_msgs_by_group_json(integer, character varying);

CREATE OR REPLACE FUNCTION public.get_event_msgs_by_group_json(
	_event_group_id integer,
	_advisory_id character varying)
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
		SELECT to_char(e.event_ts, 'Mon DD, HH24:MI:SS') || ' - ' || e.raw_data AS event_summary	
		FROM public."ASGS_Mon_event" e
		WHERE e.event_group_id=_event_group_id AND e.advisory_id=_advisory_id
		GROUP BY id 
		ORDER BY id DESC
		LIMIT 7) r;
END;

$BODY$;

ALTER FUNCTION public.get_event_msgs_by_group_json(integer, character varying)
    OWNER TO powen;

GRANT EXECUTE ON FUNCTION public.get_event_msgs_by_group_json(integer, character varying) TO powen;

GRANT EXECUTE ON FUNCTION public.get_event_msgs_by_group_json(integer, character varying) TO asgs;

GRANT EXECUTE ON FUNCTION public.get_event_msgs_by_group_json(integer, character varying) TO PUBLIC;

COMMENT ON FUNCTION public.get_event_msgs_by_group_json(integer, character varying)
    IS 'Returns a recordset (json) of the last 5 event messages for a group.';

    
    
-- FUNCTION: public.get_init_json(boolean, date, text, text)

-- DROP FUNCTION public.get_init_json(boolean, date, text, text);

CREATE OR REPLACE FUNCTION public.get_init_json(
	_viewactive boolean,
	_since date DEFAULT to_date(
	'01/01/1970'::text,
	'MM/DD/YYYY'::text),
	_inactives text DEFAULT ''::text,
	_sites text DEFAULT ''::text)
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
			 	eg.advisory_id AS advisory_number,
			 	eg.id AS eg_id,
				'' AS message,
				ARRAY[100] AS ranges,
				ARRAY[0] AS measures,
				ARRAY[100] AS markers,
				(SELECT public.get_event_msgs_by_group_json(eg.id, eg.advisory_id)) AS event_raw_msgs
			FROM "ASGS_Mon_instance" i
			JOIN "ASGS_Mon_site_lu" s ON s.id=i.site_id
			JOIN "ASGS_Mon_event_group" eg ON eg.instance_id=i.id
			JOIN "ASGS_Mon_event" e ON e.event_group_id=eg.id
			JOIN "ASGS_Mon_event_type_lu" etl ON etl.id=e.event_type_id
			JOIN "ASGS_Mon_state_type_lu" stlgrp ON stlgrp.id=eg.state_type_id
			JOIN "ASGS_Mon_instance_state_type_lu" istlu ON istlu.id=i.inst_state_type_id
--			INNER JOIN (SELECT max(id) AS id, advisory_id FROM "ASGS_Mon_event" GROUP BY event_group_id, advisory_id) AS meid ON meid.id=e.id AND meid.advisory_id=eg.advisory_id
--			INNER JOIN LATERAL (SELECT max(id) AS id, e1.advisory_id FROM "ASGS_Mon_event" e1 where e1.event_group_id=e.event_group_id and e1.advisory_id=eg.advisory_id group by e1.event_group_id, e1.advisory_id) AS meid ON meid.id=e.id AND meid.advisory_id=eg.advisory_id
--			INNER JOIN (SELECT max(id) AS id, instance_id, advisory_id FROM "ASGS_Mon_event_group" GROUP BY instance_id, advisory_id) AS megid ON megid.id=eg.id AND megid.instance_id=i.id AND megid.advisory_id=eg.advisory_id	
--			INNER JOIN LATERAL (SELECT max(id) AS id, instance_id, advisory_id FROM "ASGS_Mon_event_group" eg2 where eg2.instance_id=eg.instance_id and eg2.advisory_id=eg.advisory_id GROUP BY instance_id, advisory_id) AS megid ON megid.id=eg.id AND megid.instance_id=i.id AND megid.advisory_id=eg.advisory_id	
			INNER JOIN LATERAL (SELECT id, e1.advisory_id FROM "ASGS_Mon_event" e1 where e1.event_group_id=eg.id and e1.advisory_id=eg.advisory_id ORDER BY 1 DESC LIMIT 1) AS meid ON meid.id=e.id AND meid.advisory_id=eg.advisory_id
			WHERE
				(
					CASE WHEN _viewActive = true
						THEN i.inst_state_type_id IN (0, 1, 2, 4, 5, 8) AND eg.state_type_id IN (0, 1, 2, 4, 5, 8)
					END OR		
					CASE WHEN _inactives <> ''
						THEN i.inst_state_type_id = ANY (_inactives::int[]) OR eg.state_type_id = ANY (_inactives::int[])
					END
				) 
				AND
				(
					CASE WHEN _sites <> ''
						THEN s.id = ANY (_sites::int[])
						ELSE s.id = s.id
					END
				)
				AND	i.start_ts >= _since
				AND eg.advisory_id <> '0'
			ORDER BY i.start_ts DESC, eg.advisory_id DESC
			--LIMIT 50
			) AS items;
END;

$BODY$;

ALTER FUNCTION public.get_init_json(boolean, date, text, text)
    OWNER TO powen;

GRANT EXECUTE ON FUNCTION public.get_init_json(boolean, date, text, text) TO powen;

GRANT EXECUTE ON FUNCTION public.get_init_json(boolean, date, text, text) TO asgs;

GRANT EXECUTE ON FUNCTION public.get_init_json(boolean, date, text, text) TO PUBLIC;

COMMENT ON FUNCTION public.get_init_json(boolean, date, text, text)
    IS 'Returns a recordset (json) of the running ASGS cluster instances.';

    
    
-- FUNCTION: public.handle_stalled_event_groups()

-- DROP FUNCTION public.handle_stalled_event_groups();

CREATE OR REPLACE FUNCTION public.handle_stalled_event_groups(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
	DECLARE affected_rows integer;	
BEGIN
	/*
	-- SQL that details the records to be updated
	SELECT DISTINCT eg.id, eg.instance_id, e.advisory_id, i.site_id, e.event_ts,  now() - interval '3 hours' AS expiration, i.inst_state_type_id, eg.state_type_id, i.instance_name, i.run_params
	FROM "ASGS_Mon_event_group" eg 
	JOIN "ASGS_Mon_event" e ON e.event_group_id = eg.id
	JOIN "ASGS_Mon_instance" i ON i.id=eg.instance_id
	WHERE 
		e.event_ts = (SELECT MAX(e1.event_ts) FROM "ASGS_Mon_event" e1 WHERE e1.event_group_id = eg.id AND e1.advisory_id = eg.advisory_id)
		AND i.inst_state_type_id NOT IN (0, 3, 6, 7, 9, 10) AND eg.state_type_id NOT IN (0, 3, 6, 7, 9, 10)
		AND e.event_ts < now() - interval '3 hours'
		AND eg.advisory_id <> '0'
	ORDER BY 1,2,3,4
	*/

	-- do the update
	UPDATE "ASGS_Mon_event_group" SET state_type_id=10 WHERE ID IN 
	(
		SELECT DISTINCT eg.id
		FROM "ASGS_Mon_event_group" eg 
		JOIN "ASGS_Mon_event" e ON e.event_group_id = eg.id
		JOIN "ASGS_Mon_instance" i ON i.id=eg.instance_id
		WHERE 
			e.event_ts = (SELECT MAX(e1.event_ts) FROM "ASGS_Mon_event" e1 WHERE e1.event_group_id = eg.id AND e1.advisory_id = eg.advisory_id)
			AND i.inst_state_type_id NOT IN (0, 3, 6, 7, 9, 10) AND eg.state_type_id NOT IN (0, 3, 6, 7, 9, 10)
			AND e.event_ts < now() - interval '3 hours'
			AND eg.advisory_id <> '0'
	);
	
	-- get the number of rows updated
	GET DIAGNOSTICS affected_rows = ROW_COUNT;	
	
	-- return the count back to the caller
	RETURN affected_rows;
END;

$BODY$;

ALTER FUNCTION public.handle_stalled_event_groups()
    OWNER TO powen;

GRANT EXECUTE ON FUNCTION public.handle_stalled_event_groups() TO powen;

GRANT EXECUTE ON FUNCTION public.handle_stalled_event_groups() TO asgs;

GRANT EXECUTE ON FUNCTION public.handle_stalled_event_groups() TO PUBLIC;

COMMENT ON FUNCTION public.handle_stalled_event_groups()
    IS 'Updates event groups to a stalled status when no event messages have been received in 3 or more hours.';
    