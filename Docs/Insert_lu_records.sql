delete from ASGS_Mon_site_lu
INSERT INTO ASGS_Mon_site_lu (id, name, description, cluster_name, tech_contact, phys_location, state_type_id) VALUES (0, 'RENCI', '', 'Hatteras', '', 'NC', 13);
INSERT INTO ASGS_Mon_site_lu (id, name, description, cluster_name, tech_contact, phys_location, state_type_id) VALUES (1, 'TACC', '', 'TACC cluster', '', 'TX', 13);
INSERT INTO ASGS_Mon_site_lu (id, name, description, cluster_name, tech_contact, phys_location, state_type_id) VALUES (2, 'LSU', '', 'LSU cluster', '', 'LA', 13);
INSERT INTO ASGS_Mon_site_lu (id, name, description, cluster_name, tech_contact, phys_location, state_type_id) VALUES (3, 'UCF', '', 'UCF cluster', '', 'FL', 13);
INSERT INTO ASGS_Mon_site_lu (id, name, description, cluster_name, tech_contact, phys_location, state_type_id) VALUES (4, 'GM', '', 'GM cluster', '', 'VA', 13);

delete from ASGS_Mon_event_type_lu
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order) VALUES (0, 'RSRT', 'New run has started.', 0);
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order) VALUES (1, 'PRE1', 'Pre-run 1 operations in progress.', 1);
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order) VALUES (2, 'NOWC', 'NowCast operations in progress.', 2);
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order) VALUES (3, 'PRE2', 'Pre-run 1 operations in progress.', 3);
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order) VALUES (4, 'FDRC', 'Forcast operations in progress.', 4);
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order) VALUES (5, 'POST', 'post-run operations in progress.', 5);
INSERT INTO ASGS_Mon_event_type_lu (id, name, description, view_order) VALUES (6, 'REND', 'Run has ended', 6);

delete from ASGS_Mon_state_type_lu;
INSERT INTO ASGS_Mon_state_type_lu (id, name, description, view_order) VALUES (0, 'STRT', 'Cluster is operational.', 0);
INSERT INTO ASGS_Mon_state_type_lu (id, name, description, view_order) VALUES (1, 'RUNN', 'Cluster run in progress.', 1);
INSERT INTO ASGS_Mon_state_type_lu (id, name, description, view_order) VALUES (2, 'PEND', 'Cluster is pending a run.', 2);
INSERT INTO ASGS_Mon_state_type_lu (id, name, description, view_order) VALUES (3, 'FAIL', 'Cluster has encountered an error.', 3);
INSERT INTO ASGS_Mon_state_type_lu (id, name, description, view_order) VALUES (4, 'WARN', 'Cluster has posted a warning message.', 4);
INSERT INTO ASGS_Mon_state_type_lu (id, name, description, view_order) VALUES (5, 'IDLE', 'Cluster is idle.', 5);
INSERT INTO ASGS_Mon_state_type_lu (id, name, description, view_order) VALUES (6, 'EXIT', 'Cluster is shutdown.', 6);