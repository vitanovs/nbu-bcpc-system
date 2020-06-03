BEGIN TRANSACTION;

/*
    Trigger Function that creates the table primary key value.
*/
CREATE OR REPLACE FUNCTION local.team_leader_create_primary_key() RETURNS trigger AS $delim$
    DECLARE
        pk VARCHAR(64);
        pk_seed VARCHAR;
    BEGIN
        pk_seed = CONCAT(NEW.team_id, NEW.leader_id);
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
CREATE TABLE local.team_leader (
    id VARCHAR(64) NOT NULL,
    team_id VARCHAR(64) NOT NULL,
    leader_id VARCHAR(64) NOT NULL,
    created TIMESTAMP WITH TIME ZONE NOT NULL,
    updated TIMESTAMP WITH TIME ZONE NOT NULL,
    period tstzrange NOT NULL,
    CONSTRAINT team_leader_pk PRIMARY KEY (id),
    CONSTRAINT team_leader_unique UNIQUE (team_id, leader_id),
    CONSTRAINT team_leader_to_team_fk FOREIGN KEY (team_id)
        REFERENCES local.team (id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT team_leader_to_leader_fk FOREIGN KEY (leader_id)
        REFERENCES local.leader (id) ON UPDATE CASCADE ON DELETE CASCADE
);

/*
    History table definition.
*/
CREATE TABLE history.team_leader (LIKE local.team_leader);

/*
    Trigger to update history table.
*/
CREATE TRIGGER team_leader_history_tr
    BEFORE INSERT OR UPDATE OR DELETE on local.team_leader
    FOR EACH ROW
    EXECUTE PROCEDURE public.versioning('period', 'history.team_leader', true);

/*
    Trigger to create primary key value before insert.
*/
CREATE TRIGGER team_leader_create_pk_tr
     BEFORE INSERT ON local.team_leader
     FOR EACH ROW
     EXECUTE PROCEDURE local.team_leader_create_primary_key();

/*
   Trigger to set `created` and `updated` initial values.
*/
CREATE TRIGGER team_leader_set_created_tr
     BEFORE INSERT ON local.team_leader
     FOR EACH ROW
     EXECUTE PROCEDURE utility.set_created();

/*
    Trigger to update `updated` value before update.
*/
CREATE TRIGGER team_leader_set_updated_tr
     BEFORE UPDATE ON local.team_leader
     FOR EACH ROW
     EXECUTE PROCEDURE utility.set_updated();
COMMIT;