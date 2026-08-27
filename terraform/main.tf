module "cli" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 3.0.1"

  platform = "linux"

  additional_components = ["beta"]

  create_cmd_entrypoint = "chmod +x ${path.module}/scripts/script.sh; ${path.module}/scripts/script.sh"
  create_cmd_body       = "${var.gcp_project_id} ${var.gcp_region} ${var.gcp_zone}"

  skip_download = false
  upgrade       = false

  gcloud_sdk_version = "420.0.0"

  service_account_key_file = var.service_account_key_file
}
