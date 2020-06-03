BEGIN TRANSACTION;

/*
    Trigger Function that creates the table primary key value.
*/
CREATE OR REPLACE FUNCTION local.participant_create_primary_key() RETURNS trigger AS $delim$
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
CREATE TABLE local.participant (
    id VARCHAR(64) NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    created TIMESTAMP WITH TIME ZONE NOT NULL,
    updated TIMESTAMP WITH TIME ZONE NOT NULL,
    period tstzrange NOT NULL,
    CONSTRAINT participant_pk PRIMARY KEY (id),
    CONSTRAINT participant_unique UNIQUE (email)
);

/*
    History table definition.
*/
CREATE TABLE history.participant (LIKE local.participant);

/*
    Trigger to update history table.
*/
CREATE TRIGGER participant_history_tr
    BEFORE INSERT OR UPDATE OR DELETE on local.participant
    FOR EACH ROW
    EXECUTE PROCEDURE public.versioning('period', 'history.participant', true);

/*
    Trigger to create primary key value before insert.
*/
CREATE TRIGGER participant_create_pk_tr
     BEFORE INSERT ON local.participant
     FOR EACH ROW
     EXECUTE PROCEDURE local.participant_create_primary_key();

/*
   Trigger to set `created` and `updated` initial values.
*/
CREATE TRIGGER participant_set_created_tr
     BEFORE INSERT ON local.participant
     FOR EACH ROW
     EXECUTE PROCEDURE utility.set_created();

/*
    Trigger to update `updated` value before update.
*/
CREATE TRIGGER participant_set_updated_tr
     BEFORE UPDATE ON local.participant
     FOR EACH ROW
     EXECUTE PROCEDURE utility.set_updated();
COMMIT;