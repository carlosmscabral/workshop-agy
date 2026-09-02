# Standards & Authoring Playbook for Custom Google Cloud Labs on Qwiklabs (AGENTS.md)

This document is the authoritative standard and reference for AI coding agents and engineers building, modifying, or maintaining custom private Google Cloud hands-on labs on **Qwiklabs** (`explore.qwiklabs.com` and `ce.qwiklabs.com`).

---

## 1. The Qwiklabs Dual-Architecture Mental Model

When developing a lab for Qwiklabs, there are two completely different execution layers that must never be confused:

```
+-----------------------------------------------------------------------------------+
| 1. LAB AUTHORING & FRONTEND (Web Editor / instructions)                           |
|    - Runs client-side in the student's browser at explore.qwiklabs.com.           |
|    - Markdown parser: Browser JavaScript (e.g. marked.js / SimpleMDE).           |
|    - Rules: Pure GFM Markdown fences only. No custom compiler tags in code.       |
+-----------------------------------------------------------------------------------+
| 2. INFRASTRUCTURE & BACKEND AUTOMATION (Terraform / Startup Script)               |
|    - Runs headless in a container during the 1-2 min "Lab Setup" phase.           |
|    - Controlled by `Archive.zip` manually uploaded to `project_0`.                |
|    - Rules: Must authenticate gcloud, enable APIs, inject metadata, provision.    |
+-----------------------------------------------------------------------------------+
```

> [!WARNING]
> **Git Push vs. Qwiklabs Execution:**  
> Pushing changes to GitHub **does NOT** automatically update the live lab runner in Qwiklabs.  
> * Instructions must be **copied and pasted** into the Qwiklabs Web Editor.  
> * Startup automation changes require rebuilding `qwiklabs/Archive.zip` and **manually uploading** it to the `project_0` resource in the Qwiklabs UI.

---

## 2. Markdown Syntax Standards for Instructions

The Qwiklabs Web Editor is a browser-rendered Markdown environment. Adhere strictly to these rules to prevent visual corruption:

### Rule 1: Always Use Pure GFM Fenced Code Blocks
Use standard Markdown backtick fences (```` ```bash ```` or ```` ``` ````).

```bash
# Correct:
gcloud auth list
```

**NEVER use `<ql-code-block>` or `templated` attributes in the Web Editor.**
* In the Alexandria/Git compilation pipeline, `<ql-code-block>` is a compiler macro.
* In the browser Web Editor, `<ql-code-block>` is treated as an unknown HTML element. This triggers browser text parser side effects:
  * **Quote Escaping:** `"` becomes `&quot;` and `'` becomes `&#x27;`.
  * **Unintended Autolinks:** Raw URLs like `https://...` are converted into broken `&lt;a href="..."&gt;` links.
  * **Newline Flattening:** Line breaks are collapsed into a continuous wall of text, causing code to spill outside containers.
  * **Broken Interpolation:** Triple curly braces `{{{project_0.project_id}}}` are **not** evaluated and remain as literal text.

### Rule 2: Dynamic Variable Placement
* **Inside Code Blocks:** Use shell environment variables (`$DEVSHELL_PROJECT_ID`, `$REGION`, `${PROJECT_ID}`).
* **Outside Code Blocks (Informational Cards/Text):** Use the official `<ql-variable>` Custom Element:
  ```html
  <ql-variable key="project_0.project_id"></ql-variable>
  <ql-variable key="project_0.default_region"></ql-variable>
  <ql-variable key="project_0.default_zone"></ql-variable>
  <ql-variable key="user_0.username"></ql-variable>
  ```
  `<ql-variable>` is a registered browser Custom Element that interpolates live session parameters directly into paragraphs and HTML callouts.

  > [!CAUTION]
  > **Key Name Invariant (`default_region` vs `region`):**  
  > The exact attribute names defined in the Qwiklabs specification are `default_region` and `default_zone`.  
  > Writing `key="project_0.region"` will **fail silently** and display the default fallback placeholder (`____`). Always use `default_region` and `default_zone`.

  > [!CAUTION]
  > **Never Wrap `<ql-variable>` in Backticks:**  
  > Wrapping `<ql-variable>` in backticks (e.g. `` `<ql-variable key="user_0.username"></ql-variable>` ``) causes the Markdown parser to treat it as an inline code span (`<code>`). This escapes the HTML characters and prevents the browser's Custom Element engine from executing, leaving literal `<ql-variable>` tags visible to the student. Always place `<ql-variable>` directly in normal prose without backticks: `(<ql-variable key="user_0.username"></ql-variable>)`.

### Rule 3: Callouts, Alerts, and Lists
* **Mandatory Blank Line Before Lists:** In CommonMark and the Qwiklabs browser markdown parser (SimpleMDE / marked.js), an unordered or ordered list **must always be preceded by an empty blank line**. If a list immediately follows a paragraph line without an empty line:
  ```markdown
  <!-- WRONG: Collapses into a single paragraph with literal asterisks -->
  Neste laboratório, você:
  * Configurou o agy...
  * Habilitou skills...
  
  <!-- CORRECT: Renders as a proper HTML unordered list -->
  Neste laboratório, você:

  - Configurou o agy...
  - Habilitou skills...
  ```
  Failing to leave a blank line causes the parser to treat all bullet points as continuous text of the preceding paragraph, rendering literal `*` characters inline on a single line.
* **Use Hyphens (`- `) Instead of Asterisks (`* `):** Prefer `- ` for bullet lists to avoid ambiguity with markdown italics/bold emphasis syntax.
* **Sub-lists in Numbered Steps:** When adding sub-bullets inside an ordered list step, indent the bullet with 3 or 4 spaces:
  ```markdown
  4. **Habilitar Recursos:**
     - Navegue até a aba Features;
     - Ative a opção Agentes.
  ```
* **Alerts and Callouts:** Use standard Markdown blockquotes for warnings and notes:
  ```markdown
  > ⚠️ **MUITO IMPORTANTE:** Sempre utilize uma **Janela Anônima (Incognito)**.
  ```
* Avoid inserting raw unindented `<div>` tags directly in the middle of Markdown numbered lists, as this resets list numbering back to `1.`.

### Rule 4: Cloud Shell Execution Invariants & Gotchas
* **First-Run API Authorization Pop-up:** On the first execution of any command issuing API requests, Cloud Shell triggers a modal dialog: *"Autorizar o Cloud Shell a fazer chamadas de API do GCP" (Authorize Cloud Shell to make GCP API calls)*. Instructions must explicitly instruct the student to click **"Autorizar" (Authorize)**.
* **Strict Incognito Window Protocol:** Mandatory requirement. Running labs in regular browser windows risks cross-account auth leaks between corporate `@google.com` / personal `@gmail.com` accounts and the student's temporary `@qwiklabs.net` session. Instruct students to never register personal phone numbers or 2FA on temporary lab accounts.
* **Zero-Dependency Execution (`urllib` vs `pip install`):** For test and verification scripts inside Cloud Shell, favor Python standard library `urllib.request` with `ADC_TOKEN=$(gcloud auth print-access-token)` over heavy SDK installations (`pip install google-cloud-*`). Standard library scripts run with 100% reliability immediately without pip network delays, virtual environment conflicts, or permission issues.
* **FQDNs in `gcloud services list` Filters:** Service Usage API filters strictly require fully qualified domain names (FQDNs). Writing `--filter="name:(aiplatform OR discoveryengine)"` will produce a warning: `WARNING: The following filter keys were not present in any resource : name`. Always use the complete domain:
  ```bash
  gcloud services list --enabled \
    --filter="name:(aiplatform.googleapis.com OR discoveryengine.googleapis.com)"
  ```
* **ADK Web Server CORS in Cloud Shell Web Preview (`--allow_origins="*"`):** When running `adk web` inside Google Cloud Shell, the user accesses the Dev UI via Cloud Shell's Web Preview reverse proxy (`https://<port>-cs-*.cloudshell.dev`). By default, ADK's ASGI middleware (`_OriginCheckMiddleware` in `api_server.py`) strictly rejects cross-origin requests from non-loopback hosts. Because Angular/Vite loads JavaScript bundles as ES modules (`<script type="module">`), the browser attaches an `Origin` header pointing to `cloudshell.dev`, which causes ADK to reject all `.js` bundles with `403 Forbidden: origin not allowed`, rendering a black screen. Always run ADK Web with the origin bypass flag in quotes:
  ```bash
  uv run adk web --allow_origins="*"
  ```
  *(Note: Quotes around `"*"` are mandatory in Bash to prevent shell globbing expansion to local filenames).*

### Rule 5: No Backticks or Code Formatting in Headings (`#`, `##`, `###`)
* **TOC Parser Truncation Bug:** The Qwiklabs navigation panel / Table of Contents (TOC) builder extracts markdown headings to generate the student sidebar index. When it encounters backticks (e.g. `## Tarefa 2. Instalar o `agents-cli`, habilitar skills...`), the TOC parser fails on inline code tags and **truncates the title at the first backtick**, displaying incomplete text (e.g. `Tarefa 2. Instalar o`).
* **Enforcement:** Always use plain text for tool names, CLIs, commands, and options inside headings and subheadings (e.g. `## Tarefa 2. Instalar o agents-cli, habilitar skills e criar o agente` and `### Alinhar e estruturar o agente com o comando /grill-me`). Keep backtick code formatting strictly inside regular body paragraphs.

---

## 3. Dynamic Variable Resolution Strategy in Cloud Shell

Qwiklabs provisions disposable sandboxes with randomly selected project IDs (e.g. `qwiklabs-gcp-04-f3194e85be5b`) and randomly assigned regions (e.g. `us-east1`, `us-west1`, `us-central1`).

**NEVER hardcode project IDs or regions in code snippets.** Use this 3-tier standard pattern:

### Standard Initialization Snippet (Task 1 of any GCP Lab)
Every lab must start by initializing the environment using this exact pattern:

```bash
export PROJECT_ID=$DEVSHELL_PROJECT_ID

# Obter dinamicamente a região atribuída ao sandbox pelo Qwiklabs:
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata[google-compute-default-region])" 2>/dev/null)
export REGION=${REGION:-$(gcloud config get-value compute/region 2>/dev/null)}
export REGION=${REGION:-us-central1}

gcloud config set project $PROJECT_ID
gcloud config set compute/region $REGION

echo "=========================================="
echo "Projeto Sandbox Ativo: ${PROJECT_ID}"
echo "Região Ativa:          ${REGION}"
echo "=========================================="
```

### Why this works:
1. **`$DEVSHELL_PROJECT_ID`**: Pre-injected by Google Cloud Shell infrastructure into every container session for Qwiklabs. Always valid and reliable.
2. **`commonInstanceMetadata[google-compute-default-region]`**: The startup script sets this project metadata property during provisioning.
3. **Lookup Syntax:** In `gcloud`, querying `commonInstanceMetadata[KEY]` extracts the item from the inner `items` array. (Do not use `--filter="commonInstanceMetadata.key=..."`, which fails because `items` is an array).
4. **Fallback:** If metadata query fails or is delayed, it falls back to `compute/region` config or safe default `us-central1`.

### Templating Local Files in Cloud Shell
When students need to generate local files:
* **For Configuration/Environment Files (`.env`, config manifests):** Use unquoted heredocs (`cat << EOF > .env`) so that `${PROJECT_ID}` and `${REGION}` are expanded into their active sandbox values:
  ```bash
  cat << EOF > .env
  PROJECT_ID=${PROJECT_ID}
  REGION=${REGION}
  EOF
  ```
* **For Python, Shell, or Code Scripts (`test_script.py`):** Use quoted heredocs (`cat << 'EOF' > test.py`) to prevent premature shell expansion of internal script variables and syntax.

---

## 4. Terraform Startup Automation Standards

Startup automation runs unattended in Qwiklabs via Terraform and the **Project Octopus** script runner.

### The 5 Mandatory Files of the Startup Bundle (`Archive.zip`)

Every startup archive uploaded to a Qwiklabs `gcp_project` resource (e.g. `project_0`) with `Script Type: qwiklabs` MUST contain these exact files at its root:

```
Archive.zip
├── runtime.yaml      <-- MANDATORY: Project Octopus runner declaration
├── variables.tf      <-- MANDATORY: 4 input variables passed by Qwiklabs
├── provider.tf       <-- MANDATORY: Google provider credentials configuration
├── main.tf           <-- MANDATORY: Terraform module & execution entrypoint
└── scripts/
    └── script.sh     <-- MANDATORY: Bash provisioning script
```

---

### 1. `runtime.yaml` (Project Octopus Engine Contract)

> [!CAUTION]
> **The `runtime.yaml` Requirement:**  
> If `runtime.yaml` is missing from the root of `Archive.zip`, Qwiklabs will instantly reject the startup package with:  
> `missing runtime.yaml file` &rarr; `Resources failed to launch: project 0`.  
> This file informs the Qwiklabs runner which execution engine and version to spin up.

```yaml
runtime: terraform
version: 1.4.6
```

---

### 2. `variables.tf` (Qwiklabs Input Contract)

Qwiklabs automatically passes four specific input variables into the Terraform root module. All four **must** be declared:

```terraform
variable "gcp_project_id" {
  description = "The GCP project ID provided dynamically by Qwiklabs"
  type        = string
}

variable "gcp_region" {
  description = "The default GCP region assigned to this lab session"
  type        = string
}

variable "gcp_zone" {
  description = "The default GCP zone assigned to this lab session"
  type        = string
}

variable "service_account_key_file" {
  description = "Path to the temporary service account credentials JSON file"
  type        = string
}
```

---

### 3. `provider.tf` (Google Cloud Provider Configuration)

Configures the Terraform Google provider to authenticate using the temporary credentials file injected by Qwiklabs:

```terraform
provider "google" {
  project     = var.gcp_project_id
  region      = var.gcp_region
  zone        = var.gcp_zone
  credentials = var.service_account_key_file
}
```

---

### 4. `main.tf` (Module Call & Entrypoint)

Use the official `terraform-google-modules/gcloud/google` module to invoke `scripts/script.sh`.

> [!CRITICAL]
> **Passing the Service Account Key:**  
> You **MUST** pass `${var.service_account_key_file}` in `create_cmd_body` (as argument `$4`). If omitted, the shell script cannot execute `gcloud auth activate-service-account`, and all subsequent `gcloud` commands will fail due to lack of an active authenticated account.

```terraform
module "cli" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 3.0.1"

  platform = "linux"
  additional_components = []

  create_cmd_entrypoint = "chmod +x ${path.module}/scripts/script.sh; ${path.module}/scripts/script.sh"
  create_cmd_body       = "${var.gcp_project_id} ${var.gcp_region} ${var.gcp_zone} ${var.service_account_key_file}"

  skip_download = false
  upgrade       = false
  gcloud_sdk_version = "420.0.0"

  service_account_key_file = var.service_account_key_file
}
```

---

### 5. `scripts/script.sh` - Standard Lifecycle
Every startup script must follow this lifecycle order:

```bash
#!/bin/bash
set -e

PROJECT_ID="$1"
REGION="$2"
ZONE="$3"
SA_KEY_FILE="$4"

echo "============================================================"
echo "Starting Lab Setup Automation"
echo "Project: ${PROJECT_ID} | Region: ${REGION} | Zone: ${ZONE}"
echo "============================================================"

# 1. Authenticate gcloud using the passed service account key file
if [ -n "${SA_KEY_FILE}" ] && [ -f "${SA_KEY_FILE}" ]; then
  echo "Activating Service Account credentials..."
  gcloud auth activate-service-account --key-file="${SA_KEY_FILE}" || true
  export GOOGLE_APPLICATION_CREDENTIALS="${SA_KEY_FILE}"
fi

if [ -n "${PROJECT_ID}" ]; then
  gcloud config set project "${PROJECT_ID}" || true
fi

# 2. Enable Required APIs (Always enable compute.googleapis.com first)
echo "Enabling Core APIs..."
gcloud services enable   serviceusage.googleapis.com   cloudresourcemanager.googleapis.com   compute.googleapis.com   storage.googleapis.com || true

# 3. Register Region/Zone into Project Metadata (with retry loop)
# When compute.googleapis.com is freshly enabled, Compute Engine control plane
# may take 5-15 seconds to initialize project-info. Retry up to 5 times.
if [ -n "${REGION}" ] && [ -n "${ZONE}" ]; then
  echo "Configuring default project metadata (region: ${REGION}, zone: ${ZONE})..."
  for i in 1 2 3 4 5; do
    gcloud compute project-info add-metadata       --project="${PROJECT_ID}"       --metadata="google-compute-default-region=${REGION},google-compute-default-zone=${ZONE}" && break || sleep 3
  done
fi

# 4. Provision Shared Lab Resources (buckets, datasets, service accounts)
# ...
```

---

## 5. Lab Packaging and Deployment Workflow

Follow this procedure when creating or updating any Qwiklabs lab:

```
[Edit Code / Scripts] 
       │
       ├──> 1. git commit & push (Preserves source history in GitHub)
       │
       ├──> 2. Package Archive.zip:
       │       cd terraform && zip -r ../qwiklabs/Archive.zip runtime.yaml main.tf provider.tf variables.tf scripts/script.sh && cd ..
       │
       ├──> 3. Qwiklabs Web Console (explore.qwiklabs.com/labs/<id>/edit):
       │       a. Instructions tab -> Paste lab_instructions.md
       │       b. Lab Resources tab -> Click `project_0` -> Upload `qwiklabs/Archive.zip` -> Click "Update Lab Resource"
       │
       └──> 4. Test Lab -> Start Lab -> Verify in Incognito Window
```

### Web Console Configuration: Student Visible Outputs Checklist
When creating or editing a lab on `explore.qwiklabs.com/labs/<id>/edit`:
In the **Lab Resources** tab, under the student panel settings, you must check the following **Student Visible Outputs** properties:

| Output Label in UI | Resource Reference | Student UI Impact |
| :--- | :--- | :--- |
| **Open Google Cloud Console** | `project_0.console_url` | Generates the primary blue **"Open Google Console"** action button in the student left sidebar. |
| **GCP Project ID** | `project_0.project_id` | Displays the copyable temporary project ID. |
| **Username** | `user_0.username` | Displays the copyable student login email (`student-xx-...@qwiklabs.net`). |
| **Password** | `user_0.password` | Displays the copyable temporary student password. |
| **Region** | `project_0.default_region` | Displays the assigned lab region (e.g. `us-west1`). |

> [!WARNING]
> If `project_0.console_url` is omitted from the Student Visible Outputs, the student interface will **not** display the button to open the GCP Cloud Console, forcing students to navigate manually.

---

## 6. Extending for Specialized Services

When building labs that involve specialized or non-standard Google Cloud APIs (such as Discovery Engine, Gemini Enterprise, Vertex AI Agent Engine, or Model Armor), separate specific operational patterns from the general lab standard.

* For **Discovery Engine / GEAP / Vertex AI Agent Engine** specifics (such as bare-bones `APP_TYPE_INTRANET` creation without Data Stores, avoiding the legacy Dialogflow `timeZone` requirement, and Model Armor integration), see:
  👉 **[`docs/GEAP_PATTERNS.md`](./docs/GEAP_PATTERNS.md)**

---

## 7. CLS Instructional Standards, Quota Resilience & Progress Validation

Benchmarked directly against the official Google Cloud Learning Services (CLS) Lab Architect repository (`CloudVLab/gcp-spl-content`), our lab incorporates these high-leverage standards:

### 1. CLS Writing Style Standards (`.gemini/styleguide.md`)
- **Imperative Task Titles:** Numbered tasks must use imperative verbs without trailing punctuation (`Task 1. Configure...` or `Tarefa 1. Configurar...`). Do not use colons in headings.
- **Task Summaries:** Follow each task heading with 1-2 sentences in simple present tense summarizing the goal.
- **Single Action per Numbered Step:** Sighted learners and screen readers benefit from atomic actions. Avoid combining multiple setup commands into a single step.
- **UI Element Precedence:** Always bold exact UI labels and place them before the action (e.g. `No campo **Nome**, digite...`; `No menu superior, clique em **Cloud Shell**`).
- **Second Person Direct Address:** Write directly to the student as "you" (*você*). Avoid first-person plural (*nós/vamos fazer*).
- **Governance Stamps:** Include canonical timestamps and copyright at the end:
  ```markdown
  **Manual Last Updated: September 1, 2026**
  **Lab Last Tested: September 1, 2026**
  ```

### 2. Canonical Blurbs for Manual Deploy
Because private manual labs on `explore.qwiklabs.com` do not run the Alexandria compiler macro pipeline (`![[/fragments/...]]`), standard boilerplate must be embedded inline:
- **Mandatory Incognito Window Warning:** Explicit warning preventing cross-account auth leaks with personal accounts.
- **Google Cloud Console Sign-in Flow:** Temporary username/password, terms acceptance, declining 2FA/recovery phone.
- **Cloud Shell Activation:** Instructions to click the **Authorize** pop-up for API calls.
- **Dynamic Region & Zone Setup:** Tri-tier resolution using `commonInstanceMetadata`.
- **Cached Response / Quota Notice:** Informs students that fallback responses may be returned during high traffic.
- **Lab Clean-up & Rating:** Step-by-step instructions for clicking **End Lab** and providing 1-5 star ratings.

### 3. Quota Resilience Plugin (`workshop_utils/plugins.py`)
To prevent classroom workshops from crashing when 30+ students simultaneously hit Vertex AI Gemini API rate limits (`429 RESOURCE_EXHAUSTED`), use the modular `Graceful429Plugin`:
```python
from workshop_utils.plugins import Graceful429Plugin

plugin = Graceful429Plugin()
plugin.apply_429_interceptor(root_agent)
```
The plugin catches `RESOURCE_EXHAUSTED` in async streams and returns realistic pre-cached fallback responses matching the due diligence audit contract, preventing students from getting blocked.

### 4. Student Self-Check CLI (`scripts/check_progress.sh`)
Students can run the interactive progress checker directly in Cloud Shell at any point:
```bash
./scripts/check_progress.sh 1   # Validate Task 1
./scripts/check_progress.sh 2   # Validate Task 2
./scripts/check_progress.sh all # Validate all tasks
```
The script provides colorized `[PASS]`, `[FAIL]`, `[WARN]` outputs with actionable troubleshooting hints.

