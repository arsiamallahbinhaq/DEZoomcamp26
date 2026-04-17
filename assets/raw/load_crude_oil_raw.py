"""@bruin
name: raw.load_crude_oil_raw
description: Load raw crude oil parquet files from GCS into the BigQuery raw dataset.
image: python:3.12
depends:
  - ingestion.eia_crude_oil_to_gcs
secrets:
  - key: GCP_PROJECT_ID
  - key: GCS_BUCKET_NAME
  - key: GCP_REGION
  - key: GOOGLE_APPLICATION_CREDENTIALS
tags:
  - raw
  - bigquery
  - gcs
  - crude-oil
@bruin"""

from __future__ import annotations

import argparse
import os

from dotenv import load_dotenv
from google.cloud import bigquery

DEFAULT_DATASET = "crude_oil_raw"
DEFAULT_TABLE = "crude_oil_production_raw"
DEFAULT_LOCATION = "us-central1"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Load crude oil parquet files from GCS into a BigQuery raw table."
    )
    parser.add_argument(
        "--source-uri",
        default=None,
        help=(
            "Optional explicit gs:// URI or wildcard URI. "
            "If omitted, the script loads all parquet files under raw/crude_oil/."
        ),
    )
    parser.add_argument(
        "--write-disposition",
        default="WRITE_TRUNCATE",
        choices=["WRITE_TRUNCATE", "WRITE_APPEND", "WRITE_EMPTY"],
        help="BigQuery write disposition for the load job.",
    )
    return parser.parse_args()


def require_env(name: str) -> str:
    value = os.getenv(name)
    if not value:
        raise ValueError(f"Missing required environment variable: {name}")
    return value


def build_source_uri(bucket_name: str) -> str:
    return f"gs://{bucket_name}/raw/crude_oil/load_date=*/data.parquet"


def main() -> None:
    load_dotenv()
    args = parse_args()

    project_id = require_env("GCP_PROJECT_ID")
    bucket_name = require_env("GCS_BUCKET_NAME")
    dataset_id = os.getenv("BQ_RAW_DATASET_ID", DEFAULT_DATASET)
    table_name = os.getenv("BQ_RAW_TABLE_NAME", DEFAULT_TABLE)
    location = os.getenv("GCP_REGION", DEFAULT_LOCATION)

    source_uri = args.source_uri or build_source_uri(bucket_name)
    table_id = f"{project_id}.{dataset_id}.{table_name}"

    client = bigquery.Client(project=project_id)
    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.PARQUET,
        write_disposition=args.write_disposition,
    )

    load_job = client.load_table_from_uri(
        source_uris=source_uri,
        destination=table_id,
        job_config=job_config,
        location=location,
    )
    load_job.result()

    destination_table = client.get_table(table_id)
    print(
        {
            "table_id": table_id,
            "source_uri": source_uri,
            "rows_loaded": destination_table.num_rows,
            "write_disposition": args.write_disposition,
        }
    )


if __name__ == "__main__":
    main()
