# Project Implementation Plan

Dokumen ini adalah panduan kerja step by step untuk menyelesaikan capstone Data Engineering Zoomcamp 2026 dengan scope yang sudah dikunci.

## 1. Scope Final

Scope final proyek:

- domain: `U.S. crude oil production`
- source utama: `EIA API`
- cloud: `GCP`
- IaC: `Terraform`
- orchestration: `Bruin`
- warehouse: `BigQuery`
- dashboard: `Looker Studio`

Scope ini sengaja dipersempit agar:

- implementasi lebih realistis
- cerita project lebih tajam
- dashboard lebih fokus
- lebih mudah dipresentasikan saat review

## 2. Pertanyaan Dashboard yang Dikunci

Pertanyaan utama yang akan dijawab:

- Bagaimana tren produksi crude oil AS per bulan dari tahun ke tahun?
- State mana yang konsisten menjadi produsen crude oil terbesar?
- Apakah kontribusi produksi terkonsentrasi di beberapa state saja?
- Kapan terjadi lonjakan atau penurunan produksi yang paling menonjol?

## 3. Mapping ke Kriteria Penilaian Dashboard

Requirement minimal dashboard:

- 1 grafik distribusi kategorikal
- 1 grafik distribusi temporal

Mapping-nya:

1. `Temporal line chart`
   Menjawab:
   - tren produksi dari waktu ke waktu
   - lonjakan atau penurunan yang paling menonjol

2. `Categorical bar chart`
   Menjawab:
   - state dengan produksi terbesar
   - tingkat konsentrasi produksi antar state

## 4. Dashboard yang Akan Dibangun

Tile minimum final:

1. `Monthly Crude Oil Production Trend`
   - chart type: `line chart`
   - dimension: `period`
   - metric: `total_production`

2. `Crude Oil Production by State`
   - chart type: `bar chart`
   - dimension: `state_name`
   - metric: `total_production`

Metric tambahan yang sebaiknya tersedia di mart:

- `mom_change_pct`
- `yoy_change_pct`
- `share_of_total_pct`
- `production_year`
- `production_month`

## 5. Flow Besar Proyek

Flow proyek yang harus Anda pahami:

1. EIA API mengembalikan data crude oil dalam format JSON
2. Python ingestion mengambil data dan mengubahnya menjadi parquet
3. File parquet disimpan ke GCS sebagai raw data lake
4. Data dimuat ke BigQuery raw
5. Data dibersihkan dan distandarkan di staging
6. Data diagregasi di mart
7. Looker Studio membaca tabel mart
8. Bruin mengatur urutan eksekusi
9. Terraform membuat resource cloud secara repeatable

## 6. Step by Step Implementation

### Step 1 — Setup GCP dan fondasi repo

Tujuan step ini:

- menyiapkan project GCP
- menentukan naming convention
- menyiapkan file environment
- menyiapkan file Terraform awal

Yang perlu Anda miliki:

- 1 GCP project untuk capstone
- billing aktif
- EIA API key

API GCP yang perlu di-enable:

- BigQuery API
- Cloud Storage API
- IAM API

Output Step 1:

- `project_id`
- `region`
- `bucket name convention`
- service account name yang akan dipakai pipeline
- file `infra/` awal di repo
- file `.env.example`

Checklist Step 1:

- tentukan `project_id`
- tentukan `region`, misalnya `us-central1`
- tentukan prefix resource, misalnya `dezoomcamp26`
- siapkan nama bucket raw
- siapkan nama service account

Naming convention yang disarankan:

- raw bucket: `<project-id>-crude-oil-raw`
- datasets:
  - `crude_oil_raw`
  - `crude_oil_staging`
  - `crude_oil_mart`
- service account: `bruin-crude-oil-sa`

### Step 2 — Terraform resources

Resource minimum:

- 1 GCS bucket
- 3 BigQuery datasets
- 1 service account
- IAM role untuk BigQuery dan GCS

Target file:

- `infra/main.tf`
- `infra/variables.tf`
- `infra/outputs.tf`
- `infra/terraform.tfvars`
- `infra/providers.tf`

### Step 3 — Eksplorasi schema EIA crude oil

Tujuan:

- memahami field dari response API
- memilih field raw dan field final

Field penting yang perlu dipertahankan:

- `period`
- `area-name`
- `area`
- `value`
- `units`
- deskripsi series atau product jika ada

### Step 4 — Ingestion Python ke GCS

Target:

- fetch data crude oil
- simpan ke parquet
- upload ke GCS

### Step 5 — Raw layer di BigQuery

Target:

- memuat data mentah ke dataset `crude_oil_raw`

### Step 6 — Staging layer

Target:

- cast tipe data
- rename kolom
- filter invalid rows
- standarisasi state

### Step 7 — Mart layer

Target:

- membuat `fct_crude_oil_production`
- menghitung metrik dashboard

### Step 8 — Orchestration dengan Bruin

Target:

- seluruh dependency antar asset berjalan benar

### Step 9 — Dashboard di Looker Studio

Target:

- 2 tile sesuai rubric
- visual sederhana dan jelas

### Step 10 — Finalisasi submission

Target:

- README sinkron dengan implementasi
- screenshot tersedia
- repo mudah dipahami reviewer

## 7. Definition of Done

Project dianggap siap submit jika:

- Terraform bisa membuat resource utama
- data crude oil berhasil masuk ke GCS
- data tersedia di BigQuery raw, staging, dan mart
- Bruin bisa menjalankan pipeline end-to-end
- dashboard menampilkan minimal 2 tile sesuai rubric
- README sesuai keadaan repo
- Anda bisa menjelaskan flow proyek tanpa meloncat-loncat

## 8. Status Saat Ini

Status terkini:

- scope final sudah dikunci
- pertanyaan dashboard sudah dikunci
- README sudah disejajarkan dengan scope baru
- Step 1 sudah selesai
- Terraform berhasil membuat resource utama di GCP
- output Terraform sudah terverifikasi
- project saat ini siap masuk ke tahap eksplorasi schema EIA crude oil dan pembuatan ingestion

Resource yang sudah berhasil dibuat:

- GCS bucket: `dezoomcamp2026-493003-crude-oil-raw`
- BigQuery dataset raw: `crude_oil_raw`
- BigQuery dataset staging: `crude_oil_staging`
- BigQuery dataset mart: `crude_oil_mart`
- Pipeline service account:
  `bruin-crude-oil-sa@dezoomcamp2026-493003.iam.gserviceaccount.com`

Catatan sesi ini:

- `terraform init` berhasil
- `terraform plan` berhasil
- `terraform apply` berhasil setelah IAM API, BigQuery API, dan Cloud Storage API di-enable
- autentikasi Terraform menggunakan service account key di `.secrets/gcp-sa-key.json`

Hal yang perlu dilanjutkan nanti malam:

1. mulai `Step 3` dengan eksplorasi schema endpoint EIA crude oil
2. tentukan field raw yang akan disimpan
3. buat skeleton folder `assets/ingestion`, `assets/raw`, `assets/staging`, dan `assets/mart`
4. buat `requirements.txt`
5. mulai implementasi `eia_fetch.py`

Catatan keamanan:

- `.secrets/` sudah di-ignore dan tidak boleh di-commit
- `infra/terraform.tfvars` sudah di-ignore dan tidak boleh di-commit
- `EIA_API_KEY` sempat terekspos di sesi ini, jadi sebaiknya di-regenerate sebelum pipeline final dipakai

## 9. Fokus Praktis Berikutnya

Setelah Step 1 ini, urutan kerja kita adalah:

1. eksplorasi schema data crude oil dari EIA
2. definisikan schema raw dan schema staging
3. buat script ingestion Python
4. upload parquet ke GCS
5. lanjut ke raw, staging, dan mart layer di BigQuery
