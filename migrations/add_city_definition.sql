BEGIN TRANSACTION;

/*
    Trigger Function that creates the table primary key value.
*/
CREATE OR REPLACE FUNCTION local.city_create_primary_key() RETURNS trigger AS $delim$
    DECLARE
        pk VARCHAR(64);
        pk_seed VARCHAR;
    BEGIN
        pk_seed = CONCAT(NEW.name);
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
CREATE TABLE local.city (
    id VARCHAR(64) NOT NULL,
    name VARCHAR(255) NOT NULL,
    external_link VARCHAR(255) NOT NULL DEFAULT 'N/A',
    created TIMESTAMP WITH TIME ZONE NOT NULL,
    updated TIMESTAMP WITH TIME ZONE NOT NULL,
    period tstzrange NOT NULL,
    CONSTRAINT city_pk PRIMARY KEY (id)
);

/*
    History table definition.
*/
CREATE TABLE history.city (LIKE local.city);

/*
    Trigger to update history table.
*/
CREATE TRIGGER city_history_tr
    BEFORE INSERT OR UPDATE OR DELETE on local.city
    FOR EACH ROW
    EXECUTE PROCEDURE public.versioning('period', 'history.city', true);

/*
    Trigger to create primary key value before insert.
*/
CREATE TRIGGER city_create_pk_tr
     BEFORE INSERT ON local.city
     FOR EACH ROW
     EXECUTE PROCEDURE local.city_create_primary_key();

/*
   Trigger to set `created` and `updated` initial values.
*/
CREATE TRIGGER city_set_created_tr
     BEFORE INSERT ON local.city
     FOR EACH ROW
     EXECUTE PROCEDURE utility.set_created();

/*
    Trigger to update `updated` value before update.
*/
CREATE TRIGGER city_set_updated_tr
     BEFORE UPDATE ON local.city
     FOR EACH ROW
     EXECUTE PROCEDURE utility.set_updated();
COMMIT;