BEGIN TRANSACTION;

/*
    Trigger Function that creates the table primary key value.
*/
CREATE OR REPLACE FUNCTION local.team_create_primary_key() RETURNS trigger AS $delim$
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
CREATE TABLE local.team (
    id VARCHAR(64) NOT NULL,
    name VARCHAR(255) NOT NULL,
    created TIMESTAMP WITH TIME ZONE NOT NULL,
    updated TIMESTAMP WITH TIME ZONE NOT NULL,
    period tstzrange NOT NULL,
    CONSTRAINT team_pk PRIMARY KEY (id),
    CONSTRAINT team_unique UNIQUE (name)
);

/*
    History table definition.
*/
CREATE TABLE history.team (LIKE local.team);

/*
    Trigger to update history table.
*/
CREATE TRIGGER team_history_tr
    BEFORE INSERT OR UPDATE OR DELETE on local.team
    FOR EACH ROW
    EXECUTE PROCEDURE local.versioning('period', 'history.team', true);

/*
    Trigger to create primary key value before insert.
*/
CREATE TRIGGER team_create_pk_tr
     BEFORE INSERT ON local.team
     FOR EACH ROW
     EXECUTE PROCEDURE local.team_create_primary_key();

/*
   Trigger to set `created` and `updated` initial values.
*/
CREATE TRIGGER team_set_created_tr
     BEFORE INSERT ON local.team
     FOR EACH ROW
     EXECUTE PROCEDURE utility.set_created();

/*
    Trigger to update `updated` value before update.
*/
CREATE TRIGGER team_set_updated_tr
     BEFORE UPDATE ON local.team
     FOR EACH ROW
     EXECUTE PROCEDURE utility.set_updated();
COMMIT;