-- Snowflake bootstrap for the SkyTrax rebuild (trial account).
-- Run once as ACCOUNTADMIN in a Snowsight worksheet.
--
-- Cost posture: ONE XSMALL warehouse, AUTO_SUSPEND = 60s, INITIALLY SUSPENDED.
-- The original project (terraform/snowflake/warehouses.tf) provisions five
-- warehouses XSMALL..XLARGE; a trial does not need them.

USE ROLE ACCOUNTADMIN;

-- 1. Compute -------------------------------------------------------------
CREATE WAREHOUSE IF NOT EXISTS SKYTRAX_COMPUTE_XSMALL
    WAREHOUSE_SIZE      = 'XSMALL'
    AUTO_SUSPEND        = 60      -- seconds of idle before suspend
    AUTO_RESUME         = TRUE
    INITIALLY_SUSPENDED = TRUE
    MIN_CLUSTER_COUNT   = 1
    MAX_CLUSTER_COUNT   = 1
    COMMENT             = 'SkyTrax rebuild - minimal trial warehouse';

-- 2. Database and schemas ------------------------------------------------
CREATE DATABASE IF NOT EXISTS SKYTRAX_REVIEWS_DB
    COMMENT = 'Skytrax airline reviews data warehouse (rebuild)';

CREATE SCHEMA IF NOT EXISTS SKYTRAX_REVIEWS_DB.RAW
    COMMENT = 'Landing zone loaded by COPY INTO. dbt never writes here.';

-- dbt target schema. The learner owns the layer layout inside it.
CREATE SCHEMA IF NOT EXISTS SKYTRAX_REVIEWS_DB.DBT_DEV
    COMMENT = 'dbt development target';

-- 3. Raw table -----------------------------------------------------------
-- Contract copied verbatim from the extract_load repository:
-- include/sql/create_table_airlines.sql
CREATE TABLE IF NOT EXISTS SKYTRAX_REVIEWS_DB.RAW.AIRLINE_REVIEWS (
    verify                  BOOLEAN,
    date_submitted          DATE,
    date_flown              DATE,
    customer_name           STRING,
    nationality             STRING,
    airline_name            STRING,
    type_of_traveller       STRING,
    seat_type               STRING,
    aircraft                STRING,
    origin_city             STRING,
    origin_airport          STRING,
    destination_city        STRING,
    destination_airport     STRING,
    transit_city            STRING,
    transit_airport         STRING,
    seat_comfort            INT,
    cabin_staff_service     INT,
    food_and_beverages      INT,
    inflight_entertainment  INT,
    ground_service          INT,
    wifi_and_connectivity   INT,
    value_for_money         INT,
    recommended             BOOLEAN,
    review                  STRING,
    updated_at              TIMESTAMP_NTZ
);

-- 4. Internal stage ------------------------------------------------------
-- Replaces the production external S3 stage (RAW.SKYTRAX_S3_STAGE). Same
-- FILE_FORMAT as include/sql/create_stage.sql, minus the S3 URL/credentials,
-- so the stage -> COPY INTO mechanic stays identical without needing AWS.
CREATE STAGE IF NOT EXISTS SKYTRAX_REVIEWS_DB.RAW.SKYTRAX_LOCAL_STAGE
    FILE_FORMAT = (
        TYPE                           = 'CSV'
        FIELD_OPTIONALLY_ENCLOSED_BY   = '"'
        SKIP_HEADER                    = 1
        FIELD_DELIMITER                = ','
        NULL_IF                        = ('', 'NULL', 'None')
        ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    )
    COMMENT = 'Internal stage for locally processed CSVs (rebuild)';

-- 5. Role ----------------------------------------------------------------
CREATE ROLE IF NOT EXISTS SKYTRAX_TRANSFORMER
    COMMENT = 'Read RAW, read/write dbt target schemas';

GRANT USAGE  ON WAREHOUSE SKYTRAX_COMPUTE_XSMALL   TO ROLE SKYTRAX_TRANSFORMER;
GRANT USAGE  ON DATABASE  SKYTRAX_REVIEWS_DB       TO ROLE SKYTRAX_TRANSFORMER;
GRANT USAGE  ON SCHEMA    SKYTRAX_REVIEWS_DB.RAW   TO ROLE SKYTRAX_TRANSFORMER;
GRANT SELECT ON ALL    TABLES IN SCHEMA SKYTRAX_REVIEWS_DB.RAW TO ROLE SKYTRAX_TRANSFORMER;
GRANT SELECT ON FUTURE TABLES IN SCHEMA SKYTRAX_REVIEWS_DB.RAW TO ROLE SKYTRAX_TRANSFORMER;
GRANT READ, WRITE ON STAGE SKYTRAX_REVIEWS_DB.RAW.SKYTRAX_LOCAL_STAGE TO ROLE SKYTRAX_TRANSFORMER;

-- dbt creates schemas under the target, so give it the database-level right.
GRANT CREATE SCHEMA ON DATABASE SKYTRAX_REVIEWS_DB TO ROLE SKYTRAX_TRANSFORMER;
GRANT ALL ON SCHEMA SKYTRAX_REVIEWS_DB.DBT_DEV     TO ROLE SKYTRAX_TRANSFORMER;

-- 6. Grant the role to your user ----------------------------------------
-- Replace <YOUR_USERNAME> with the login name of your trial account.
-- GRANT ROLE SKYTRAX_TRANSFORMER TO USER <YOUR_USERNAME>;

-- 7. Verify --------------------------------------------------------------
SHOW WAREHOUSES LIKE 'SKYTRAX_COMPUTE_XSMALL';
SHOW STAGES IN SCHEMA SKYTRAX_REVIEWS_DB.RAW;
DESC TABLE SKYTRAX_REVIEWS_DB.RAW.AIRLINE_REVIEWS;
