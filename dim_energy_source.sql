/* @bruin
name: energy_mart.dim_energy_source
type: bq.sql
description: "Dimension table — energy types dan metadata"

depends:
  - energy_staging.stg_petroleum

materialization:
  type: table
@bruin */

SELECT DISTINCT
  energy_type,
  unit,
  CASE energy_type
    WHEN 'Crude Oil'     THEN 'Petroleum liquid extracted dari reservoir'
    WHEN 'Natural Gas'   THEN 'Methane-rich gas dari formasi geologi'
    ELSE 'Other'
  END AS description,
  CASE energy_type
    WHEN 'Crude Oil'     THEN 'Mbbl/month'
    WHEN 'Natural Gas'   THEN 'MMcf/month'
    ELSE unit
  END AS standard_unit

FROM `energy_staging.stg_petroleum`
ORDER BY energy_type
