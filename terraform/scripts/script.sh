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

# Set project-level default compute region and zone metadata
if [ -n "${REGION}" ] && [ -n "${ZONE}" ]; then
  echo "Configuring default project metadata (region: ${REGION}, zone: ${ZONE})..."
  gcloud compute project-info add-metadata \
    --project="${PROJECT_ID}" \
    --metadata="google-compute-default-region=${REGION},google-compute-default-zone=${ZONE}" || true
fi

# 2. Pre-create GE App (Gemini Enterprise Intranet App - "Pelado", sem Data Store)
echo "Pre-creating GE App (agy-enterprise-app) in Discovery Engine..."
ADC_TOKEN=$(gcloud auth print-access-token 2>/dev/null || true)
APP_ID="agy-enterprise-app"
APP_DISPLAY_NAME="AGY Enterprise Agent App"

if [ -n "${ADC_TOKEN}" ]; then
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer ${ADC_TOKEN}" \
    -H "X-Goog-User-Project: ${PROJECT_ID}" \
    "https://discoveryengine.googleapis.com/v1/projects/${PROJECT_ID}/locations/global/collections/default_collection/engines/${APP_ID}" || true)

  if [ "${HTTP_CODE}" == "404" ] || [ -z "${HTTP_CODE}" ]; then
    echo "Creating empty GE App '${APP_ID}'..."
    curl -s -X POST \
      -H "Authorization: Bearer ${ADC_TOKEN}" \
      -H "X-Goog-User-Project: ${PROJECT_ID}" \
      -H "Content-Type: application/json; charset=utf-8" \
      -d '{
        "displayName": "'"${APP_DISPLAY_NAME}"'",
        "solutionType": "SOLUTION_TYPE_SEARCH",
        "industryVertical": "GENERIC",
        "appType": "APP_TYPE_INTRANET",
        "dataStoreIds": [],
        "searchEngineConfig": {
          "searchTier": "SEARCH_TIER_ENTERPRISE",
          "searchAddOns": ["SEARCH_ADD_ON_LLM"],
          "requiredSubscriptionTier": "SUBSCRIPTION_TIER_SEARCH_AND_ASSISTANT"
        }
      }' \
      "https://discoveryengine.googleapis.com/v1/projects/${PROJECT_ID}/locations/global/collections/default_collection/engines?engineId=${APP_ID}" || true
  else
    echo "GE App '${APP_ID}' already exists or status code: ${HTTP_CODE}."
  fi
fi

echo "============================================================"
echo "Lab Setup Complete!"
echo "============================================================"
exit 0
