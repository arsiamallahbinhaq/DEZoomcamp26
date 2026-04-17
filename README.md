# Crude Oil Production Analytics Pipeline
> Data Engineering Zoomcamp 2026 Capstone Project

This repository contains an end-to-end data engineering project that analyzes monthly U.S. crude oil production using GCP, Terraform, Bruin, BigQuery, and Looker Studio.

Dokumen ini disediakan dalam dua bahasa:

- [Bahasa Indonesia](#bahasa-indonesia)
- [English](#english)

---

## Bahasa Indonesia

### Ringkasan Proyek

Project ini membangun pipeline data end-to-end untuk menganalisis produksi `crude oil` bulanan di Amerika Serikat dari data publik EIA.

Alur utamanya:

1. Mengambil data crude oil dari EIA API
2. Menyimpan data mentah ke Google Cloud Storage dalam format parquet
3. Memuat data ke BigQuery raw layer
4. Membersihkan dan menstandarkan data di staging layer
5. Membuat tabel mart untuk dashboard
6. Menampilkan insight di Looker Studio

### Scope yang Disepakati

Project ini sekarang difokuskan hanya pada `crude oil production`, bukan crude oil dan natural gas sekaligus.

Fokus dashboard akhir:

- 1 tile distribusi kategorikal
- 1 tile distribusi temporal

### Pertanyaan Bisnis Utama

- Bagaimana tren produksi crude oil AS per bulan dari tahun ke tahun?
- State mana yang konsisten menjadi produsen crude oil terbesar?
- Apakah kontribusi produksi terkonsentrasi di beberapa state saja?
- Kapan terjadi lonjakan atau penurunan produksi yang paling menonjol?

### Dashboard Akhir

Dashboard minimum akan berisi 2 tile utama:

1. `Line chart`
   Menampilkan tren produksi crude oil bulanan berdasarkan `period`

2. `Bar chart`
   Menampilkan distribusi produksi crude oil berdasarkan `state_name`

Dengan desain ini, requirement penilaian tetap terpenuhi:

- satu grafik kategorikal
- satu grafik temporal

### Arsitektur Singkat

```text
EIA API
  -> Python ingestion
  -> GCS raw parquet
  -> BigQuery raw
  -> BigQuery staging
  -> BigQuery mart
  -> Looker Studio dashboard
```

### Teknologi yang Digunakan

- `GCP`
- `Terraform`
- `Bruin`
- `BigQuery`
- `Looker Studio`

### Struktur Proyek yang Dituju

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

### Status Saat Ini

Tahap sekarang:

- scope project sudah dikunci
- ingestion, raw, staging, dan mart layer sudah berhasil dibuat
- pipeline sudah dibungkus sebagai asset Bruin
- `bruin validate .` sudah berhasil

### Menjalankan dengan Bruin

1. Copy konfigurasi Bruin:

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

3. Validasi pipeline:

```bash
bruin validate .
```

4. Jalankan pipeline:

```bash
bruin run .
```

Flow Bruin di project ini:

- `ingestion.eia_crude_oil_to_gcs`
- `raw.load_crude_oil_raw`
- `staging.stg_crude_oil_production`
- `mart.fct_crude_oil_production`

Bruin membaca `depends` antar asset dan mengeksekusinya dalam urutan yang benar.

### Bruin Competition Notes

Untuk mendukung kriteria kompetisi Bruin:

- ingestion dijalankan lewat asset Python Bruin
- transformation dijalankan lewat asset SQL Bruin di BigQuery
- orchestration dijalankan lewat `bruin run`
- panduan `AI data analyst` disiapkan di [docs/bruin-ai-analyst.md](/workspaces/DEZoomcamp26/docs/bruin-ai-analyst.md:1)

### Kriteria Nilai yang Ditargetkan

Project ini dirancang untuk menunjukkan:

- problem statement yang jelas
- pipeline end-to-end
- cloud storage dan data warehouse
- orchestration
- infrastructure as code
- dashboard akhir yang relevan

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
