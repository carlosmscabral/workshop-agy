# Mandatory runtime variables populated automatically by Qwiklabs backend
variable "gcp_project_id" {
  type        = string
  description = "The GCP project ID allocated for the lab sandbox."
}

variable "gcp_region" {
  type        = string
  description = "The default GCP region allocated for the lab (e.g. us-central1)."
}

variable "gcp_zone" {
  type        = string
  description = "The default GCP zone allocated for the lab (e.g. us-central1-a)."
}

variable "service_account_key_file" {
  type        = string
  description = "Path to the service account key file used by Qwiklabs."
}
