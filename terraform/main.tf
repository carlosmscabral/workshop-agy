resource "google_storage_bucket" "geap_bucket" {
  name                        = "${var.gcp_project_id}-geap-artifacts"
  location                    = var.gcp_region
  uniform_bucket_level_access = true
  force_destroy               = true
}

module "cli" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 3.0.1"

  platform = "linux"

  create_cmd_entrypoint = "chmod +x ${path.module}/scripts/script.sh; ${path.module}/scripts/script.sh"
  create_cmd_body       = "${var.gcp_project_id} ${var.gcp_region} ${var.gcp_zone} ${var.service_account_key_file}"

  skip_download = false
  upgrade       = false

  service_account_key_file = var.service_account_key_file

  depends_on = [google_storage_bucket.geap_bucket]
}
