delete from ASGS_Mon_site_lu;
INSERT INTO ASGS_Mon_site_lu (id, name, description, cluster_name, tech_contact, phys_location, state_type_id) VALUES (0, 'RENCI', '', 'Hatteras', '', 'NC', 13);
INSERT INTO ASGS_Mon_site_lu (id, name, description, cluster_name, tech_contact, phys_location, state_type_id) VALUES (1, 'TACC', '', 'TACC cluster', '', 'TX', 13);
INSERT INTO ASGS_Mon_site_lu (id, name, description, cluster_name, tech_contact, phys_location, state_type_id) VALUES (2, 'LSU', '', 'LSU cluster', '', 'LA', 13);
INSERT INTO ASGS_Mon_site_lu (id, name, description, cluster_name, tech_contact, phys_location, state_type_id) VALUES (3, 'UCF', '', 'UCF cluster', '', 'FL', 13);
INSERT INTO ASGS_Mon_site_lu (id, name, description, cluster_name, tech_contact, phys_location, state_type_id) VALUES (4, 'George Mason', '', 'GM cluster', '', 'VA', 13);

delete from ASGS_Mon_event_type_lu;
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order, pct_complete) VALUES (0, 'RSTR', 'New run has started', 2, 0);
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order, pct_complete) VALUES (1, 'PRE1', 'Pre-run 1 operations in progress', 3, 20);
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order, pct_complete) VALUES (2, 'NOWC', 'NowCast operations in progress', 4, 40);
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order, pct_complete) VALUES (3, 'PRE2', 'Pre-run 2 operations in progress', 5, 60);
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order, pct_complete) VALUES (4, 'FORE', 'Forcast operations in progress', 6, 80);
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order, pct_complete) VALUES (5, 'POST', 'Post-run operations in progress', 7, 90);
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order, pct_complete) VALUES (6, 'REND', 'Run has ended', 8, 100);
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order, pct_complete) VALUES (7, 'STRT', 'Start submission of run', 0, 0);
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order, pct_complete) VALUES (8, 'HIND', 'Ready for next run', 1, 0);


delete from ASGS_Mon_state_type_lu;
INSERT INTO ASGS_Mon_state_type_lu (id, name, description, view_order) VALUES (0, 'INIT', 'Operational.', 0);
INSERT INTO ASGS_Mon_state_type_lu (id, name, description, view_order) VALUES (1, 'RUNN', 'Running.', 1);
INSERT INTO ASGS_Mon_state_type_lu (id, name, description, view_order) VALUES (2, 'PEND', 'Pending.', 2);
INSERT INTO ASGS_Mon_state_type_lu (id, name, description, view_order) VALUES (3, 'FAIL', 'Error.', 3);
INSERT INTO ASGS_Mon_state_type_lu (id, name, description, view_order) VALUES (4, 'WARN', 'Warning.', 4);
INSERT INTO ASGS_Mon_state_type_lu (id, name, description, view_order) VALUES (5, 'IDLE', 'Idle.', 5);
INSERT INTO ASGS_Mon_state_type_lu (id, name, description, view_order) VALUES (6, 'CMPL', 'Completing and event.', 6);
INSERT INTO ASGS_Mon_state_type_lu (id, name, description, view_order) VALUES (7, 'NONE', 'Starting or completing an event group.', 7);

-- use this to create python constants ready for cut/paste into the codebase
select d.const_name from 
(
        select id, '1' as 'theorder', 'CONST_SITE_' || UPPER(REPLACE(name, ' ', '') || ' = ' || id) as 'const_name' from ASGS_Mon_site_lu
        union
        select id, '2' as 'theorder', 'CONST_EVENT_TYPE_' ||  UPPER(REPLACE(name, ' ', '') || ' = ' || id) as 'const_name' from ASGS_Mon_event_type_lu
        union
        select id, '3' as 'theorder', 'CONST_STATE_' ||  UPPER(REPLACE(name, ' ', '') || ' = ' || id) as 'const_name' from ASGS_Mon_state_type_lu
) as d
order by d.theorder, d.id
