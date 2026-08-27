#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="$1"
REGION="$2"
ZONE="$3"

echo "================================================================="
echo " Starting GEAP & Vertex AI Agent Engine Lab Setup Automation"
echo " Project: ${PROJECT_ID}"
echo " Region:  ${REGION}"
echo " Zone:    ${ZONE}"
echo "================================================================="

gcloud config set project "${PROJECT_ID}"

# -----------------------------------------------------------------
# 1. Enable Full GEAP Enterprise API Surface
# -----------------------------------------------------------------
echo "[1/4] Enabling GEAP, Vertex AI, Data, Security & Compute APIs..."
gcloud services enable \
  serviceusage.googleapis.com \
  cloudresourcemanager.googleapis.com \
  compute.googleapis.com \
  storage.googleapis.com \
  aiplatform.googleapis.com \
  discoveryengine.googleapis.com \
  cloudaicompanion.googleapis.com \
  notebooks.googleapis.com \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  secretmanager.googleapis.com \
  modelarmor.googleapis.com \
  pubsub.googleapis.com \
  eventarc.googleapis.com \
  bigquery.googleapis.com \
  bigqueryconnection.googleapis.com \
  spanner.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  logging.googleapis.com \
  monitoring.googleapis.com \
  cloudtrace.googleapis.com

# -----------------------------------------------------------------
# 2. Pre-create Artifact Registry for Custom Agent / MCP Containers
# -----------------------------------------------------------------
echo "[2/4] Initializing Artifact Registry repository for Agent containers..."
gcloud artifacts repositories create "geap-agent-docker" \
  --project="${PROJECT_ID}" \
  --repository-format=docker \
  --location="${REGION}" \
  --description="Docker repository for GEAP Custom Agents and MCP servers" || echo "Repository already exists."

# -----------------------------------------------------------------
# 3. Create Staging Cloud Storage Bucket for Agent Engine & Pickles
# -----------------------------------------------------------------
BUCKET_NAME="${PROJECT_ID}-geap-artifacts"
echo "[3/4] Creating staging GCS bucket: gs://${BUCKET_NAME} in ${REGION}..."
gcloud storage buckets create "gs://${BUCKET_NAME}" \
  --project="${PROJECT_ID}" \
  --location="${REGION}" \
  --uniform-bucket-level-access || echo "Bucket already exists."

# -----------------------------------------------------------------
# 4. Seed Sample Agent Manifest & Reference Schemas
# -----------------------------------------------------------------
echo "[4/4] Seeding sample agent manifest and reference schemas..."
cat << 'EOF' > /tmp/agent_manifest.json
{
  "agent_id": "enterprise-customer-support-agent",
  "version": "v1.0",
  "framework": "google-adk-2.0",
  "runtime": "vertex-reasoning-engine",
  "model": "gemini-1.5-pro",
  "grounding": {
    "rag_corpus": "customer-kb-corpus",
    "datastore": "discovery-engine-kb"
  },
  "guardrails": {
    "model_armor_template": "enterprise-safety-floor"
  },
  "tools": [
    "remote_mcp_order_lookup",
    "vertex_datastore_search",
    "bigquery_sql_analytics"
  ]
}
EOF

gcloud storage cp /tmp/agent_manifest.json "gs://${BUCKET_NAME}/manifests/agent_manifest.json"

echo "================================================================="
echo " GEAP Lab Setup Automation Successfully Completed!"
echo "================================================================="
