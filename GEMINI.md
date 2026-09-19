# Jetski Project Instructions: workshop-agy

Welcome to **workshop-agy**! This project contains the complete source code, automation, assets, and Qwiklabs instructions for the **Due Diligence Agent Workshop** built with the **Antigravity CLI (`agy`)**, **Google ADK (Agent Development Kit)**, **Google Cloud Agent Runtime**, and **Gemini Enterprise App**.

---

## 1. Project Directory & Key Files

```
workshop-agy/
├── .antigravityignore              # Shields AGY student context from lab infrastructure/authoring files
├── .geminiignore                  # Mirror ignore rules for Gemini CLI tools
├── GEMINI.md                      # Jetski project entrypoint and instructions (this file)
├── AGENTS.md                      # Operational directives for student's agy assistant (Google ADK & Due Diligence)
├── README.md                      # Primary GitHub repository documentation with embedded screenshots
├── lab_instructions.md            # Official Qwiklabs-ready instructions (uses <ql-variable> and CDN image links)
│
├── assets/
│   └── imgs/                      # Screenshots illustrating agy authentication, skills, and GE App setup
│
├── skills/
│   └── due-diligence-contract/    # Specialized ADK skill used during agy /grill-me alignment
│       ├── SKILL.md
│       └── references/
│           ├── checklist.md       # 10-category legal compliance checklist
│           └── workflow.md        # Step-by-step audit workflow & risk matrix definition
│
├── scripts/
│   └── check_progress.sh          # Student self-check CLI progress validator for Cloud Shell
│
├── workshop_utils/
│   ├── __init__.py
│   └── plugins.py                 # Graceful429Plugin quota resilience interceptor for Google ADK
│
├── docs/
│   ├── Contrato Social Consolidado - Nexus Tecnologia Ltda..pdf  # Sample contract for student testing
│   ├── sample_contract.pdf        # Bash-friendly alias without spaces for terminal commands
│   │
│   └── authoring/                 # Internal engineering & authoring documentation (ignored by AGY)
│       ├── AGENTS.md              # Authoritative engineering standard & Qwiklabs authoring playbook
│       ├── IDEIAS_E_MELHORIAS.md  # Benchmarking and canonical blurbs from CloudVLab/gcp-spl-content
│       ├── GEAP_PATTERNS.md       # Deep dive into Discovery Engine and Vertex AI Agent Engine patterns
│       └── archive/               # Archived foundational GEAP & Gemini 3.7 Flash lab instructions
│           └── foundational-geap-lab/
│
├── terraform/                     # Qwiklabs startup automation bundle (Project Octopus)
│   ├── runtime.yaml               # Engine declaration: terraform 1.4.6
│   ├── variables.tf               # 4 mandatory Qwiklabs input variables
│   ├── provider.tf                # Google provider authentication configuration
│   ├── main.tf                    # terraform-google-modules/gcloud/google module call
│   └── scripts/
│       └── script.sh              # Headless provisioning: API enablement, region metadata injection
│
└── qwiklabs/
    └── Archive.zip                # Packaged zip bundle ready for upload to project_0 in Qwiklabs
```

---

## 2. Core Invariants for Jetski & Developers

When modifying or updating this project, strictly follow the rules codified in [`docs/authoring/AGENTS.md`](./docs/authoring/AGENTS.md):

1. **Pure GFM Code Blocks:** In `lab_instructions.md`, always use standard Markdown fences (```` ```bash ````). Never use `<ql-code-block>` or `templated` tags (which break in the Qwiklabs browser editor).
2. **Variable Resolution:**
   - Inside code blocks: use `$DEVSHELL_PROJECT_ID` and dynamic region discovery via `commonInstanceMetadata[google-compute-default-region]`.
   - Outside code blocks (text/cards): use `<ql-variable key="project_0.project_id"></ql-variable>` and `<ql-variable key="project_0.default_region"></ql-variable>`. (Never write `project_0.region`!).
3. **Markdown List & Qwiklabs Indentation Invariant (Anti `1. 1. 1.` & Anti `<pre><code>`):**
   - Every top-level list (ordered or unordered) **must** have a blank line (`\n\n`) preceding it, and use hyphen bullets (`- `).
   - Inside numbered steps (`1.  `, `2.  `), **fenced code blocks (`    ``` `) MUST be indented by 4 spaces (`    `) and placed at the very end of the step** (`0` or `3` spaces closes `<ol>` in Qwiklabs and resets numbering to `1.`).
   - **NEVER indent non-code lines (sub-bullets `- `, paragraphs, or images `![...]`) by 4 spaces after a blank line (`\n\n    `)** — Qwiklabs's parser treats any 4-space non-fenced line after `\n\n` as a classic Indented Code Block (`<pre><code>`), turning bullets and images into dark code boxes! Attach sub-bullets (`   - `) and images (`   ![...]`) on the immediate next line (`\n`, NO blank line) with **3 spaces (`   `)** of indentation before the step's final `    ``` ` fence (or `0` spaces after the last item of a list).
4. **Image Hosting:** Images in `lab_instructions.md` must point to absolute raw GitHub URLs:
   `https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/<image_name>.png`.
5. **Startup Packaging Workflow:**
   When updating `terraform/scripts/script.sh` or Terraform files:
   ```bash
   cd terraform && zip -r ../qwiklabs/Archive.zip runtime.yaml main.tf provider.tf variables.tf scripts/script.sh && cd ..
   ```
   *Remember: Pushing to GitHub does not update Qwiklabs; `Archive.zip` must be uploaded to `project_0` in the Qwiklabs UI.*
