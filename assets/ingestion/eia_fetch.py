"""@bruin
name: ingestion.eia_crude_oil_to_gcs
description: Fetch monthly crude oil production data from the EIA API and store the raw extract as parquet in GCS.
image: python:3.12
secrets:
  - key: EIA_API_KEY
  - key: GCS_BUCKET_NAME
  - key: GOOGLE_APPLICATION_CREDENTIALS
tags:
  - ingestion
  - eia
  - gcs
  - crude-oil
@bruin"""

from __future__ import annotations

import argparse
import os
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import pandas as pd
import requests
from dotenv import load_dotenv
from google.cloud import storage

BASE_URL = "https://api.eia.gov/v2/petroleum/crd/crpdn/data/"
PAGE_SIZE = 5000
DEFAULT_PRODUCT = "EPC0"
DEFAULT_PROCESS = "FPF"
DEFAULT_FREQUENCY = "monthly"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Fetch EIA crude oil production data and upload raw parquet to GCS."
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=None,
        help="Optional row limit for testing. If omitted, fetches every page.",
    )
    parser.add_argument(
        "--skip-upload",
        action="store_true",
        help="Write parquet locally but do not upload to GCS.",
    )
    return parser.parse_args()


def require_env(name: str) -> str:
    value = os.getenv(name)
    if not value:
        raise ValueError(f"Missing required environment variable: {name}")
    return value


def fetch_page(
    session: requests.Session,
    api_key: str,
    offset: int,
    length: int,
) -> dict[str, Any]:
    params: list[tuple[str, str]] = [
        ("api_key", api_key),
        ("frequency", DEFAULT_FREQUENCY),
        ("data[]", "value"),
        ("facets[product][]", DEFAULT_PRODUCT),
        ("facets[process][]", DEFAULT_PROCESS),
        ("sort[0][column]", "period"),
        ("sort[0][direction]", "desc"),
        ("offset", str(offset)),
        ("length", str(length)),
    ]
    response = session.get(BASE_URL, params=params, timeout=60)
    response.raise_for_status()
    payload = response.json()
    if "response" not in payload:
        raise ValueError(f"Unexpected EIA response: {payload}")
    return payload


def fetch_all_records(api_key: str, limit: int | None = None) -> list[dict[str, Any]]:
    session = requests.Session()
    all_records: list[dict[str, Any]] = []
    offset = 0
    total_expected: int | None = None

    while True:
        remaining = None if limit is None else max(limit - len(all_records), 0)
        if remaining == 0:
            break

        page_length = PAGE_SIZE if remaining is None else min(PAGE_SIZE, remaining)
        payload = fetch_page(session, api_key=api_key, offset=offset, length=page_length)
        response = payload["response"]
        page_records = response.get("data", [])
        total_expected = int(response["total"])

        if not page_records:
            break

        all_records.extend(page_records)
        offset += len(page_records)

        if len(page_records) < page_length:
            break

        if limit is None and len(all_records) >= total_expected:
            break

    return all_records


def normalize_records(records: list[dict[str, Any]]) -> pd.DataFrame:
    df = pd.DataFrame(records)
    rename_map = {
        "area-name": "area_name",
        "product-name": "product_name",
        "process-name": "process_name",
        "series-description": "series_description",
    }
    df = df.rename(columns=rename_map)

    ingested_at = datetime.now(timezone.utc)
    load_date = ingested_at.date().isoformat()

    df["period"] = pd.to_datetime(df["period"], format="%Y-%m", errors="coerce")
    df["value_numeric"] = pd.to_numeric(df["value"], errors="coerce")
    df["ingested_at"] = ingested_at.isoformat()
    df["load_date"] = load_date
    df["source_name"] = "eia_crude_oil_production"
    df["source_endpoint"] = BASE_URL

    ordered_columns = [
        "period",
        "duoarea",
        "area_name",
        "product",
        "product_name",
        "process",
        "process_name",
        "series",
        "series_description",
        "value",
        "value_numeric",
        "units",
        "ingested_at",
        "load_date",
        "source_name",
        "source_endpoint",
    ]
    return df[ordered_columns]


def build_gcs_path(load_date: str) -> str:
    return f"raw/crude_oil/load_date={load_date}/data.parquet"


def write_parquet(df: pd.DataFrame) -> Path:
    tmp_dir = Path(tempfile.mkdtemp(prefix="eia_crude_oil_"))
    file_path = tmp_dir / "crude_oil_raw.parquet"
    df.to_parquet(file_path, index=False)
    return file_path


def upload_to_gcs(local_path: Path, bucket_name: str, blob_name: str) -> None:
    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(blob_name)
    blob.upload_from_filename(str(local_path))


def main() -> None:
    load_dotenv()
    args = parse_args()

    api_key = require_env("EIA_API_KEY")
    bucket_name = require_env("GCS_BUCKET_NAME")

    records = fetch_all_records(api_key=api_key, limit=args.limit)
    if not records:
        raise ValueError("No records returned from EIA API.")

    df = normalize_records(records)
    parquet_path = write_parquet(df)
    blob_name = build_gcs_path(df["load_date"].iloc[0])

    if not args.skip_upload:
        upload_to_gcs(parquet_path, bucket_name=bucket_name, blob_name=blob_name)

    print(
        {
            "rows_fetched": len(df),
            "local_parquet": str(parquet_path),
            "gcs_path": f"gs://{bucket_name}/{blob_name}" if not args.skip_upload else None,
            "min_period": df["period"].min().date().isoformat(),
            "max_period": df["period"].max().date().isoformat(),
        }
    )


if __name__ == "__main__":
    main()
