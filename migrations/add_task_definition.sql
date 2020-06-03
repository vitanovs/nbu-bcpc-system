BEGIN TRANSACTION;

/*
    Trigger Function that creates the table primary key value.
*/
CREATE OR REPLACE FUNCTION local.task_create_primary_key() RETURNS trigger AS $delim$
    DECLARE
        pk VARCHAR(64);
        pk_seed VARCHAR;
    BEGIN
        pk_seed = CONCAT(NEW.name, NEW.olympiad_id);
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
CREATE TABLE local.task (
    id VARCHAR(64) NOT NULL,
    olympiad_id VARCHAR(64) NOT NULL,
    name VARCHAR(255) NOT NULL,
    abbreviation VARCHAR(255) NOT NULL DEFAULT 'N/A',
    external_link VARCHAR(255) NOT NULL DEFAULT 'N/A',
    created TIMESTAMP WITH TIME ZONE NOT NULL,
    updated TIMESTAMP WITH TIME ZONE NOT NULL,
    period tstzrange NOT NULL,
    CONSTRAINT task_pk PRIMARY KEY (id),
    CONSTRAINT task_unique UNIQUE (olympiad_id, name),
    CONSTRAINT task_to_olympiad_fk FOREIGN KEY (olympiad_id)
        REFERENCES local.olympiad (id) ON UPDATE CASCADE ON DELETE CASCADE
);

/*
    History table definition.
*/
CREATE TABLE history.task (LIKE local.task);

/*
    Trigger to update history table.
*/
CREATE TRIGGER task_history_tr
    BEFORE INSERT OR UPDATE OR DELETE on local.task
    FOR EACH ROW
    EXECUTE PROCEDURE public.versioning('period', 'history.task', true);

/*
    Trigger to create primary key value before insert.
*/
CREATE TRIGGER task_create_pk_tr
     BEFORE INSERT ON local.task
     FOR EACH ROW
     EXECUTE PROCEDURE local.task_create_primary_key();

/*
   Trigger to set `created` and `updated` initial values.
*/
CREATE TRIGGER task_set_created_tr
     BEFORE INSERT ON local.task
     FOR EACH ROW
     EXECUTE PROCEDURE utility.set_created();

/*
    Trigger to update `updated` value before update.
*/
CREATE TRIGGER task_set_updated_tr
     BEFORE UPDATE ON local.task
     FOR EACH ROW
     EXECUTE PROCEDURE utility.set_updated();
COMMIT;