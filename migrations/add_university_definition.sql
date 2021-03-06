BEGIN TRANSACTION;

/*
    Trigger Function that creates the table primary key value.
*/
CREATE OR REPLACE FUNCTION local.university_create_primary_key() RETURNS trigger AS $delim$
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
CREATE TABLE local.university (
    id VARCHAR(64) NOT NULL,
    city_id VARCHAR(64) NOT NULL,
    name VARCHAR(255) NOT NULL,
    external_link VARCHAR(255) DEFAULT 'N/A' NOT NULL,
    created TIMESTAMP WITH TIME ZONE NOT NULL,
    updated TIMESTAMP WITH TIME ZONE NOT NULL,
    period tstzrange NOT NULL,
    CONSTRAINT university_pk PRIMARY KEY (id),
    CONSTRAINT university_unique UNIQUE (name),
    CONSTRAINT university_to_city_fk FOREIGN KEY (city_id)
        REFERENCES local.city (id) ON UPDATE CASCADE ON DELETE CASCADE
);

/*
History table definition.
*/

CREATE TABLE history.university (LIKE local.university);

/*
    Trigger to update history table.
*/
CREATE TRIGGER university_history_tr
    BEFORE INSERT OR UPDATE OR DELETE on local.university
    FOR EACH ROW
    EXECUTE PROCEDURE public.versioning('period', 'history.university', true);

/*
    Trigger to create primary key value before insert.
*/
CREATE TRIGGER university_create_pk_tr
     BEFORE INSERT ON local.university
     FOR EACH ROW
     EXECUTE PROCEDURE local.university_create_primary_key();

/*
   Trigger to set `created` and `updated` initial values.
*/
CREATE TRIGGER university_set_created_tr
     BEFORE INSERT ON local.university
     FOR EACH ROW
     EXECUTE PROCEDURE utility.set_created();

/*
    Trigger to update `updated` value before update.
*/
CREATE TRIGGER university_set_updated_tr
     BEFORE UPDATE ON local.university
     FOR EACH ROW
     EXECUTE PROCEDURE utility.set_updated();
COMMIT;