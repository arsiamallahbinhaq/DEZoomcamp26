-- Query untuk mencari 5 state dengan pertumbuhan MoM tertinggi pada data terbaru
-- Berguna untuk menambahkan insight "Top Gainers" di dashboard

SELECT 
    state_name,
    period,
    total_production,
    mom_change_pct
FROM `dezoomcamp2026-493003.crude_oil_mart.fct_crude_oil_production`
WHERE period = (SELECT MAX(period) FROM `dezoomcamp2026-493003.crude_oil_mart.fct_crude_oil_production`)
  AND mom_change_pct IS NOT NULL
ORDER BY mom_change_pct DESC
LIMIT 5;