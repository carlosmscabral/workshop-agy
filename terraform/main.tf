terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

module "cli" {
  source                   = "terraform-google-modules/gcloud/google"
  version                  = "~> 3.0.1"
  platform                 = "linux"
  additional_components    = ["beta"]

  # Ensure the script is executable and run it with clean string interpolation
  create_cmd_entrypoint    = "chmod +x ${path.module}/scripts/script.sh; ${path.module}/scripts/script.sh"

  # Pass Qwiklabs variables as positional arguments: $1 = project_id, $2 = region, $3 = zone
  create_cmd_body          = "${var.gcp_project_id} ${var.gcp_region} ${var.gcp_zone}"

  skip_download            = false
  upgrade                  = false
  gcloud_sdk_version       = "480.0.0"
  service_account_key_file = var.service_account_key_file
}
