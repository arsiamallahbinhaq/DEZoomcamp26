/* @bruin

name: staging.stg_crude_oil_production
type: bq.sql
depends:
  - raw.load_crude_oil_raw
description: Clean the raw crude oil dataset into state-level monthly production records ready for mart aggregation.
tags:
  - staging
  - bigquery
  - crude-oil

@bruin */

CREATE OR REPLACE TABLE `crude_oil_staging.stg_crude_oil_production`
PARTITION BY period
CLUSTER BY state_code AS
WITH raw_source AS (
    SELECT
        DATE(TIMESTAMP_MICROS(CAST(period / 1000 AS INT64))) AS period,
        duoarea,
        area_name,
        product,
        product_name,
        process,
        process_name,
        series,
        series_description,
        SAFE_CAST(value_numeric AS NUMERIC) AS production_value,
        units,
        TIMESTAMP(ingested_at) AS ingested_at,
        DATE(load_date) AS load_date,
        source_name,
        source_endpoint
    FROM `crude_oil_raw.crude_oil_production_raw`
),
filtered AS (
    SELECT
        period,
        EXTRACT(YEAR FROM period) AS production_year,
        EXTRACT(MONTH FROM period) AS production_month,
        duoarea,
        REGEXP_EXTRACT(area_name, r'^USA-([A-Z]{2})$') AS state_code,
        COALESCE(
            REGEXP_EXTRACT(series_description, r'^(.*?) Field Production of Crude Oil'),
            area_name
        ) AS state_name,
        area_name AS area_name_raw,
        product,
        product_name,
        process,
        process_name,
        series,
        series_description,
        production_value,
        units,
        ingested_at,
        load_date,
        source_name,
        source_endpoint
    FROM raw_source
    WHERE period IS NOT NULL
      AND production_value IS NOT NULL
      AND production_value >= 0
      AND product = 'EPC0'
      AND process = 'FPF'
      AND units = 'MBBL'
      AND REGEXP_CONTAINS(area_name, r'^USA-[A-Z]{2}$')
),
deduplicated AS (
    SELECT
        *
    FROM filtered
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY period, state_code, series, units
        ORDER BY ingested_at DESC, load_date DESC
    ) = 1
)
SELECT
    period,
    production_year,
    production_month,
    state_code,
    state_name,
    area_name_raw,
    duoarea,
    product,
    product_name,
    process,
    process_name,
    series,
    series_description,
    production_value,
    units,
    ingested_at,
    load_date,
    source_name,
    source_endpoint
FROM deduplicated;
