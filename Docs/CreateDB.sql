BEGIN;
--
-- Create model Event
--
CREATE TABLE "ASGS_Mon_event" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "event_ts" datetime NOT NULL, "advisory_id" varchar(50) NOT NULL, "pct_complete" real NOT NULL, "host_start_file" varchar(1000) NOT NULL, "raw_data" varchar(4000) NOT NULL);
--
-- Create model Event_group
--
CREATE TABLE "ASGS_Mon_event_group" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "event_group_ts" datetime NOT NULL, "storm_name" varchar(50) NOT NULL, "storm_number" varchar(50) NOT NULL, "advisory_id" varchar(50) NOT NULL, "final_product" varchar(1000) NOT NULL);
--
-- Create model Event_type_lu
--
CREATE TABLE "ASGS_Mon_event_type_lu" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "name" varchar(50) NOT NULL, "description" varchar(100) NOT NULL, "view_order" integer NOT NULL);
--
-- Create model Site_lu
--
CREATE TABLE "ASGS_Mon_site_lu" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "name" varchar(50) NOT NULL, "description" varchar(100) NOT NULL, "cluster_name" varchar(100) NOT NULL, "tech_contact" varchar(100) NOT NULL, "phys_location" varchar(100) NOT NULL);
--
-- Create model State_type_lu
--
CREATE TABLE "ASGS_Mon_state_type_lu" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "name" varchar(50) NOT NULL, "description" varchar(100) NOT NULL, "view_order" integer NOT NULL);
--
-- Add field state_type to site_lu
--
ALTER TABLE "ASGS_Mon_site_lu" RENAME TO "ASGS_Mon_site_lu__old";
CREATE TABLE "ASGS_Mon_site_lu" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "name" varchar(50) NOT NULL, "description" varchar(100) NOT NULL, "cluster_name" varchar(100) NOT NULL, "tech_contact" varchar(100) NOT NULL, "phys_location" varchar(100) NOT NULL, "state_type_id" integer NOT NULL REFERENCES "ASGS_Mon_state_type_lu" ("id") DEFERRABLE INITIALLY DEFERRED);
INSERT INTO "ASGS_Mon_site_lu" ("id", "name", "description", "cluster_name", "tech_contact", "phys_location", "state_type_id") SELECT "id", "name", "description", "cluster_name", "tech_contact", "phys_location", NULL FROM "ASGS_Mon_site_lu__old";
DROP TABLE "ASGS_Mon_site_lu__old";
CREATE INDEX "ASGS_Mon_site_lu_state_type_id_5f028294" ON "ASGS_Mon_site_lu" ("state_type_id");
--
-- Add field site to event_group
--
ALTER TABLE "ASGS_Mon_event_group" RENAME TO "ASGS_Mon_event_group__old";
CREATE TABLE "ASGS_Mon_event_group" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "event_group_ts" datetime NOT NULL, "storm_name" varchar(50) NOT NULL, "storm_number" varchar(50) NOT NULL, "advisory_id" varchar(50) NOT NULL, "final_product" varchar(1000) NOT NULL, "site_id" integer NOT NULL REFERENCES "ASGS_Mon_site_lu" ("id") DEFERRABLE INITIALLY DEFERRED);
INSERT INTO "ASGS_Mon_event_group" ("id", "event_group_ts", "storm_name", "storm_number", "advisory_id", "final_product", "site_id") SELECT "id", "event_group_ts", "storm_name", "storm_number", "advisory_id", "final_product", NULL FROM "ASGS_Mon_event_group__old";
DROP TABLE "ASGS_Mon_event_group__old";
CREATE INDEX "ASGS_Mon_event_group_site_id_c09fa11b" ON "ASGS_Mon_event_group" ("site_id");
--
-- Add field state_type to event_group
--
ALTER TABLE "ASGS_Mon_event_group" RENAME TO "ASGS_Mon_event_group__old";
CREATE TABLE "ASGS_Mon_event_group" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "event_group_ts" datetime NOT NULL, "storm_name" varchar(50) NOT NULL, "storm_number" varchar(50) NOT NULL, "advisory_id" varchar(50) NOT NULL, "final_product" varchar(1000) NOT NULL, "site_id" integer NOT NULL REFERENCES "ASGS_Mon_site_lu" ("id") DEFERRABLE INITIALLY DEFERRED, "state_type_id" integer NOT NULL REFERENCES "ASGS_Mon_state_type_lu" ("id") DEFERRABLE INITIALLY DEFERRED);
INSERT INTO "ASGS_Mon_event_group" ("id", "event_group_ts", "storm_name", "storm_number", "advisory_id", "final_product", "site_id", "state_type_id") SELECT "id", "event_group_ts", "storm_name", "storm_number", "advisory_id", "final_product", "site_id", NULL FROM "ASGS_Mon_event_group__old";
DROP TABLE "ASGS_Mon_event_group__old";
CREATE INDEX "ASGS_Mon_event_group_site_id_c09fa11b" ON "ASGS_Mon_event_group" ("site_id");
CREATE INDEX "ASGS_Mon_event_group_state_type_id_60fd7afd" ON "ASGS_Mon_event_group" ("state_type_id");
--
-- Add field event_group to event
--
ALTER TABLE "ASGS_Mon_event" RENAME TO "ASGS_Mon_event__old";
CREATE TABLE "ASGS_Mon_event" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "event_ts" datetime NOT NULL, "advisory_id" varchar(50) NOT NULL, "pct_complete" real NOT NULL, "host_start_file" varchar(1000) NOT NULL, "raw_data" varchar(4000) NOT NULL, "event_group_id" integer NOT NULL REFERENCES "ASGS_Mon_event_group" ("id") DEFERRABLE INITIALLY DEFERRED);
INSERT INTO "ASGS_Mon_event" ("id", "event_ts", "advisory_id", "pct_complete", "host_start_file", "raw_data", "event_group_id") SELECT "id", "event_ts", "advisory_id", "pct_complete", "host_start_file", "raw_data", NULL FROM "ASGS_Mon_event__old";
DROP TABLE "ASGS_Mon_event__old";
CREATE INDEX "ASGS_Mon_event_event_group_id_df49e39a" ON "ASGS_Mon_event" ("event_group_id");
--
-- Add field event_type to event
--
ALTER TABLE "ASGS_Mon_event" RENAME TO "ASGS_Mon_event__old";
CREATE TABLE "ASGS_Mon_event" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "event_ts" datetime NOT NULL, "advisory_id" varchar(50) NOT NULL, "pct_complete" real NOT NULL, "host_start_file" varchar(1000) NOT NULL, "raw_data" varchar(4000) NOT NULL, "event_group_id" integer NOT NULL REFERENCES "ASGS_Mon_event_group" ("id") DEFERRABLE INITIALLY DEFERRED, "event_type_id" integer NOT NULL REFERENCES "ASGS_Mon_event_type_lu" ("id") DEFERRABLE INITIALLY DEFERRED);
INSERT INTO "ASGS_Mon_event" ("id", "event_ts", "advisory_id", "pct_complete", "host_start_file", "raw_data", "event_group_id", "event_type_id") SELECT "id", "event_ts", "advisory_id", "pct_complete", "host_start_file", "raw_data", "event_group_id", NULL FROM "ASGS_Mon_event__old";
DROP TABLE "ASGS_Mon_event__old";
CREATE INDEX "ASGS_Mon_event_event_group_id_df49e39a" ON "ASGS_Mon_event" ("event_group_id");
CREATE INDEX "ASGS_Mon_event_event_type_id_3b972d2a" ON "ASGS_Mon_event" ("event_type_id");
--
-- Add field site to event
--
ALTER TABLE "ASGS_Mon_event" RENAME TO "ASGS_Mon_event__old";
CREATE TABLE "ASGS_Mon_event" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "event_ts" datetime NOT NULL, "advisory_id" varchar(50) NOT NULL, "pct_complete" real NOT NULL, "host_start_file" varchar(1000) NOT NULL, "raw_data" varchar(4000) NOT NULL, "event_group_id" integer NOT NULL REFERENCES "ASGS_Mon_event_group" ("id") DEFERRABLE INITIALLY DEFERRED, "event_type_id" integer NOT NULL REFERENCES "ASGS_Mon_event_type_lu" ("id") DEFERRABLE INITIALLY DEFERRED, "site_id" integer NOT NULL REFERENCES "ASGS_Mon_site_lu" ("id") DEFERRABLE INITIALLY DEFERRED);
INSERT INTO "ASGS_Mon_event" ("id", "event_ts", "advisory_id", "pct_complete", "host_start_file", "raw_data", "event_group_id", "event_type_id", "site_id") SELECT "id", "event_ts", "advisory_id", "pct_complete", "host_start_file", "raw_data", "event_group_id", "event_type_id", NULL FROM "ASGS_Mon_event__old";
DROP TABLE "ASGS_Mon_event__old";
CREATE INDEX "ASGS_Mon_event_event_group_id_df49e39a" ON "ASGS_Mon_event" ("event_group_id");
CREATE INDEX "ASGS_Mon_event_event_type_id_3b972d2a" ON "ASGS_Mon_event" ("event_type_id");
CREATE INDEX "ASGS_Mon_event_site_id_d67f18e8" ON "ASGS_Mon_event" ("site_id");
COMMIT;