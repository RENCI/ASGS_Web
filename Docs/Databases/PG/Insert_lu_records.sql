delete from "ASGS_Mon_site_lu";
INSERT INTO "ASGS_Mon_site_lu" (id, name, description, cluster_name, tech_contact, phys_location) VALUES (0, 'RENCI', '', 'Hatteras', '', 'NC');
INSERT INTO "ASGS_Mon_site_lu" (id, name, description, cluster_name, tech_contact, phys_location) VALUES (1, 'TACC', '', 'TACC cluster', '', 'TX');
INSERT INTO "ASGS_Mon_site_lu" (id, name, description, cluster_name, tech_contact, phys_location) VALUES (2, 'LSU', '', 'LSU cluster', '', 'LA');
INSERT INTO "ASGS_Mon_site_lu" (id, name, description, cluster_name, tech_contact, phys_location) VALUES (3, 'UCF', '', 'UCF cluster', '', 'FL');
INSERT INTO "ASGS_Mon_site_lu" (id, name, description, cluster_name, tech_contact, phys_location) VALUES (4, 'George Mason', '', 'GM cluster', '', 'VA');
INSERT INTO "ASGS_Mon_site_lu" (id, name, description, cluster_name, tech_contact, phys_location) VALUES (5, 'Penguin', '', 'POD', '', 'Penguin');
INSERT INTO "ASGS_Mon_site_lu" (id, name, description, cluster_name, tech_contact, phys_location) VALUES (6, 'LONI', '', 'Queenbee', '', 'LONI');
INSERT INTO "ASGS_Mon_site_lu" (id, name, description, cluster_name, tech_contact, phys_location) VALUES (7, 'Seahorse', '', 'jason-desktop', 'Jason Fleming', 'Seahorse');
INSERT INTO "ASGS_Mon_site_lu" (id, name, description, cluster_name, tech_contact, phys_location) VALUES (8, 'QB2', '', 'Queenbee2', 'Matthew Bilskie', 'QB2');

delete from "ASGS_Mon_event_type_lu";
INSERT INTO "ASGS_Mon_event_type_lu" (id, name, description, pct_complete) VALUES (0, 'RSTR', 'New NC/FC cycle has started', 0);
INSERT INTO "ASGS_Mon_event_type_lu" (id, name, description, pct_complete) VALUES (1, 'PRE1', 'Nowcast preprocessing', 0);
INSERT INTO "ASGS_Mon_event_type_lu" (id, name, description, pct_complete) VALUES (2, 'NOWC', 'Nowcast in progress', 20);
INSERT INTO "ASGS_Mon_event_type_lu" (id, name, description, pct_complete) VALUES (3, 'PRE2', 'Forecast preprocessing', 40);
INSERT INTO "ASGS_Mon_event_type_lu" (id, name, description, pct_complete) VALUES (4, 'FORE', 'Forecast in progress', 60);
INSERT INTO "ASGS_Mon_event_type_lu" (id, name, description, pct_complete) VALUES (5, 'POST', 'Post-processing in progress', 90);
INSERT INTO "ASGS_Mon_event_type_lu" (id, name, description, pct_complete) VALUES (6, 'REND', 'NC/FC cycle has ended', 100);
INSERT INTO "ASGS_Mon_event_type_lu" (id, name, description, pct_complete) VALUES (7, 'STRT', 'ASGS initializing', 0);
INSERT INTO "ASGS_Mon_event_type_lu" (id, name, description, pct_complete) VALUES (8, 'HIND', 'Computing hindcast', 0);
INSERT INTO "ASGS_Mon_event_type_lu" (id, name, description, pct_complete) VALUES (9, 'EXIT', '"ASGS has exited"', 0);
INSERT INTO "ASGS_Mon_event_type_lu" (id, name, description, pct_complete) VALUES (10, 'FSTR', 'Start of forecast cycle', 40);
INSERT INTO "ASGS_Mon_event_type_lu" (id, name, description, pct_complete) VALUES (11, 'FEND', 'End of forecast cycle', 90);

delete from "ASGS_Mon_state_type_lu";
INSERT INTO "ASGS_Mon_state_type_lu" (id, name, description) VALUES (0, 'INIT', 'Initializing.');
INSERT INTO "ASGS_Mon_state_type_lu" (id, name, description) VALUES (1, 'RUNN', 'Running.');
INSERT INTO "ASGS_Mon_state_type_lu" (id, name, description) VALUES (2, 'PEND', 'Pending.');
INSERT INTO "ASGS_Mon_state_type_lu" (id, name, description) VALUES (3, 'FAIL', 'Error.');
INSERT INTO "ASGS_Mon_state_type_lu" (id, name, description) VALUES (4, 'WARN', 'Warning.');
INSERT INTO "ASGS_Mon_state_type_lu" (id, name, description) VALUES (5, 'IDLE', 'Idle.');
INSERT INTO "ASGS_Mon_state_type_lu" (id, name, description) VALUES (6, 'CMPL', 'Finished a major step.');
INSERT INTO "ASGS_Mon_state_type_lu" (id, name, description) VALUES (7, 'NONE', 'Unknown.');
INSERT INTO "ASGS_Mon_state_type_lu" (id, name, description) VALUES (8, 'WAIT', 'Waiting.');
INSERT INTO "ASGS_Mon_state_type_lu" (id, name, description) VALUES (9, 'EXIT', 'Exited.');
INSERT INTO "ASGS_Mon_state_type_lu" (id, name, description) VALUES (10, 'STALLED', 'Stalled.');

delete from "ASGS_Mon_instance_state_type_lu";
INSERT INTO "ASGS_Mon_instance_state_type_lu" (id, name, description) VALUES (0, 'INIT', 'Initializing.');
INSERT INTO "ASGS_Mon_instance_state_type_lu" (id, name, description) VALUES (1, 'RUNN', 'Running.');
INSERT INTO "ASGS_Mon_instance_state_type_lu" (id, name, description) VALUES (2, 'PEND', 'Pending.');
INSERT INTO "ASGS_Mon_instance_state_type_lu" (id, name, description) VALUES (3, 'FAIL', 'Error.');
INSERT INTO "ASGS_Mon_instance_state_type_lu" (id, name, description) VALUES (4, 'WARN', 'Warning.');
INSERT INTO "ASGS_Mon_instance_state_type_lu" (id, name, description) VALUES (5, 'IDLE', 'Idle.');
INSERT INTO "ASGS_Mon_instance_state_type_lu" (id, name, description) VALUES (6, 'CMPL', 'Finished a major step.');
INSERT INTO "ASGS_Mon_instance_state_type_lu" (id, name, description) VALUES (7, 'NONE', 'Unknown.');
INSERT INTO "ASGS_Mon_instance_state_type_lu" (id, name, description) VALUES (8, 'WAIT', 'Waiting.');
INSERT INTO "ASGS_Mon_instance_state_type_lu" (id, name, description) VALUES (9, 'EXIT', 'Exited.');
INSERT INTO "ASGS_Mon_instance_state_type_lu" (id, name, description) VALUES (10, 'STALLED', 'Stalled.');

-- use this to create python constants ready for cut/paste into the codebase
select d.const_name from 
(
        select id, '1' as theorder, 'CONST_SITE_' || UPPER(REPLACE(name, ' ', '') || ' = ' || id) as const_name from "ASGS_Mon_site_lu"
        union
        select id, '2' as theorder, 'CONST_EVENT_TYPE_' ||  UPPER(REPLACE(name, ' ', '') || ' = ' || id) as const_name from "ASGS_Mon_event_type_lu"
        union
        select id, '3' as theorder, 'CONST_STATE_' ||  UPPER(REPLACE(name, ' ', '') || ' = ' || id) as const_name from "ASGS_Mon_state_type_lu"
        union
        select id, '4' as theorder, 'CONST_INSTANCE_STATE_' ||  UPPER(REPLACE(name, ' ', '') || ' = ' || id) as const_name from "ASGS_Mon_instance_state_type_lu"
) as d
order by d.theorder, d.id
