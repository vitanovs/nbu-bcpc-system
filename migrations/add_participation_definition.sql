BEGIN TRANSACTION;

/*
    Trigger Function that creates the table primary key value.
*/
CREATE OR REPLACE FUNCTION local.participation_create_primary_key() RETURNS trigger AS $delim$
    DECLARE
        pk VARCHAR(64);
        pk_seed VARCHAR;
    BEGIN
        pk_seed = CONCAT(NEW.team_id, NEW.olympiad_id);
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
CREATE TABLE local.participation (
    id VARCHAR(64) NOT NULL,
    team_id VARCHAR(64) NOT NULL,
    olympiad_id VARCHAR(64) NOT NULL,
    created TIMESTAMP WITH TIME ZONE NOT NULL,
    updated TIMESTAMP WITH TIME ZONE NOT NULL,
    period tstzrange NOT NULL,
    CONSTRAINT participation_pk PRIMARY KEY (id),
    CONSTRAINT participation_unique UNIQUE (team_id, olympiad_id),
    CONSTRAINT participation_to_team_fk FOREIGN KEY (team_id)
        REFERENCES local.team (id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT participation_to_olympiad_fk FOREIGN KEY (olympiad_id)
        REFERENCES local.olympiad (id) ON UPDATE CASCADE ON DELETE CASCADE
);

/*
    History table definition.
*/
CREATE TABLE history.participation (LIKE local.participation);

/*
    Trigger to update history table.
*/
CREATE TRIGGER participation_history_tr
    BEFORE INSERT OR UPDATE OR DELETE on local.participation
    FOR EACH ROW
    EXECUTE PROCEDURE public.versioning('period', 'history.participation', true);

/*
    Trigger to create primary key value before insert.
*/
CREATE TRIGGER participation_create_pk_tr
     BEFORE INSERT ON local.participation
     FOR EACH ROW
     EXECUTE PROCEDURE local.participation_create_primary_key();

/*
   Trigger to set `created` and `updated` initial values.
*/
CREATE TRIGGER participation_set_created_tr
     BEFORE INSERT ON local.participation
     FOR EACH ROW
     EXECUTE PROCEDURE utility.set_created();

/*
    Trigger to update `updated` value before update.
*/
CREATE TRIGGER participation_set_updated_tr
     BEFORE UPDATE ON local.participation
     FOR EACH ROW
     EXECUTE PROCEDURE utility.set_updated();
COMMIT;
