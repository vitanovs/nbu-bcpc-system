# NBU BCPC Statistics System

[![Documentation Status](https://readthedocs.org/projects/ansicolortags/badge/?version=latest)](http://ansicolortags.readthedocs.io/?badge=latest) [![GitHub issues](https://img.shields.io/github/issues/Naereen/StrapDown.js.svg)](https://github.com/vitanovs/nbu-bcpc-system/issues)

This repository contains the source code of the BCPC Statistics system of New Bulgarian University.

## Requirements

* [PostgreSQL](https://www.postgresql.org) - v12.3 at least
* [Temporal Tables](https://pgxn.org/dist/temporal_tables/) - v1.2.0 at least
* [Versioner](https://github.com/vitanovs/versioner) - v1.5.0 at least

## Installation

To apply the migration use the `versioner` schema migration tool, specified in the requirements section. Head over to the tool's page to get more information on how to use it in your environment. The following commands are a brief overview:

* Dropping database:

    ```sh
    versioner -e localhost -p 5432 -d postgres --username admin --password 1234 --sslmode disable database drop -n demo
    ```

* Creating database:

    ```sh
    versioner -e localhost -p 5432 -d postgres --username admin --password 1234 --sslmode disable database create -n demo
    ```

* Initialization:

    ```sh
    versioner -e localhost -p 5432 -d demo --username admin --password 1234 --sslmode disable migration init
    ```

* Applying migrations:

    ```sh
    versioner -e localhost -p 5432 -d demo --username admin --password 1234 --sslmode disable migration apply -c ./configuration.toml
    ```

## Usage

After initializing and applying the migrations, four main schemas are being created:

* `local` - Storing the latest state of the data in the tables.
* `history` - Storing the historical records of the data. ( See `temporal tables` plugin features ).
* `utility` - Storing utility functions, used across the schema.
* `versioner` - Storing the `versioner` tool necessary data.

To examine the latest schema version click [here](https://raw.githubusercontent.com/vitanovs/nbu-bcpc-system/master/docs/schema.png).

## Contacts

Open issue of submit pull request.
