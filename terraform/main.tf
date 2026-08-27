terraform {
  required_version = ">= 1.0"
}

provider "google" {
  project     = var.gcp_project_id
  region      = var.gcp_region
  zone        = var.gcp_zone
  credentials = var.service_account_key_file
}

resource "google_storage_bucket" "test_bucket" {
  name                        = "${var.gcp_project_id}-test"
  location                    = var.gcp_region
  uniform_bucket_level_access = true
  force_destroy               = true
}
