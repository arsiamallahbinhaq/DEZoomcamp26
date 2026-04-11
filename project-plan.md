# US Energy Production Analytics Pipeline
### Data Engineering Zoomcamp 2026 — Capstone Project Plan

---

## Problem Statement

The global energy transition requires clear visibility into how fossil fuel production
trends over time and varies across regions. This project builds an end-to-end batch
data pipeline that ingests U.S. energy production data from the EIA (U.S. Energy
Information Administration) Open Data API, processes it through a multi-layer
data warehouse, and surfaces insights via an interactive dashboard.

**Questions this dashboard will answer:**
- How has U.S. crude oil and natural gas production trended over the past decade?
- Which states are the top producers, and how has their share shifted?
- What is the distribution of production by energy type (oil, gas, NGL)?

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        ORCHESTRATION                            │
│                   Bruin CLI (batch, daily)                      │
│               Scheduled via GitHub Actions                      │
└───────────────────────────┬─────────────────────────────────────┘
                            │
          ┌─────────────────▼──────────────────┐
          │           DATA SOURCE               │
          │      EIA Open Data API v2           │
          │  (Petroleum, Natural Gas, NGL)      │
          └─────────────────┬──────────────────┘
                            │  Python asset (Bruin)
          ┌─────────────────▼──────────────────┐
          │           DATA LAKE                 │
          │    Google Cloud Storage (GCS)       │
          │    gs://energy-raw-data/            │
          │    Partitioned: year=/month=        │
          └─────────────────┬──────────────────┘
                            │  Bruin ingestr (GCS → BQ)
          ┌─────────────────▼──────────────────┐
          │         DATA WAREHOUSE              │
          │           BigQuery                  │
          │  ┌──────────────────────────────┐  │
          │  │  Layer 1: energy_raw         │  │
          │  │  (raw ingested tables)       │  │
          │  ├──────────────────────────────┤  │
          │  │  Layer 2: energy_staging     │  │
          │  │  (cleaned, typed, validated) │  │
          │  ├──────────────────────────────┤  │
          │  │  Layer 3: energy_mart        │  │
          │  │  (aggregated, dashboard-ready│  │
          │  └──────────────────────────────┘  │
          └─────────────────┬──────────────────┘
                            │  BigQuery connector
          ┌─────────────────▼──────────────────┐
          │           DASHBOARD                 │
          │         Looker Studio               │
          │  Tile 1: Production by source (bar) │
          │  Tile 2: Monthly trend (line)       │
          └────────────────────────────────────┘
```

---

## Tech Stack

| Component | Technology | Justification |
|---|---|---|
| Cloud provider | GCP | Free tier + $5 credit |
| Infrastructure as Code | Terraform | Required for 4/4 cloud score |
| Workflow orchestration | Bruin CLI | Replaces Airflow — lightweight, supports BQ + GCS natively |
| Data lake | Google Cloud Storage | Cheap ($0.02/GB), same-region free egress to BQ |
| Data warehouse | BigQuery | Free tier: 10 GB storage + 1 TB query/month |
| Transformation | Bruin `bq.sql` assets | Native SQL transformation with dependency graph |
| Data quality | Bruin built-in checks | Column not-null, accepted values, row count |
| Dashboard | Looker Studio | Free, native BigQuery connector |
| CI/CD | GitHub Actions | Runs Bruin pipeline on schedule |
| Dev environment | GitHub Codespaces | 60 free hours/month |

---

## Dataset Candidates

> Status: **TO BE DECIDED** — see dataset evaluation section below

### Candidate A — EIA Petroleum Production (Primary candidate)
- **URL:** `https://api.eia.gov/v2/petroleum/crd/crpdn/data/`
- **Content:** Monthly crude oil production by state (2000–present)
- **Format:** JSON via REST API (free API key required)
- **Volume:** ~500 MB historical, ~1 MB/month incremental
- **Relevance:** Directly relevant to oil & gas background
- **Temporal coverage:** Monthly since 1981
- **Categorical dimension:** state, energy type (oil/NGL/gas)

### Candidate B — EIA Natural Gas Production
- **URL:** `https://api.eia.gov/v2/natural-gas/prod/sum/data/`
- **Content:** Monthly NG production by state and type
- **Format:** JSON via REST API
- **Volume:** ~300 MB historical

### Candidate C — EIA Total Energy (Combined)
- **URL:** `https://api.eia.gov/v2/total-energy/data/`
- **Content:** All energy types in one endpoint
- **Format:** JSON
- **Advantage:** Single pipeline, multiple dimensions

### Candidate D — OPEC Production Data (CSV bulk)
- **URL:** `https://www.opec.org/opec_web/en/data_graphs/40.htm`
- **Content:** OPEC member country production
- **Format:** CSV download (no API)
- **Advantage:** International angle — different from most DE Zoomcamp projects

---

## Evaluation Criteria Mapping

| Criteria | Max Score | Our Approach | Expected Score |
|---|---|---|---|
| Problem description | 4 | Clear problem, oil & gas context | 4/4 |
| Cloud (IaC) | 4 | GCP + Terraform | 4/4 |
| Data ingestion (batch) | 4 | Bruin multi-step DAG → GCS → BQ | 4/4 |
| Data warehouse | 4 | BQ partitioned by date, clustered by state/type | 4/4 |
| Transformations | 4 | Bruin bq.sql (raw → staging → mart) | 4/4 |
| Dashboard | 4 | Looker Studio, 2 tiles | 4/4 |
| Reproducibility | 4 | README + env vars + one-command setup | 4/4 |
| **Total** | **28** | | **28/28** |

---

## Budget Plan

| Item | Cost |
|---|---|
| GCP (BigQuery free tier) | $0.00/month |
| GCP (GCS storage ~5 GB) | ~$0.10/month |
| GCP total over 3 months | ~$0.30–$1.00 |
| GitHub Codespaces | $0 (60h free/month) |
| EIA API | $0 (free key) |
| Looker Studio | $0 |
| **Total estimated** | **~$1–$3 of $5 credit** |

**Safety rules:**
- Set GCP budget alert at $3.00
- Set hard notification at $4.50
- Keep GCS + BQ in `us-central1` (same region = free egress)
- Enable BigQuery cost controls: max bytes billed per query

---

## Project Structure (Bruin)

```
energy-pipeline/
├── .bruin.yml                    # Bruin config: GCP connection
├── .github/
│   └── workflows/
│       └── pipeline.yml          # GitHub Actions schedule
├── infra/
│   ├── main.tf                   # GCS bucket + BQ datasets
│   ├── variables.tf
│   └── outputs.tf
├── assets/
│   ├── ingestion/
│   │   └── eia_petroleum_fetch.py   # Python asset: API → GCS
│   ├── raw/
│   │   └── raw_petroleum.asset.yml  # ingestr: GCS → BQ raw
│   ├── staging/
│   │   └── stg_petroleum.sql        # Clean + type cast
│   └── mart/
│       ├── fct_production.sql       # Monthly production facts
│       └── dim_energy_source.sql    # Energy type dimension
├── dashboard/
│   └── looker_studio_link.md     # Dashboard URL + screenshot
└── README.md
```

---

## Pipeline DAG

```
eia_petroleum_fetch (Python)
        │
        ▼
raw_petroleum (bq.sql — ingestr GCS→BQ)
        │
        ▼
stg_petroleum (bq.sql — clean + validate)
        │
        ├──────────────────────┐
        ▼                      ▼
fct_production (mart)   dim_energy_source (mart)
        │                      │
        └──────────┬───────────┘
                   ▼
           Looker Studio Dashboard
```

---

## BigQuery Table Design

### `energy_raw.petroleum_production`
```sql
-- Partitioned by: DATE(period)
-- Clustered by: state, product
period          DATE,
state           STRING,
product         STRING,   -- crude oil / NGL / etc
value           FLOAT64,  -- thousand barrels/day
unit            STRING,
duoarea         STRING,
series_id       STRING,
_ingested_at    TIMESTAMP
```

### `energy_mart.fct_production`
```sql
-- Partitioned by: production_month
-- Clustered by: state, energy_type
production_month    DATE,
state               STRING,
energy_type         STRING,
total_value         FLOAT64,
unit                STRING,
yoy_change_pct      FLOAT64,
mom_change_pct      FLOAT64
```

---

## Dashboard Design

### Tile 1 — Production by energy source (bar chart)
- X-axis: Energy type (crude oil, NGL, dry gas)
- Y-axis: Average monthly production (Mbbl/day)
- Filter: Year range selector
- Source table: `energy_mart.fct_production`

### Tile 2 — Monthly production trend (line chart)
- X-axis: Month (2015–2024)
- Y-axis: Total U.S. production
- Breakdown: Top 5 states as separate lines
- Source table: `energy_mart.fct_production`

---

## Reproducibility Checklist (for README)

- [ ] `.env.example` with all required variables (EIA_API_KEY, GCP_PROJECT_ID)
- [ ] `terraform init && terraform apply` provisions all infra
- [ ] `bruin run` executes full pipeline end-to-end
- [ ] Dashboard link accessible without login (public Looker Studio)
- [ ] All secrets via env vars — no hardcoded values

---

## Timeline

| Week | Tasks |
|---|---|
| Week 1 | Setup GCP + Terraform, create GCS bucket + BQ datasets |
| Week 1 | Register EIA API key, explore data via Jupyter |
| Week 2 | Build Bruin Python ingestion asset, test EIA fetch |
| Week 2 | Build raw + staging SQL assets, test data quality checks |
| Week 3 | Build mart layer, connect Looker Studio |
| Week 3 | Build dashboard tiles, write README, final testing |

---

## Next Step

**Confirm dataset choice** → then generate:
1. `eia_petroleum_fetch.py` — Python Bruin asset
2. `main.tf` — Terraform infra config
3. `.bruin.yml` — GCP connection config
4. `stg_petroleum.sql` — staging transformation

---

*Last updated: April 2026 | DE Zoomcamp 2026 Capstone*
