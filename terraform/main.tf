terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

provider "google" {
  project     = var.gcp_project_id
  region      = var.gcp_region
  zone        = var.gcp_zone
  credentials = var.service_account_key_file
}

# 1. Enable Core GEAP and Vertex AI APIs
resource "google_project_service" "geap_apis" {
  for_each = toset([
    "serviceusage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "storage.googleapis.com",
    "aiplatform.googleapis.com",
    "discoveryengine.googleapis.com",
    "cloudaicompanion.googleapis.com",
    "notebooks.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "secretmanager.googleapis.com",
    "modelarmor.googleapis.com",
    "pubsub.googleapis.com",
    "eventarc.googleapis.com",
    "bigquery.googleapis.com",
    "bigqueryconnection.googleapis.com",
    "spanner.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "cloudtrace.googleapis.com"
  ])
  project            = var.gcp_project_id
  service            = each.key
  disable_on_destroy = false
}

# 2. Pre-create Artifact Registry repository for Agent containers & Remote MCP
resource "google_artifact_registry_repository" "agent_docker" {
  depends_on    = [google_project_service.geap_apis]
  project       = var.gcp_project_id
  location      = var.gcp_region
  repository_id = "geap-agent-docker"
  description   = "Docker repository for GEAP Custom Agents and MCP servers"
  format        = "DOCKER"
}

# 3. Create Staging Cloud Storage Bucket for Agent Engine
resource "google_storage_bucket" "artifacts" {
  depends_on                  = [google_project_service.geap_apis]
  project                     = var.gcp_project_id
  name                        = "${var.gcp_project_id}-geap-artifacts"
  location                    = var.gcp_region
  uniform_bucket_level_access = true
  force_destroy               = true
}
