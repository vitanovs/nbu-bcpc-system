BEGIN TRANSACTION;

/*
    Trigger Function that creates the table primary key value.
*/
CREATE OR REPLACE FUNCTION local.leader_create_primary_key() RETURNS trigger AS $delim$
    DECLARE
        pk VARCHAR(64);
        pk_seed VARCHAR;
    BEGIN
        pk_seed = CONCAT(NEW.email);
        pk =LOWER(ENCODE(public.DIGEST(pk_seed, 'sha256'), 'hex'));
        IF NEW.id IS DISTINCT FROM pk THEN
          NEW.id := pk;
        END IF;

        RETURN NEW;
    END;
$delim$ LANGUAGE plpgsql;

/*
    Table definition.
*/
CREATE TABLE local.leader (
    id VARCHAR(64) NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    created TIMESTAMP WITH TIME ZONE NOT NULL,
    updated TIMESTAMP WITH TIME ZONE NOT NULL,
    period tstzrange NOT NULL,
    CONSTRAINT leader_pk PRIMARY KEY (id),
    CONSTRAINT leader_unique UNIQUE (email)
);

/*
    History table definition.
*/
CREATE TABLE history.leader (LIKE local.leader);

/*
    Trigger to update history table.
*/
CREATE TRIGGER leader_history_tr
    BEFORE INSERT OR UPDATE OR DELETE on local.leader
    FOR EACH ROW
    EXECUTE PROCEDURE local.versioning('period', 'history.leader', true);

/*
    Trigger to create primary key value before insert.
*/
CREATE TRIGGER leader_create_pk_tr
     BEFORE INSERT ON local.leader
     FOR EACH ROW
     EXECUTE PROCEDURE local.leader_create_primary_key();

/*
   Trigger to set `created` and `updated` initial values.
*/
CREATE TRIGGER leader_set_created_tr
     BEFORE INSERT ON local.leader
     FOR EACH ROW
     EXECUTE PROCEDURE utility.set_created();

/*
    Trigger to update `updated` value before update.
*/
CREATE TRIGGER leader_set_updated_tr
     BEFORE UPDATE ON local.leader
     FOR EACH ROW
     EXECUTE PROCEDURE utility.set_updated();
COMMIT;