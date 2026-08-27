# Building Enterprise Autonomous Agents with Vertex AI & GEAP

## Overview
Welcome to the **Google Enterprise Agent Platform (GEAP)** hands-on lab. In this lab, you will explore how to build, test, and deploy enterprise AI agents using the Vertex AI Agent Engine, Google ADK (Agent Development Kit), Model Armor safety guardrails, and Vertex RAG grounding.

All foundational services, networking, staging Cloud Storage buckets, and container registries have been pre-provisioned.

## Objectives
* Verify the enabled GEAP and Vertex AI services in your sandbox.
* Inspect pre-staged agent manifests and Artifact Registry repositories.
* Interact with Vertex AI Gemini foundation models from Cloud Shell.
* Explore Vertex AI Agent Engine and ADK endpoints.

---

## Environment Credentials

Your assigned sandbox parameters:
* **GCP Project ID:** `{{{ project_0.project_id }}}`
* **Assigned Region:** `{{{ project_0.region }}}`
* **Assigned Zone:** `{{{ project_0.zone }}}`
* **Student Username:** `{{{ user_0.username }}}`

---

## Task 1: Open Google Cloud Console and Cloud Shell

1. Click **Open Google Cloud Console** in the left panel.
2. Sign in with the temporary **Student Username** and **Password**.
3. In the top-right corner of the Cloud Console, click **Activate Cloud Shell** (`>_`).
4. Set your default compute region and verify project context:

```bash
gcloud config set project {{{ project_0.project_id }}}
gcloud config set compute/region {{{ project_0.region }}}
```

---

## Task 2: Verify GEAP Core Services

Confirm that all required GEAP, Discovery Engine, and Model Armor services are running:

```bash
gcloud services list --enabled --filter="name:(aiplatform OR discoveryengine OR modelarmor OR run)"
```

You should see:
* `aiplatform.googleapis.com` (Vertex AI / Reasoning Engines)
* `discoveryengine.googleapis.com` (Vertex AI Agent Builder)
* `modelarmor.googleapis.com` (Model Armor Guardrails)
* `run.googleapis.com` (Cloud Run for Remote MCP & Custom Agents)

---

## Task 3: Inspect Pre-staged Agent Artifacts & Docker Registry

1. Check the Docker repository prepared for custom agent containers and remote MCP servers:

```bash
gcloud artifacts repositories describe geap-agent-docker --location={{{ project_0.region }}}
```

2. Inspect the pre-staged agent manifest in your Cloud Storage staging bucket:

```bash
export BUCKET_NAME="{{{ project_0.project_id }}}-geap-artifacts"
gcloud storage cat "gs://${BUCKET_NAME}/manifests/agent_manifest.json"
```

---

## Task 4: Test Vertex AI Model Invocation from Cloud Shell

Run a Python script in Cloud Shell to query Gemini with structured generation:

```bash
python3 -c '
import urllib.request, json, subprocess

token = subprocess.check_output(["gcloud", "auth", "print-access-token"]).decode("utf-8").strip()
project_id = "{{{ project_0.project_id }}}"
region = "{{{ project_0.region }}}"

url = f"https://{region}-aiplatform.googleapis.com/v1/projects/{project_id}/locations/{region}/publishers/google/models/gemini-1.5-flash:generateContent"

payload = {
    "contents": [{"role": "user", "parts": [{"text": "You are a GEAP router. Classify user intent: \"Where is my order #12345?\" into JSON {intent: string, confidence: float}"}]}],
    "generationConfig": {"responseMimeType": "application/json"}
}

req = urllib.request.Request(url, data=json.dumps(payload).encode("utf-8"), headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"})
with urllib.request.urlopen(req) as resp:
    print(resp.read().decode("utf-8"))
'
```

---

## Task 5: End Lab

1. Click **End Lab** in the Qwiklabs tab to release your sandbox project.
