BEGIN TRANSACTION;

/*
    Schema used for storing utility functions and definitions.
*/
CREATE SCHEMA utility;

/*
    Function to set `created` and `updated` columns of a new row.
*/
CREATE OR REPLACE FUNCTION utility.set_created() RETURNS trigger AS $delim_set_created$
    BEGIN
        NEW.created := now();
        NEW.updated := NEW.created;
        RETURN NEW;
    END;
$delim_set_created$ LANGUAGE plpgsql;

/*
    Function to update `updated` column of a new row.
*/
CREATE OR REPLACE FUNCTION utility.set_updated() RETURNS trigger AS $delim_set_updated$
    BEGIN
        NEW.updated := now();
        RETURN NEW;
    END;
$delim_set_updated$ LANGUAGE plpgsql;

COMMIT;