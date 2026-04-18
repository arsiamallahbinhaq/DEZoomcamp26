# U.S. Crude Oil Production Analytics Pipeline
[![GCP](https://img.shields.io/badge/GCP-Cloud-blue?logo=google-cloud)](https://cloud.google.com/)
[![Bruin](https://img.shields.io/badge/Orchestration-Bruin-orange)](https://getbruin.com/)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-purple?logo=terraform)](https://www.terraform.io/)
[![BigQuery](https://img.shields.io/badge/Data_Warehouse-BigQuery-blue?logo=google-bigquery)](https://cloud.google.com/bigquery)

This repository contains an end-to-end data engineering pipeline designed to analyze monthly U.S. crude oil production data. The project leverages modern data stack tools to transform raw API data into actionable business insights.

## 📊 Interactive Dashboard
You can access the live interactive report here:
**[Looker Studio Dashboard - U.S. Crude Oil Production](https://datastudio.google.com/s/hRlK9DCmA5A)**

---

## 🎯 Project Overview
The primary goal of this project is to build a robust, scalable pipeline that tracks crude oil production across different U.S. states using public data from the Energy Information Administration (EIA).

### Key Business Questions:
- What is the monthly trend of U.S. crude oil production over time?
- Which states are the top contributors to the national production?
- How concentrated is the production within a few key states?
- When did significant production spikes or drops occur?

## 🏗️ Architecture
The pipeline follows a modular architecture:
1. **Ingestion**: Python script fetches data from EIA API v2.
2. **Data Lake**: Raw data is stored in **Google Cloud Storage (GCS)** as Parquet files.
3. **Warehouse (Medallion Architecture)**:
   - **Raw Layer**: External tables pointing to GCS.
   - **Staging Layer**: Data cleaning, type casting, and deduplication.
   - **Mart Layer**: Final fact tables with growth metrics (MoM, YoY).
4. **Orchestration**: **Bruin** manages the entire dependency graph.
5. **Visualization**: **Looker Studio** for temporal and categorical analysis.

## 🛠️ Tech Stack
- **Cloud**: Google Cloud Platform (GCS, BigQuery)
- **IaC**: Terraform
- **Orchestration**: Bruin
- **Languages**: Python (Ingestion), SQL (Transformations)
- **Visualization**: Looker Studio

## 📂 Project Structure
```text
DEZoomcamp26/
├── infra/                # Terraform configuration files
├── assets/
│   ├── ingestion/       # Python extraction scripts
│   ├── raw/             # BigQuery raw layer definitions
│   ├── staging/         # SQL cleaning and standardization
│   └── mart/            # SQL final analytical models
├── ai-analyst/          # Metadata for Bruin AI data analyst
├── docs/                # Project documentation
└── pipeline.yml         # Bruin pipeline definition
```

## 🚀 Getting Started

### Prerequisites
- Google Cloud Project with Billing enabled
- EIA API Key (Get one here)
- Terraform and Bruin installed

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/DEZoomcamp26.git
   ```
2. Setup Environment:
   ```bash
   cp .env.example .env
   # Fill in your API keys and Project ID
   ```
3. Run Pipeline:
   ```bash
   bruin run .
   ```

---

## 🇮🇩 Bahasa Indonesia

### Ringkasan Proyek
Proyek ini membangun pipeline data end-to-end untuk menganalisis produksi crude oil bulanan di Amerika Serikat menggunakan data publik dari EIA.

### Alur Kerja:
1. **Ingestion**: Mengambil data dari EIA API v2.
2. **Data Lake**: Menyimpan data mentah ke GCS dalam format Parquet.
3. **Data Warehouse**: Memproses data di BigQuery melalui layer Raw, Staging, dan Mart.
4. **Orchestration**: Menggunakan Bruin untuk mengatur jadwal dan ketergantungan antar aset.
5. **Visualisasi**: Menyajikan data melalui dashboard interaktif di Looker Studio.

### Dashboard Utama:
Dashboard kami dirancang untuk menjawab metrik kunci produksi:
- **Tren Temporal**: Grafik garis yang menunjukkan tren produksi bulanan dari 2024-2025.
- **Distribusi Kategorikal**: Grafik batang yang menunjukkan kontribusi produksi per negara bagian (State).

**Buka Report Looker Studio**

### Cara Menjalankan:
1. Pastikan Anda memiliki Service Account GCP dengan akses BigQuery dan GCS.
2. Jalankan `bruin validate .` untuk memastikan semua koneksi benar.
3. Jalankan `bruin run .` untuk mengeksekusi pipeline dari awal hingga akhir.

### Catatan Bruin AI Analyst:
Proyek ini mendukung fitur AI Analyst dari Bruin. Dokumentasi metadata dapat ditemukan di folder `ai-analyst/` yang memungkinkan analisis data menggunakan bahasa alami melalui Bruin CLI.

---

*Developed as a Capstone Project for Data Engineering Zoomcamp 2026.*

---

## English

### Project Summary

This project builds an end-to-end data pipeline to analyze monthly U.S. `crude oil production` using public EIA data.

Main flow:

1. Extract crude oil data from the EIA API
2. Store raw data in Google Cloud Storage as parquet
3. Load the raw data into the BigQuery raw layer
4. Clean and standardize the data in the staging layer
5. Build a mart table for analytics and dashboarding
6. Visualize the final result in Looker Studio

### Agreed Scope

The project is now intentionally limited to `crude oil production` only, rather than combining crude oil and natural gas.

The final dashboard will focus on:

- 1 categorical distribution tile
- 1 temporal distribution tile

### Core Business Questions

- How has U.S. crude oil production changed month by month over time?
- Which states are consistently the largest crude oil producers?
- Is production concentrated in only a few states?
- When do the most notable production increases or declines occur?

### Final Dashboard

The minimum dashboard will contain 2 main tiles:

1. `Line chart`
   Showing monthly crude oil production over `period`

2. `Bar chart`
   Showing crude oil production distribution by `state_name`

This directly matches the evaluation guidance:

- one categorical graph
- one temporal graph

### High-Level Architecture

```text
EIA API
  -> Python ingestion
  -> GCS raw parquet
  -> BigQuery raw
  -> BigQuery staging
  -> BigQuery mart
  -> Looker Studio dashboard
```

### Technology Stack

- `GCP`
- `Terraform`
- `Bruin`
- `BigQuery`
- `Looker Studio`

### Target Project Structure

```text
DEZoomcamp26/
├── infra/
├── assets/
│   ├── ingestion/
│   ├── raw/
│   ├── staging/
│   └── mart/
├── .github/workflows/
├── .bruin.yml
├── .env.example
├── requirements.txt
├── README.md
└── project-plan.md
```

### Current Status

Current phase:

- the project scope has been locked
- ingestion, raw, staging, and mart layers have been built
- the pipeline has been wrapped as Bruin assets
- `bruin validate .` passes successfully

### Running with Bruin

1. Copy the Bruin config:

```bash
cp .bruin.yml.example .bruin.yml
```

2. Export environment variables:

```bash
set -a
source .env
set +a
export PATH=$HOME/.local/bin:$PATH
export BRUIN_HOME=/tmp/.bruin
```

3. Validate the pipeline:

```bash
bruin validate .
```

4. Run the pipeline:

```bash
bruin run .
```

Bruin flow in this project:

- `ingestion.eia_crude_oil_to_gcs`
- `raw.load_crude_oil_raw`
- `staging.stg_crude_oil_production`
- `mart.fct_crude_oil_production`

Bruin reads the `depends` graph and executes the assets in dependency order.

### Bruin Competition Notes

To support the Bruin competition requirements:

- ingestion is executed as a Bruin Python asset
- transformations are executed as Bruin SQL assets on BigQuery
- orchestration runs through `bruin run`
- an `AI data analyst` guide is included in [docs/bruin-ai-analyst.md](/workspaces/DEZoomcamp26/docs/bruin-ai-analyst.md:1)

### Evaluation Goals

This project is designed to demonstrate:

- a clear problem statement
- a working end-to-end pipeline
- cloud storage and a data warehouse
- orchestration
- infrastructure as code
- a relevant final dashboard
