BEGIN TRANSACTION;

/*
    Trigger Function that creates the table primary key value.
*/
CREATE OR REPLACE FUNCTION local.olympiad_create_primary_key() RETURNS trigger AS $delim$
    DECLARE
        pk VARCHAR(64);
        pk_seed VARCHAR;
    BEGIN
        pk_seed = CONCAT(NEW.name);
        pk =LOWER(ENCODE(local.DIGEST(pk_seed, 'sha256'), 'hex'));

        IF NEW.id IS DISTINCT FROM pk THEN
          NEW.id := pk;
        END IF;

        RETURN NEW;
    END;
$delim$ LANGUAGE plpgsql;

/*
    Table definition.
*/
CREATE TABLE local.olympiad (
    id VARCHAR(64) NOT NULL,
    university_id VARCHAR(64) NOT NULL,
    city_id VARCHAR(64) NOT NULL,
    name VARCHAR(255) NOT NULL,
    year SMALLINT NOT NULL,
    external_link VARCHAR(255) NOT NULL DEFAULT 'N/A',
    created TIMESTAMP WITH TIME ZONE NOT NULL,
    updated TIMESTAMP WITH TIME ZONE NOT NULL,
    period tstzrange NOT NULL,
    CONSTRAINT olympiad_pk PRIMARY KEY (id),
    CONSTRAINT olympiad_unique UNIQUE (name, year),
    CONSTRAINT olympiad_year_should_be_positive CHECK (year > 0),
    CONSTRAINT olympiad_to_university_fk FOREIGN KEY (university_id)
        REFERENCES local.university (id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT olympiad_to_city_fk FOREIGN KEY (city_id)
        REFERENCES local.city (id) ON UPDATE CASCADE ON DELETE CASCADE
);

/*
    History table definition.
*/
CREATE TABLE history.olympiad (LIKE local.olympiad);

/*
    Trigger to update history table.
*/
CREATE TRIGGER olympiad_history_tr
    BEFORE INSERT OR UPDATE OR DELETE on local.olympiad
    FOR EACH ROW
    EXECUTE PROCEDURE local.versioning('period', 'history.olympiad', true);

/*
    Trigger to create primary key value before insert.
*/
CREATE TRIGGER olympiad_create_pk_tr
     BEFORE INSERT ON local.olympiad
     FOR EACH ROW
     EXECUTE PROCEDURE local.olympiad_create_primary_key();

/*
   Trigger to set `created` and `updated` initial values.
*/
CREATE TRIGGER olympiad_set_created_tr
     BEFORE INSERT ON local.olympiad
     FOR EACH ROW
     EXECUTE PROCEDURE utility.set_created();

/*
    Trigger to update `updated` value before update.
*/
CREATE TRIGGER olympiad_set_updated_tr
     BEFORE UPDATE ON local.olympiad
     FOR EACH ROW
     EXECUTE PROCEDURE utility.set_updated();
COMMIT;