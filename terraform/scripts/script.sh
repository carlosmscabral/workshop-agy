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
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  pubsub.googleapis.com || true

# Set project-level default compute region and zone metadata
if [ -n "${REGION}" ] && [ -n "${ZONE}" ]; then
  echo "Configuring default project metadata (region: ${REGION}, zone: ${ZONE})..."
  for i in 1 2 3 4 5; do
    gcloud compute project-info add-metadata \
      --project="${PROJECT_ID}" \
      --metadata="google-compute-default-region=${REGION},google-compute-default-zone=${ZONE}" && break || sleep 3
  done
fi

echo "============================================================"
echo "Lab Setup Complete!"
echo "============================================================"
exit 0
