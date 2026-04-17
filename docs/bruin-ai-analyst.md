# Bruin AI Analyst

Dokumen ini menunjukkan langkah minimum agar proyek ini memenuhi syarat kompetisi Bruin pada bagian `analysis using the AI data analyst`.

## 1. Siapkan koneksi Bruin

1. Copy `.bruin.yml.example` menjadi `.bruin.yml`
2. Load environment variables
3. Pastikan koneksi BigQuery dapat dipakai oleh Bruin

```bash
cp .bruin.yml.example .bruin.yml
source .env
```

## 2. Import konteks database

Import schema mart ke folder AI analyst terpisah:

```bash
bruin import database --connection gcp --schema crude_oil_mart ai-analyst
bruin import database --connection gcp --schema crude_oil_staging ai-analyst
```

Status saat ini di repo ini:

- `ai-analyst/assets/crude_oil_mart/fct_crude_oil_production.asset.yml` sudah berhasil dibuat
- `ai-analyst/assets/crude_oil_staging/stg_crude_oil_production.asset.yml` sudah berhasil dibuat
- `bruin validate ai-analyst` sudah berhasil

## 3. Enhance metadata dengan AI

Jika Anda memakai Codex CLI:

```bash
bruin ai enhance ai-analyst --codex
```

Jika Anda memakai Claude Code:

```bash
bruin ai enhance ai-analyst --claude
```

Catatan:

- di environment kerja saat ini, provider CLI untuk `bruin ai enhance` belum terpasang
- jadi langkah enhancement AI belum dijalankan otomatis di sesi ini
- begitu `Codex CLI` atau `Claude Code` tersedia, command di atas bisa langsung dijalankan

## 4. Query sebagai AI analyst

Contoh analisis yang bisa Anda tunjukkan:

```bash
bruin query --connection gcp --query "
SELECT
  period,
  state_name,
  total_production,
  share_of_total_pct
FROM \`dezoomcamp2026-493003.crude_oil_mart.fct_crude_oil_production\`
ORDER BY period DESC, total_production DESC
LIMIT 10
" --description "Inspect top state producers for the dashboard narrative"
```

Query ini sudah berhasil dijalankan di repo ini melalui `bruin query`.

## 5. Bukti untuk kompetisi

Saat posting ke komunitas Bruin, sertakan bahwa Anda sudah:

- menjalankan pipeline utama dengan `bruin run`
- menggunakan `bruin ai enhance`
- menggunakan `bruin query` untuk analisis data mart
