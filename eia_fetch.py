"""
Bruin Python asset: EIA Petroleum Production → GCS
Fetch monthly crude oil + natural gas production data by state dari EIA API v2
dan simpan sebagai parquet ke GCS bucket.
"""

import os
import json
import time
import requests
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
from datetime import datetime
from google.cloud import storage


# ── Config ───────────────────────────────────────────────────────────────────
EIA_API_KEY   = os.environ["EIA_API_KEY"]
GCS_BUCKET    = os.environ["GCS_BUCKET_NAME"]
START_DATE    = "2015-01"
END_DATE      = datetime.now().strftime("%Y-%m")
MAX_ROWS      = 5000  # EIA API limit per request


# ── EIA API endpoints ─────────────────────────────────────────────────────────
ENDPOINTS = {
    "petroleum": {
        "url": "https://api.eia.gov/v2/petroleum/crd/crpdn/data/",
        "data_cols": ["value"],
        "description": "Crude oil production by state (Mbbl/month)",
    },
    "natural_gas": {
        "url": "https://api.eia.gov/v2/natural-gas/prod/sum/data/",
        "data_cols": ["value"],
        "description": "Natural gas production by state (MMcf/month)",
    },
}


def fetch_eia_data(url: str, offset: int = 0) -> dict:
    """Fetch satu halaman data dari EIA API v2."""
    params = {
        "api_key":    EIA_API_KEY,
        "frequency":  "monthly",
        "data[0]":    "value",
        "start":      START_DATE,
        "end":        END_DATE,
        "sort[0][column]": "period",
        "sort[0][direction]": "asc",
        "length":     MAX_ROWS,
        "offset":     offset,
    }
    resp = requests.get(url, params=params, timeout=30)
    resp.raise_for_status()
    return resp.json()


def fetch_all_pages(url: str, energy_type: str) -> pd.DataFrame:
    """Loop semua halaman sampai habis (EIA max 5000 rows/request)."""
    all_records = []
    offset = 0

    while True:
        print(f"  Fetching {energy_type} — offset {offset}...")
        data = fetch_eia_data(url, offset)

        records = data.get("response", {}).get("data", [])
        if not records:
            break

        all_records.extend(records)
        total = data.get("response", {}).get("total", 0)
        offset += MAX_ROWS

        if offset >= int(total):
            break

        time.sleep(0.5)  # Jangan spam API

    df = pd.DataFrame(all_records)
    df["energy_type"] = energy_type
    df["_ingested_at"] = datetime.utcnow().isoformat()
    return df


def clean_dataframe(df: pd.DataFrame) -> pd.DataFrame:
    """Basic type casting dan rename kolom agar konsisten."""
    rename_map = {
        "period":      "period",
        "duoarea":     "area_code",
        "area-name":   "area_name",
        "product":     "product_code",
        "product-name": "product_name",
        "process":     "process_code",
        "process-name": "process_name",
        "series":      "series_id",
        "series-description": "series_description",
        "value":       "value",
        "units":       "unit",
    }
    df = df.rename(columns={k: v for k, v in rename_map.items() if k in df.columns})

    if "period" in df.columns:
        df["period"] = pd.to_datetime(df["period"], format="%Y-%m", errors="coerce")
        df["year"]   = df["period"].dt.year
        df["month"]  = df["period"].dt.month

    if "value" in df.columns:
        df["value"] = pd.to_numeric(df["value"], errors="coerce")

    return df


def upload_to_gcs(df: pd.DataFrame, energy_type: str, bucket_name: str):
    """Upload dataframe sebagai parquet ke GCS dengan partisi year/month."""
    client  = storage.Client()
    bucket  = client.bucket(bucket_name)

    # Partisi per tahun untuk efisiensi
    for year, year_df in df.groupby("year"):
        blob_path = f"raw/{energy_type}/year={year}/data.parquet"
        blob      = bucket.blob(blob_path)

        table  = pa.Table.from_pandas(year_df)
        buf    = pa.BufferOutputStream()
        pq.write_table(table, buf)

        blob.upload_from_string(buf.getvalue().to_pybytes(), content_type="application/octet-stream")
        print(f"  Uploaded: gs://{bucket_name}/{blob_path} ({len(year_df)} rows)")


def main():
    print(f"=== EIA Energy Data Ingestion ===")
    print(f"Period: {START_DATE} → {END_DATE}")
    print(f"Target bucket: gs://{GCS_BUCKET}\n")

    for energy_type, config in ENDPOINTS.items():
        print(f"[{energy_type.upper()}] {config['description']}")

        df = fetch_all_pages(config["url"], energy_type)
        print(f"  Total rows fetched: {len(df)}")

        df = clean_dataframe(df)
        upload_to_gcs(df, energy_type, GCS_BUCKET)
        print(f"  Done.\n")

    print("=== Ingestion complete ===")


if __name__ == "__main__":
    main()
