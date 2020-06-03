BEGIN TRANSACTION;

CREATE SCHEMA local ;
CREATE SCHEMA history ;

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public ;
CREATE EXTENSION IF NOT EXISTS ltree WITH SCHEMA public ;
CREATE EXTENSION IF NOT EXISTS temporal_tables WITH SCHEMA public;

COMMIT;
