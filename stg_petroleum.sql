/* @bruin
name: energy_staging.stg_petroleum
type: bq.sql
description: "Clean dan standardisasi data petroleum production"

depends:
  - energy_raw.petroleum_production

materialization:
  type: table
  partition_by: DATE_TRUNC(period, MONTH)
  cluster_by:
    - state_code
    - energy_type

columns:
  - name: period
    type: date
    checks:
      - name: not_null
  - name: state_code
    type: string
    checks:
      - name: not_null
      - name: not_null
  - name: production_value
    type: float
    checks:
      - name: not_null
      - name: positive_values
@bruin */

WITH source AS (
  SELECT * FROM `energy_raw.petroleum_production`
),

cleaned AS (
  SELECT
    period,

    -- Standardisasi kode area → state code 2 huruf
    CASE
      WHEN LENGTH(area_code) = 2 AND area_code != 'US' THEN area_code
      WHEN area_code = 'NUS' THEN 'US'
      ELSE area_code
    END AS state_code,

    area_name AS state_name,
    product_code,
    product_name,

    -- Standardisasi nama energy type
    CASE
      WHEN energy_type = 'petroleum' THEN 'Crude Oil'
      WHEN energy_type = 'natural_gas' THEN 'Natural Gas'
      ELSE energy_type
    END AS energy_type,

    value AS production_value,
    unit,
    series_id,
    ingested_at,

    -- Tambah kolom turunan
    EXTRACT(YEAR FROM period)  AS production_year,
    EXTRACT(MONTH FROM period) AS production_month,

  FROM source
  WHERE
    value > 0
    AND period IS NOT NULL
    AND area_code IS NOT NULL
)

SELECT * FROM cleaned
