resource "google_storage_bucket" "raw_bucket" {
  name                        = var.raw_bucket_name
  location                    = var.region
  force_destroy               = false
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

resource "google_bigquery_dataset" "raw" {
  dataset_id = var.raw_dataset_id
  location   = var.region
}

resource "google_bigquery_dataset" "staging" {
  dataset_id = var.staging_dataset_id
  location   = var.region
}

resource "google_bigquery_dataset" "mart" {
  dataset_id = var.mart_dataset_id
  location   = var.region
}

resource "google_service_account" "pipeline" {
  account_id   = var.service_account_id
  display_name = "Bruin Crude Oil Pipeline Service Account"
}

resource "google_project_iam_member" "pipeline_bigquery_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.pipeline.email}"
}

resource "google_project_iam_member" "pipeline_bigquery_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.pipeline.email}"
}

resource "google_project_iam_member" "pipeline_storage_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.pipeline.email}"
}
