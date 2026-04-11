terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "raw_data" {
  name          = "${var.project_id}-energy-raw"
  location      = var.region
  force_destroy = true

  lifecycle_rule {
    condition { age = 90 }
    action    { type = "Delete" }
  }

  uniform_bucket_level_access = true
}

resource "google_bigquery_dataset" "raw" {
  dataset_id  = "energy_raw"
  location    = var.region
  description = "Raw ingested data from EIA API"

  delete_contents_on_destroy = true
}

resource "google_bigquery_dataset" "staging" {
  dataset_id  = "energy_staging"
  location    = var.region
  description = "Cleaned and validated data"

  delete_contents_on_destroy = true
}

resource "google_bigquery_dataset" "mart" {
  dataset_id  = "energy_mart"
  location    = var.region
  description = "Aggregated, dashboard-ready data"

  delete_contents_on_destroy = true
}

resource "google_service_account" "bruin_sa" {
  account_id   = "bruin-pipeline-sa"
  display_name = "Bruin Pipeline Service Account"
}

resource "google_project_iam_member" "bq_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.bruin_sa.email}"
}

resource "google_project_iam_member" "bq_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.bruin_sa.email}"
}

resource "google_project_iam_member" "gcs_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.bruin_sa.email}"
}

resource "google_service_account_key" "bruin_sa_key" {
  service_account_id = google_service_account.bruin_sa.name
}

resource "local_file" "sa_key_file" {
  content  = base64decode(google_service_account_key.bruin_sa_key.private_key)
  filename = "${path.module}/../.secrets/gcp-sa-key.json"
}
