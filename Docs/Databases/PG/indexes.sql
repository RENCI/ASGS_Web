-- Index: ASGS_Mon_event_id_group_id_advisory_id

-- DROP INDEX public."ASGS_Mon_event_id_group_id_advisory_id";

CREATE INDEX "ASGS_Mon_event_id_group_id_advisory_id"
    ON public."ASGS_Mon_event" USING btree
    (event_group_id, advisory_id COLLATE pg_catalog."default")
    TABLESPACE pg_default;

    
-- Index: ASGS_Mon_event_group_instance_advisory

-- DROP INDEX public."ASGS_Mon_event_group_instance_advisory";

CREATE INDEX "ASGS_Mon_event_group_instance_advisory"
    ON public."ASGS_Mon_event_group" USING btree
    (instance_id, advisory_id COLLATE pg_catalog."default")
    TABLESPACE pg_default;

    
-- Index: ASGS_Mon_event_group_state_storm_advisory

-- DROP INDEX public."ASGS_Mon_event_group_state_storm_advisory";

CREATE INDEX "ASGS_Mon_event_group_state_storm_advisory"
    ON public."ASGS_Mon_event_group" USING btree
    (state_type_id, storm_name COLLATE pg_catalog."default", advisory_id COLLATE pg_catalog."default")
    TABLESPACE pg_default;

    
-- Index: ASGS_Mon_instance_site_process_instance_name

-- DROP INDEX public."ASGS_Mon_instance_site_process_instance_name";

CREATE INDEX "ASGS_Mon_instance_site_process_instance_name"
    ON public."ASGS_Mon_instance" USING btree
    (site_id, process_id, instance_name COLLATE pg_catalog."default")
    TABLESPACE pg_default;

    
-- Index: ASGS_Mon_instance_state_end_run

-- DROP INDEX public."ASGS_Mon_instance_state_end_run";

CREATE INDEX "ASGS_Mon_instance_state_end_run"
    ON public."ASGS_Mon_instance" USING btree
    (inst_state_type_id, end_ts, run_params COLLATE pg_catalog."default")
    TABLESPACE pg_default;

    
    