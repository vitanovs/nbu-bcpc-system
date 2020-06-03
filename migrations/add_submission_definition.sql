BEGIN TRANSACTION;

/*
    Trigger Function that creates the table primary key value.
*/
CREATE OR REPLACE FUNCTION local.submission_create_primary_key() RETURNS trigger AS $delim$
    DECLARE
        pk VARCHAR(64);
        pk_seed VARCHAR;
    BEGIN
        pk_seed = CONCAT(NEW.participation_id, NEW.task_id);
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
CREATE TABLE local.submission (
    id VARCHAR(64) NOT NULL,
    participation_id VARCHAR(64) NOT NULL,
    task_id VARCHAR(64) NOT NULL,
    trials_count INT NOT NULL,
    minutes_since_start INT NOT NULL,
    is_solved BOOLEAN NOT NULL,
    created TIMESTAMP WITH TIME ZONE NOT NULL,
    updated TIMESTAMP WITH TIME ZONE NOT NULL,
    period tstzrange NOT NULL,
    CONSTRAINT submission_pk PRIMARY KEY (id),
    CONSTRAINT submission_unique UNIQUE (participation_id, task_id),
    CONSTRAINT sumission_trials_count_must_be_a_natural_number CHECK ( trials_count > 0 ),
    CONSTRAINT sumission_minutes_since_start_must_be_a_positive_number CHECK ( minutes_since_start > 0 ),
    CONSTRAINT submission_to_participation_fk FOREIGN KEY (participation_id)
        REFERENCES local.participation (id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT submission_to_task_fk FOREIGN KEY (task_id)
        REFERENCES local.task (id) ON UPDATE CASCADE ON DELETE CASCADE
);

/*
    History table definition.
*/
CREATE TABLE history.submission (LIKE local.submission);

/*
    Trigger to update history table.
*/
CREATE TRIGGER submission_history_tr
    BEFORE INSERT OR UPDATE OR DELETE on local.submission
    FOR EACH ROW
    EXECUTE PROCEDURE public.versioning('period', 'history.submission', true);

/*
    Trigger to create primary key value before insert.
*/
CREATE TRIGGER submission_create_pk_tr
     BEFORE INSERT ON local.submission
     FOR EACH ROW
     EXECUTE PROCEDURE local.submission_create_primary_key();

/*
   Trigger to set `created` and `updated` initial values.
*/
CREATE TRIGGER submission_set_created_tr
     BEFORE INSERT ON local.submission
     FOR EACH ROW
     EXECUTE PROCEDURE utility.set_created();

/*
    Trigger to update `updated` value before update.
*/
CREATE TRIGGER submission_set_updated_tr
     BEFORE UPDATE ON local.submission
     FOR EACH ROW
     EXECUTE PROCEDURE utility.set_updated();
COMMIT;