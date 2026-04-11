/* @bruin
name: energy_raw.petroleum_production
type: bq.sql
description: "Load petroleum production data dari GCS ke BigQuery raw layer"

depends:
  - ingestion.eia_fetch

materialization:
  type: table
  partition_by: DATE_TRUNC(period, MONTH)
  cluster_by:
    - area_code
    - energy_type

columns:
  - name: period
    type: date
    checks:
      - name: not_null
  - name: area_code
    type: string
    checks:
      - name: not_null
  - name: value
    type: float
    checks:
      - name: not_null
@bruin */

SELECT
  PARSE_DATE('%Y-%m', period_str)     AS period,
  area_code,
  area_name,
  product_code,
  product_name,
  series_id,
  series_description,
  SAFE_CAST(value AS FLOAT64)         AS value,
  unit,
  energy_type,
  CAST(_ingested_at AS TIMESTAMP)     AS ingested_at

FROM `{{ env "GCS_BUCKET_NAME" }}`.`raw/petroleum/year=*/*.parquet`
WHERE value IS NOT NULL
