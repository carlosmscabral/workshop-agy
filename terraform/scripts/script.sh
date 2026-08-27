#!/bin/bash
set -e

PROJECT_ID="$1"
REGION="$2"
ZONE="$3"
SA_KEY_FILE="$4"

echo "============================================================"
echo "Starting Lab Setup Automation for GEAP & Vertex AI"
echo "Project: ${PROJECT_ID}"
echo "Region:  ${REGION}"
echo "Zone:    ${ZONE}"
echo "============================================================"

# Authenticate if service account key file is provided
if [ -n "${SA_KEY_FILE}" ] && [ -f "${SA_KEY_FILE}" ]; then
  echo "Activating Service Account credentials from ${SA_KEY_FILE}..."
  gcloud auth activate-service-account --key-file="${SA_KEY_FILE}" || true
  export GOOGLE_APPLICATION_CREDENTIALS="${SA_KEY_FILE}"
fi

# Set active project
if [ -n "${PROJECT_ID}" ]; then
  gcloud config set project "${PROJECT_ID}" || true
fi

# 1. Enable Core, Vertex AI, Discovery Engine, Sessions and Telemetry APIs
echo "Enabling Core GEAP APIs (Agent Runtime, Inference, Sessions, Telemetry)..."
gcloud services enable \
  serviceusage.googleapis.com \
  cloudresourcemanager.googleapis.com \
  compute.googleapis.com \
  storage.googleapis.com \
  aiplatform.googleapis.com \
  discoveryengine.googleapis.com \
  cloudaicompanion.googleapis.com \
  modelarmor.googleapis.com \
  run.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  logging.googleapis.com \
  monitoring.googleapis.com \
  cloudtrace.googleapis.com \
  pubsub.googleapis.com || true

# 2. Create Artifact Staging Cloud Storage Bucket
BUCKET_NAME="${PROJECT_ID}-geap-artifacts"
echo "Creating staging GCS bucket: gs://${BUCKET_NAME} in ${REGION}..."
gcloud storage buckets create "gs://${BUCKET_NAME}" \
  --project="${PROJECT_ID}" \
  --location="${REGION}" \
  --uniform-bucket-level-access || true

# 3. Pre-create GE App (Data Store and Chat Engine in Discovery Engine / Agent Builder)
echo "Pre-creating GE App (agy-enterprise-app) in Discovery Engine..."
ADC_TOKEN=$(gcloud auth print-access-token 2>/dev/null || true)
DATA_STORE_ID="agy-kb-store"
APP_ID="agy-enterprise-app"
APP_DISPLAY_NAME="AGY Enterprise Agent App"

if [ -n "${ADC_TOKEN}" ]; then
  # 3a. Create Data Store for the Chat Engine
  echo "Creating Data Store '${DATA_STORE_ID}'..."
  curl -s -X POST \
    -H "Authorization: Bearer ${ADC_TOKEN}" \
    -H "X-Goog-User-Project: ${PROJECT_ID}" \
    -H "Content-Type: application/json; charset=utf-8" \
    -d '{
      "displayName": "AGY Knowledge Base",
      "industryVertical": "GENERIC",
      "solutionTypes": ["SOLUTION_TYPE_CHAT"],
      "contentConfig": "NO_CONTENT"
    }' \
    "https://discoveryengine.googleapis.com/v1/projects/${PROJECT_ID}/locations/global/collections/default_collection/dataStores?dataStoreId=${DATA_STORE_ID}" || true

  # 3b. Check if app already exists
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer ${ADC_TOKEN}" \
    -H "X-Goog-User-Project: ${PROJECT_ID}" \
    "https://discoveryengine.googleapis.com/v1/projects/${PROJECT_ID}/locations/global/collections/default_collection/engines/${APP_ID}" || true)

  if [ "${HTTP_CODE}" == "404" ] || [ -z "${HTTP_CODE}" ]; then
    echo "Creating Chat Engine '${APP_ID}' linked to '${DATA_STORE_ID}'..."
    curl -s -X POST \
      -H "Authorization: Bearer ${ADC_TOKEN}" \
      -H "X-Goog-User-Project: ${PROJECT_ID}" \
      -H "Content-Type: application/json; charset=utf-8" \
      -d '{
        "displayName": "'"${APP_DISPLAY_NAME}"'",
        "solutionType": "SOLUTION_TYPE_CHAT",
        "industryVertical": "GENERIC",
        "dataStoreIds": ["'"${DATA_STORE_ID}"'"],
        "chatEngineConfig": {
          "agentCreationConfig": {
            "business": "Enterprise Multi-Agent Platform",
            "defaultLanguageCode": "pt-BR"
          }
        }
      }' \
      "https://discoveryengine.googleapis.com/v1/projects/${PROJECT_ID}/locations/global/collections/default_collection/engines?engineId=${APP_ID}" || true
  else
    echo "GE App '${APP_ID}' already exists or status code: ${HTTP_CODE}."
  fi
fi

# 4. Generate local environment and agent manifest configuration files
TMP_DIR=$(mktemp -d)

# A. .env configuration file
cat << EOF > "${TMP_DIR}/.env"
# Environment Configuration for GEAP & Vertex AI Agent Runtime
PROJECT_ID=${PROJECT_ID}
REGION=${REGION}
ZONE=${ZONE}
GE_APP_ID=${APP_ID}
GEAP_BUCKET=gs://${BUCKET_NAME}
VERTEX_LOCATION=${REGION}
EOF

# B. agent_card.json metadata specification
cat << EOF > "${TMP_DIR}/agent_card.json"
{
  "name": "AGY Due Diligence Specialist Agent",
  "description": "Autonomous enterprise agent developed with Google ADK for due diligence analysis and multi-turn reasoning.",
  "version": "1.0.0",
  "runtime": "Vertex AI Agent Engine (GEAP)",
  "appId": "${APP_ID}",
  "capabilities": [
    "autonomous_reasoning",
    "session_persistence",
    "telemetry_logging"
  ]
}
EOF

# C. Seed Sample Agent Manifest
cat << EOF > "${TMP_DIR}/agent_manifest.json"
{
  "agent_id": "agy-due-diligence-agent",
  "version": "v1.0",
  "framework": "google-adk-2.0",
  "runtime": "vertex-reasoning-engine",
  "model": "gemini-1.5-flash",
  "grounding": {
    "datastore": "discovery-engine-kb"
  },
  "guardrails": {
    "model_armor_template": "enterprise-safety-floor"
  }
}
EOF

# Upload generated files to Cloud Storage config/ and manifests/
echo "Uploading generated configuration files to gs://${BUCKET_NAME}/config/..."
gcloud storage cp "${TMP_DIR}/.env" "gs://${BUCKET_NAME}/config/.env" || true
gcloud storage cp "${TMP_DIR}/agent_card.json" "gs://${BUCKET_NAME}/config/agent_card.json" || true
gcloud storage cp "${TMP_DIR}/agent_manifest.json" "gs://${BUCKET_NAME}/manifests/agent_manifest.json" || true

rm -rf "${TMP_DIR}"

echo "============================================================"
echo "Lab Setup Complete!"
echo "============================================================"
exit 0
