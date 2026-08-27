terraform {
  required_version = ">= 1.0"
}

resource "null_resource" "exec_script" {
  triggers = {
    project_id = var.gcp_project_id
    region     = var.gcp_region
    zone       = var.gcp_zone
  }

  provisioner "local-exec" {
    command = "chmod +x ${path.module}/scripts/script.sh && ${path.module}/scripts/script.sh ${var.gcp_project_id} ${var.gcp_region} ${var.gcp_zone}"
  }
}
