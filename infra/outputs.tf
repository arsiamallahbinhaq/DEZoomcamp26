output "gcs_bucket_name" {
  description = "Nama GCS bucket untuk raw data"
  value       = google_storage_bucket.raw_data.name
}

output "bq_raw_dataset" {
  value = google_bigquery_dataset.raw.dataset_id
}

output "bq_staging_dataset" {
  value = google_bigquery_dataset.staging.dataset_id
}

output "bq_mart_dataset" {
  value = google_bigquery_dataset.mart.dataset_id
}

output "service_account_email" {
  value = google_service_account.bruin_sa.email
}
