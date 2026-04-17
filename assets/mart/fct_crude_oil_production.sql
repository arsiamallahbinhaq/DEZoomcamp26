/* @bruin

name: mart.fct_crude_oil_production
type: bq.sql
depends:
  - staging.stg_crude_oil_production
description: Aggregate monthly crude oil production by state and compute dashboard metrics such as share of total and growth rates.
tags:
  - mart
  - dashboard
  - bigquery
  - crude-oil

@bruin */

CREATE OR REPLACE TABLE `crude_oil_mart.fct_crude_oil_production`
PARTITION BY period
CLUSTER BY state_code AS
WITH monthly_state_production AS (
    SELECT
        period,
        production_year,
        production_month,
        state_code,
        state_name,
        SUM(production_value) AS total_production,
        ANY_VALUE(units) AS unit
    FROM `crude_oil_staging.stg_crude_oil_production`
    GROUP BY
        period,
        production_year,
        production_month,
        state_code,
        state_name
),
with_national_total AS (
    SELECT
        *,
        SUM(total_production) OVER (PARTITION BY period) AS national_total_production
    FROM monthly_state_production
),
with_growth_metrics AS (
    SELECT
        *,
        LAG(total_production) OVER (
            PARTITION BY state_code
            ORDER BY period
        ) AS previous_month_production,
        LAG(total_production, 12) OVER (
            PARTITION BY state_code
            ORDER BY period
        ) AS previous_year_production
    FROM with_national_total
)
SELECT
    period,
    production_year,
    production_month,
    state_code,
    state_name,
    total_production,
    unit,
    national_total_production,
    SAFE_DIVIDE(total_production, national_total_production) * 100 AS share_of_total_pct,
    SAFE_DIVIDE(
        total_production - previous_month_production,
        previous_month_production
    ) * 100 AS mom_change_pct,
    SAFE_DIVIDE(
        total_production - previous_year_production,
        previous_year_production
    ) * 100 AS yoy_change_pct
FROM with_growth_metrics;
