--
-- Create model Event
--
CREATE TABLE "ASGS_Mon_event" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "event_ts" datetime NOT NULL, "nodes_in_use" integer NOT NULL, "nodes_available" integer NOT NULL, "raw_data" varchar(4000) NOT NULL);
--
-- Create model Event_type_lu
--
CREATE TABLE "ASGS_Mon_event_type_lu" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "name" varchar(50) NOT NULL, "description" varchar(100) NOT NULL);
--
-- Create model Message
--
CREATE TABLE "ASGS_Mon_message" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "advisory_id" varchar(50) NOT NULL, "storm_name" varchar(50) NOT NULL, "storm_number" varchar(50) NOT NULL, "message" varchar(250) NOT NULL, "other" varchar(250) NOT NULL);
--
-- Create model Message_type_lu
--
CREATE TABLE "ASGS_Mon_message_type_lu" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "name" varchar(50) NOT NULL, "description" varchar(100) NOT NULL);
--
-- Create model Site_lu
--
CREATE TABLE "ASGS_Mon_site_lu" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "name" varchar(50) NOT NULL, "description" varchar(100) NOT NULL, "cluster_name" varchar(100) NOT NULL, "nodes" integer NOT NULL, "tech_contact" varchar(100) NOT NULL, "location" varchar(100) NOT NULL);
--
-- Add field message_type to message
--
ALTER TABLE "ASGS_Mon_message" RENAME TO "ASGS_Mon_message__old";
CREATE TABLE "ASGS_Mon_message" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "advisory_id" varchar(50) NOT NULL, "storm_name" varchar(50) NOT NULL, "storm_number" varchar(50) NOT NULL, "message" varchar(250) NOT NULL, "other" varchar(250) NOT NULL, "message_type_id" integer NOT NULL REFERENCES "ASGS_Mon_message_type_lu" ("id") DEFERRABLE INITIALLY DEFERRED);
INSERT INTO "ASGS_Mon_message" ("id", "advisory_id", "storm_name", "storm_number", "message", "other", "message_type_id") SELECT "id", "advisory_id", "storm_name", "storm_number", "message", "other", NULL FROM "ASGS_Mon_message__old";
DROP TABLE "ASGS_Mon_message__old";
CREATE INDEX "ASGS_Mon_message_message_type_id_d7c0452c" ON "ASGS_Mon_message" ("message_type_id");
--
-- Add field event_type to event
--
ALTER TABLE "ASGS_Mon_event" RENAME TO "ASGS_Mon_event__old";
CREATE TABLE "ASGS_Mon_event" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "event_ts" datetime NOT NULL, "nodes_in_use" integer NOT NULL, "nodes_available" integer NOT NULL, "raw_data" varchar(4000) NOT NULL, "event_type_id" integer NOT NULL REFERENCES "ASGS_Mon_event_type_lu" ("id") DEFERRABLE INITIALLY DEFERRED);
INSERT INTO "ASGS_Mon_event" ("id", "event_ts", "nodes_in_use", "nodes_available", "raw_data", "event_type_id") SELECT "id", "event_ts", "nodes_in_use", "nodes_available", "raw_data", NULL FROM "ASGS_Mon_event__old";
DROP TABLE "ASGS_Mon_event__old";
CREATE INDEX "ASGS_Mon_event_event_type_id_3b972d2a" ON "ASGS_Mon_event" ("event_type_id");
--
-- Add field message to event
--
ALTER TABLE "ASGS_Mon_event" RENAME TO "ASGS_Mon_event__old";
CREATE TABLE "ASGS_Mon_event" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "event_ts" datetime NOT NULL, "nodes_in_use" integer NOT NULL, "nodes_available" integer NOT NULL, "raw_data" varchar(4000) NOT NULL, "event_type_id" integer NOT NULL REFERENCES "ASGS_Mon_event_type_lu" ("id") DEFERRABLE INITIALLY DEFERRED, "message_id" integer NOT NULL REFERENCES "ASGS_Mon_message" ("id") DEFERRABLE INITIALLY DEFERRED);
INSERT INTO "ASGS_Mon_event" ("id", "event_ts", "nodes_in_use", "nodes_available", "raw_data", "event_type_id", "message_id") SELECT "id", "event_ts", "nodes_in_use", "nodes_available", "raw_data", "event_type_id", NULL FROM "ASGS_Mon_event__old";
DROP TABLE "ASGS_Mon_event__old";
CREATE INDEX "ASGS_Mon_event_event_type_id_3b972d2a" ON "ASGS_Mon_event" ("event_type_id");
CREATE INDEX "ASGS_Mon_event_message_id_472c3a93" ON "ASGS_Mon_event" ("message_id");
--
-- Add field site to event
--
ALTER TABLE "ASGS_Mon_event" RENAME TO "ASGS_Mon_event__old";
CREATE TABLE "ASGS_Mon_event" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "event_ts" datetime NOT NULL, "nodes_in_use" integer NOT NULL, "nodes_available" integer NOT NULL, "raw_data" varchar(4000) NOT NULL, "event_type_id" integer NOT NULL REFERENCES "ASGS_Mon_event_type_lu" ("id") DEFERRABLE INITIALLY DEFERRED, "message_id" integer NOT NULL REFERENCES "ASGS_Mon_message" ("id") DEFERRABLE INITIALLY DEFERRED, "site_id" integer NOT NULL REFERENCES "ASGS_Mon_site_lu" ("id") DEFERRABLE INITIALLY DEFERRED);
INSERT INTO "ASGS_Mon_event" ("id", "event_ts", "nodes_in_use", "nodes_available", "raw_data", "event_type_id", "message_id", "site_id") SELECT "id", "event_ts", "nodes_in_use", "nodes_available", "raw_data", "event_type_id", "message_id", NULL FROM "ASGS_Mon_event__old";
DROP TABLE "ASGS_Mon_event__old";
CREATE INDEX "ASGS_Mon_event_event_type_id_3b972d2a" ON "ASGS_Mon_event" ("event_type_id");
CREATE INDEX "ASGS_Mon_event_message_id_472c3a93" ON "ASGS_Mon_event" ("message_id");
CREATE INDEX "ASGS_Mon_event_site_id_d67f18e8" ON "ASGS_Mon_event" ("site_id");
COMMIT;