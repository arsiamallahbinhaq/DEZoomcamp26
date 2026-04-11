/* @bruin
name: energy_mart.fct_production
type: bq.sql
description: "Monthly energy production facts — dashboard-ready"

depends:
  - energy_staging.stg_petroleum

materialization:
  type: table
  partition_by: DATE_TRUNC(period, MONTH)
  cluster_by:
    - state_code
    - energy_type
@bruin */

WITH base AS (
  SELECT
    period,
    state_code,
    state_name,
    energy_type,
    SUM(production_value) AS total_production,
    unit,
    production_year,
    production_month,
  FROM `energy_staging.stg_petroleum`
  WHERE state_code != 'US'  -- Exclude national aggregate, hitung sendiri
  GROUP BY 1,2,3,4,6,7,8
),

with_mom AS (
  SELECT
    *,
    LAG(total_production) OVER (
      PARTITION BY state_code, energy_type
      ORDER BY period
    ) AS prev_month_production,
  FROM base
),

with_yoy AS (
  SELECT
    *,
    LAG(total_production, 12) OVER (
      PARTITION BY state_code, energy_type
      ORDER BY period
    ) AS prev_year_production,
  FROM with_mom
)

SELECT
  period,
  state_code,
  state_name,
  energy_type,
  total_production,
  unit,
  production_year,
  production_month,

  -- Month-over-month change
  ROUND(
    SAFE_DIVIDE(total_production - prev_month_production, prev_month_production) * 100,
    2
  ) AS mom_change_pct,

  -- Year-over-year change
  ROUND(
    SAFE_DIVIDE(total_production - prev_year_production, prev_year_production) * 100,
    2
  ) AS yoy_change_pct,

FROM with_yoy
ORDER BY period DESC, total_production DESC
