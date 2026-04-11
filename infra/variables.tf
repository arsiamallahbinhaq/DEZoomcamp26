variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region untuk resource project"
  type        = string
  default     = "us-central1"
}
