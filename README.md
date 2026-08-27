# Google Enterprise Agent Platform (GEAP) & Vertex AI Workshop Lab

This repository contains the automation infrastructure, Terraform startup scripts, and direct Markdown instructional guide for the **GEAP & Vertex AI Agent Engine** hands-on lab on [explore.qwiklabs.com](https://explore.qwiklabs.com) / [ce.qwiklabs.com](https://ce.qwiklabs.com).

---

## 📁 Repository Structure

```
.
├── README.md                    # Project overview and deployment guide
├── lab_instructions.md          # Direct Markdown guide for Qwiklabs UI
├── qwiklabs/
│   └── Archive.zip              # Pre-packaged startup archive ready for upload
└── terraform/
    ├── main.tf                  # Terraform orchestrator using gcloud module
    ├── variables.tf             # Qwiklabs runtime variables contract
    └── scripts/
        └── script.sh            # Setup script enabling GEAP APIs & seeding resources
```

---

## 🚀 Lab Architecture & Enabled Services

The automated startup script provisions a sandbox project with the complete enterprise GEAP API surface:

* **Core Agent Runtime & LLMs:** `aiplatform.googleapis.com` (Vertex AI / Reasoning Engines), `discoveryengine.googleapis.com` (Vertex AI Agent Builder), `cloudaicompanion.googleapis.com`, `notebooks.googleapis.com`.
* **Tooling, Containers & MCP:** `run.googleapis.com` (Cloud Run for remote MCP servers), `artifactregistry.googleapis.com` (`geap-agent-docker` repository), `cloudbuild.googleapis.com`, `compute.googleapis.com`.
* **Data Grounding & State:** `storage.googleapis.com` (`gs://${PROJECT_ID}-geap-artifacts`), `bigquery.googleapis.com`, `bigqueryconnection.googleapis.com`, `spanner.googleapis.com`.
* **Security & Guardrails:** `modelarmor.googleapis.com` (Model Armor templates & prompt safety), `secretmanager.googleapis.com`, `iam.googleapis.com`, `iamcredentials.googleapis.com`.
* **Events & Ingress:** `pubsub.googleapis.com`, `eventarc.googleapis.com`.
* **Observability:** `logging.googleapis.com`, `monitoring.googleapis.com`, `cloudtrace.googleapis.com`, `serviceusage.googleapis.com`, `cloudresourcemanager.googleapis.com`.

---

## 🛠️ Deploying to explore.qwiklabs.com

### 1. Upload Startup Scripts Archive
1. Open your lab in Edit mode on **[explore.qwiklabs.com](https://explore.qwiklabs.com)**.
2. Scroll to **Lab Resources** &rarr; select the `gcp_project` resource (typically `project_0`).
3. Under **Startup Script / Scripts Archive**, upload `qwiklabs/Archive.zip`.
4. Click **Update Lab resource**.

### 2. Add Lab Instructions
1. Scroll to the **Instructions** section in the Lab editor.
2. Choose **Markdown / Text** mode.
3. Paste the contents of `lab_instructions.md`.
4. Click **Save / Update Lab**.

### 3. Configure Student Visible Outputs
Ensure the following controls are selected:
* `Open Google Cloud Console` &rarr; `project_0.console_url`
* `GCP Project ID` &rarr; `project_0.project_id`
* `Username` &rarr; `user_0.username`
* `Password` &rarr; `user_0.password`
* `Region` &rarr; `project_0.region`

---

## 🔄 Packaging Updates

If you modify `terraform/scripts/script.sh` or `terraform/main.tf`, re-generate `Archive.zip` using:

```bash
cd terraform
zip -r ../qwiklabs/Archive.zip main.tf variables.tf scripts/
```