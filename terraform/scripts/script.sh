#!/bin/bash

# Environment variables passed from main.tf
PROJECT_ID=$1
REGION=$2
ZONE=$3

echo "============================================================"
echo "Starting Lab Setup Automation for GEAP & Vertex AI"
echo "Project: ${PROJECT_ID}"
echo "Region:  ${REGION}"
echo "Zone:    ${ZONE}"
echo "============================================================"

# Set the active project
gcloud config set project "$PROJECT_ID"

# 1. Enable Core & Vertex AI APIs
echo "Enabling GEAP & Vertex AI APIs..."
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
  cloudtrace.googleapis.com || true

# 2. Pre-create Artifact Registry repository
echo "Creating Artifact Registry repository for Agent containers..."
gcloud artifacts repositories create geap-agent-docker \
  --project="$PROJECT_ID" \
  --repository-format=docker \
  --location="$REGION" \
  --description="Docker repository for GEAP Custom Agents and MCP servers" || true

# 3. Create Staging Cloud Storage Bucket
BUCKET_NAME="${PROJECT_ID}-geap-artifacts"
echo "Creating staging GCS bucket: gs://${BUCKET_NAME} in ${REGION}..."
gcloud storage buckets create "gs://${BUCKET_NAME}" \
  --project="$PROJECT_ID" \
  --location="$REGION" \
  --uniform-bucket-level-access || true

# 4. Seed Sample Agent Manifest
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

gcloud storage cp /tmp/agent_manifest.json "gs://${BUCKET_NAME}/manifests/agent_manifest.json" || true

echo "============================================================"
echo "Lab Setup Complete!"
echo "============================================================"
exit 0
