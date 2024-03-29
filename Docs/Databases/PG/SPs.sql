-- FUNCTION: public.get_chatmsgs_json(timestamp without time zone)

-- DROP FUNCTION public.get_chatmsgs_json(timestamp without time zone);

CREATE OR REPLACE FUNCTION public.get_chatmsgs_json(
	_since timestamp without time zone DEFAULT (
	now(
	) - '1 day'::interval))
    RETURNS TABLE(document jsonb) 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

BEGIN
  -- gather the records and return them in json format
	RETURN QUERY

	SELECT jsonb_agg(items)
		FROM
			(
				SELECT 
					username,
					to_char(msg_ts, 'YYYY/MM/DD HH24:MI:SS') AS msg_ts,
					message
				FROM
					public."ASGS_Mon_chat" 
				WHERE
					msg_ts >= _since
				ORDER BY msg_ts
			) AS items;
END;

$BODY$;

ALTER FUNCTION public.get_chatmsgs_json(timestamp without time zone)
    OWNER TO powen;

GRANT EXECUTE ON FUNCTION public.get_chatmsgs_json(timestamp without time zone) TO powen;

GRANT EXECUTE ON FUNCTION public.get_chatmsgs_json(timestamp without time zone) TO asgs;

GRANT EXECUTE ON FUNCTION public.get_chatmsgs_json(timestamp without time zone) TO PUBLIC;

COMMENT ON FUNCTION public.get_chatmsgs_json(timestamp without time zone)
    IS 'Returns a recordset (json) of the chat messages since the last update.';


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
			ARRAY[e.sub_pct_complete] AS markers,

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

-- FUNCTION: public.get_user_pref_json(text)

-- DROP FUNCTION public.get_user_pref_json(text);

CREATE OR REPLACE FUNCTION public.get_user_pref_json(
	_username text)
    RETURNS TABLE(document jsonb) 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

BEGIN
	-- if the record does not exist insert an empty one
	IF NOT EXISTS (SELECT 1 FROM public."ASGS_Mon_user_pref" WHERE username=_username) THEN
		INSERT INTO public."ASGS_Mon_user_pref" (username, home_site, filter_site) VALUES (_username, -1, '[]');
	END IF;

	RETURN QUERY
	
	-- get the preferences
	SELECT to_jsonb(item)
		FROM
			(
				SELECT 
					username,
					home_site,
					filter_site
				FROM
					public."ASGS_Mon_user_pref" 
				WHERE
					username = _username
			) AS item;
END;

$BODY$;

ALTER FUNCTION public.get_user_pref_json(text)
    OWNER TO powen;

GRANT EXECUTE ON FUNCTION public.get_user_pref_json(text) TO powen;

GRANT EXECUTE ON FUNCTION public.get_user_pref_json(text) TO asgs;

GRANT EXECUTE ON FUNCTION public.get_user_pref_json(text) TO PUBLIC;

COMMENT ON FUNCTION public.get_user_pref_json(text)
    IS 'Returns a recordset (json) of the user preferences.';

    
    
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
		AND i.inst_state_type_id NOT IN (3, 6, 7, 9, 10) AND eg.state_type_id NOT IN (3, 6, 7, 9, 10)
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
			AND i.inst_state_type_id NOT IN (3, 6, 7, 9, 10) AND eg.state_type_id NOT IN (3, 6, 7, 9, 10)
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


-- FUNCTION: public.insert_chatmsg(text, text)

-- DROP FUNCTION public.insert_chatmsg(text, text);

CREATE OR REPLACE FUNCTION public.insert_chatmsg(
	_username text,
	_msg text)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

BEGIN
	INSERT INTO public."ASGS_Mon_chat" (username, message, msg_ts) VALUES (_username, _msg, NOW());

	RETURN 0;
END;

$BODY$;

ALTER FUNCTION public.insert_chatmsg(text, text)
    OWNER TO powen;

GRANT EXECUTE ON FUNCTION public.insert_chatmsg(text, text) TO powen;

GRANT EXECUTE ON FUNCTION public.insert_chatmsg(text, text) TO asgs;

GRANT EXECUTE ON FUNCTION public.insert_chatmsg(text, text) TO PUBLIC;

COMMENT ON FUNCTION public.insert_chatmsg(text, text)
    IS 'Inserts a chat message.';
 
    
-- FUNCTION: public.insert_user_pref(text, integer, jsonb)

-- DROP FUNCTION public.insert_user_pref(text, integer, jsonb);

CREATE OR REPLACE FUNCTION public.insert_user_pref(
	_username text,
	_home_site integer,
	_filter_site jsonb)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
BEGIN
	IF EXISTS (SELECT 1 FROM public."ASGS_Mon_user_pref" WHERE username=_username) THEN
		UPDATE public."ASGS_Mon_user_pref" SET home_site = _home_site, filter_site = _filter_site WHERE username=_username;
	ELSE
		INSERT INTO public."ASGS_Mon_user_pref" (username, home_site, filter_site) VALUES (_username, _home_site, _filter_site);
	END IF;

	RETURN 0;
END;

$BODY$;

ALTER FUNCTION public.insert_user_pref(text, integer, jsonb)
    OWNER TO powen;

GRANT EXECUTE ON FUNCTION public.insert_user_pref(text, integer, jsonb) TO powen;

GRANT EXECUTE ON FUNCTION public.insert_user_pref(text, integer, jsonb) TO asgs;

GRANT EXECUTE ON FUNCTION public.insert_user_pref(text, integer, jsonb) TO PUBLIC;

COMMENT ON FUNCTION public.insert_user_pref(text, integer, jsonb)
    IS 'Updates or inserts a users preferences.';


-- FUNCTION: public.pg_stat_statements(boolean)

-- DROP FUNCTION public.pg_stat_statements(boolean);

CREATE OR REPLACE FUNCTION public.pg_stat_statements(
	showtext boolean,
	OUT userid oid,
	OUT dbid oid,
	OUT queryid bigint,
	OUT query text,
	OUT calls bigint,
	OUT total_time double precision,
	OUT min_time double precision,
	OUT max_time double precision,
	OUT mean_time double precision,
	OUT stddev_time double precision,
	OUT rows bigint,
	OUT shared_blks_hit bigint,
	OUT shared_blks_read bigint,
	OUT shared_blks_dirtied bigint,
	OUT shared_blks_written bigint,
	OUT local_blks_hit bigint,
	OUT local_blks_read bigint,
	OUT local_blks_dirtied bigint,
	OUT local_blks_written bigint,
	OUT temp_blks_read bigint,
	OUT temp_blks_written bigint,
	OUT blk_read_time double precision,
	OUT blk_write_time double precision)
    RETURNS SETOF record 
    LANGUAGE 'c'

    COST 1
    VOLATILE STRICT PARALLEL SAFE
    ROWS 1000
AS '$libdir/pg_stat_statements', 'pg_stat_statements_1_3'
;

ALTER FUNCTION public.pg_stat_statements(boolean)
    OWNER TO postgres;

    
    
-- FUNCTION: public.pg_stat_statements_reset()

-- DROP FUNCTION public.pg_stat_statements_reset();

CREATE OR REPLACE FUNCTION public.pg_stat_statements_reset(
	)
    RETURNS void
    LANGUAGE 'c'

    COST 1
    VOLATILE PARALLEL SAFE
AS '$libdir/pg_stat_statements', 'pg_stat_statements_reset'
;

ALTER FUNCTION public.pg_stat_statements_reset()
    OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.pg_stat_statements_reset() TO postgres;

GRANT EXECUTE ON FUNCTION public.pg_stat_statements_reset() TO pg_read_all_stats;

REVOKE ALL ON FUNCTION public.pg_stat_statements_reset() FROM PUBLIC;
    