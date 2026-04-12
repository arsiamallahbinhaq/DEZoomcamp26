output "raw_bucket_name" {
  value = google_storage_bucket.raw_bucket.name
}

output "raw_dataset_id" {
  value = google_bigquery_dataset.raw.dataset_id
}

output "staging_dataset_id" {
  value = google_bigquery_dataset.staging.dataset_id
}

output "mart_dataset_id" {
  value = google_bigquery_dataset.mart.dataset_id
}

output "pipeline_service_account_email" {
  value = google_service_account.pipeline.email
}
