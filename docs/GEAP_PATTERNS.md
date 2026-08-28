# Specialized Patterns: GEAP, Discovery Engine & Vertex AI Agent Engine

This document extends [`AGENTS.md`](../AGENTS.md) with specific technical architecture and implementation patterns for the **Google Enterprise Agent Platform (GEAP)**, **Discovery Engine (Gemini Enterprise)**, and **Vertex AI Agent Engine**.

---

## 1. Bare-Bones GE App Provisioning (Without Data Stores)

When creating a Gemini Enterprise / Discovery Engine App for routing or publishing agents (such as Google ADK agents via `agents-cli publish gemini-enterprise`), you often need an initial clean ("pelado") application without attached data stores.

### The Working REST Payload
To create an engine without data stores, use `solutionType: "SOLUTION_TYPE_SEARCH"` and `appType: "APP_TYPE_INTRANET"`:

```bash
ADC_TOKEN=$(gcloud auth print-access-token)
APP_ID="agy-enterprise-app"
APP_DISPLAY_NAME="AGY Enterprise Agent App"

curl -s -X POST   -H "Authorization: Bearer ${ADC_TOKEN}"   -H "X-Goog-User-Project: ${PROJECT_ID}"   -H "Content-Type: application/json; charset=utf-8"   -d '{
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
  }'   "https://discoveryengine.googleapis.com/v1/projects/${PROJECT_ID}/locations/global/collections/default_collection/engines?engineId=${APP_ID}"
```

### Why this works:
* The Discovery Engine backend validator (`IsAllowedToBeEmptyEngine`) explicitly permits `dataStoreIds: []` for `appType: "APP_TYPE_INTRANET"`.
* **DO NOT USE `solutionType: "SOLUTION_TYPE_CHAT"`**: This represents the legacy Dialogflow CX bot architecture. It enforces strict validation requiring a `timeZone` property and at least one pre-attached data store, otherwise failing with `INVALID_ARGUMENT: timeZone is required`.

---

## 2. Vertex AI Gemini Foundation Model Inference (Global Endpoint)

For labs evaluating or classifying intents using Gemini 3.7 Flash:

### Endpoint Location
Use the **`global`** Vertex AI endpoint:
```
https://aiplatform.googleapis.com/v1/projects/{project_id}/locations/global/publishers/google/models/{model}:generateContent
```

### Model Name Fallback Architecture
Model aliases in Vertex AI can vary between `gemini-flash-3.7` and `gemini-3.7-flash`. When executing python test scripts from Cloud Shell, always implement automatic fallback:

```python
import subprocess
import json
import urllib.request
import urllib.error

token = subprocess.check_output(["gcloud", "auth", "print-access-token"]).decode("utf-8").strip()
project_id = subprocess.check_output(["gcloud", "config", "get-value", "project"]).decode("utf-8").strip()

model = "gemini-flash-3.7"
url = f"https://aiplatform.googleapis.com/v1/projects/{project_id}/locations/global/publishers/google/models/{model}:generateContent"

payload = {
    "contents": [{"role": "user", "parts": [{"text": "Você é um roteador semântico da plataforma GEAP. Classifique a intenção do usuário: 'Onde está o meu pedido #12345?' em formato JSON {intent: string, confidence: float, language: string}"}]}],
    "generationConfig": {"responseMimeType": "application/json"}
}

req = urllib.request.Request(
    url,
    data=json.dumps(payload).encode("utf-8"),
    headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
)

try:
    with urllib.request.urlopen(req) as resp:
        print(resp.read().decode("utf-8"))
except urllib.error.HTTPError as e:
    # Automatic fallback for alternative publisher ID
    url_alt = f"https://aiplatform.googleapis.com/v1/projects/{project_id}/locations/global/publishers/google/models/gemini-3.7-flash:generateContent"
    req_alt = urllib.request.Request(
        url_alt,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    )
    with urllib.request.urlopen(req_alt) as resp:
        print(resp.read().decode("utf-8"))
```

---

## 3. Required API Suite for GEAP & Agent Engine

When building labs featuring autonomous agents, enable the unified GEAP API suite:

| Service Name | API Identifier | Role in Architecture |
| :--- | :--- | :--- |
| **Vertex AI Agent Engine** | `aiplatform.googleapis.com` | Reasoning engines, session persistence, Gemini inference |
| **Discovery Engine** | `discoveryengine.googleapis.com` | Agent Builder, Search & Conversation, GE App |
| **Cloud Companion** | `cloudaicompanion.googleapis.com` | Gemini Enterprise App native integration |
| **Model Armor** | `modelarmor.googleapis.com` | Prompt injection filters, safety sanitization |
| **Cloud Run** | `run.googleapis.com` | Hosting remote agent services and MCP servers |
| **Observability** | `cloudtrace.googleapis.com`, `logging.googleapis.com`, `monitoring.googleapis.com` | Distributed tracing, session replay, audit logs |
