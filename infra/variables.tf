variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Default GCP region"
  type        = string
  default     = "us-central1"
}

variable "raw_bucket_name" {
  description = "GCS bucket name for crude oil raw data"
  type        = string
}

variable "service_account_id" {
  description = "Service account ID for the pipeline"
  type        = string
  default     = "bruin-crude-oil-sa"
}

variable "raw_dataset_id" {
  description = "BigQuery raw dataset ID"
  type        = string
  default     = "crude_oil_raw"
}

variable "staging_dataset_id" {
  description = "BigQuery staging dataset ID"
  type        = string
  default     = "crude_oil_staging"
}

variable "mart_dataset_id" {
  description = "BigQuery mart dataset ID"
  type        = string
  default     = "crude_oil_mart"
}
