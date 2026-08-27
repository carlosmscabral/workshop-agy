resource "google_storage_bucket" "test_bucket" {
  name                        = "${var.gcp_project_id}-test"
  location                    = var.gcp_region
  uniform_bucket_level_access = true
  force_destroy               = true
}
