# Jetski Project Instructions: workshop-agy

Welcome to **workshop-agy**! This project contains the complete source code, automation, assets, and Qwiklabs instructions for the **Due Diligence Agent Workshop** built with the **Antigravity CLI (`agy`)**, **Google ADK (Agent Development Kit)**, **Google Cloud Agent Runtime**, and **Gemini Enterprise App**.

---

## 1. Project Directory & Key Files

```
workshop-agy/
├── GEMINI.md                      # Jetski project entrypoint and instructions (this file)
├── AGENTS.md                      # Authoritative engineering standard for Qwiklabs lab authoring
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
├── docs/
│   ├── GEAP_PATTERNS.md           # Deep dive into Discovery Engine and Vertex AI Agent Engine patterns
│   ├── Contrato Social Consolidado - Nexus Tecnologia Ltda..pdf  # Sample contract for student testing
│   └── sample_contract.pdf        # Bash-friendly alias without spaces for terminal commands
│
├── terraform/                     # Qwiklabs startup automation bundle (Project Octopus)
│   ├── runtime.yaml               # Engine declaration: terraform 1.4.6
│   ├── variables.tf               # 4 mandatory Qwiklabs input variables
│   ├── provider.tf                # Google provider authentication configuration
│   ├── main.tf                    # terraform-google-modules/gcloud/google module call
│   └── scripts/
│       └── script.sh              # Headless provisioning: API enablement, region metadata injection
│
├── qwiklabs/
│   └── Archive.zip                # Packaged zip bundle ready for upload to project_0 in Qwiklabs
│
└── archive/
    └── foundational-geap-lab/     # Archived foundational GEAP & Gemini 3.7 Flash lab instructions
```

---

## 2. Core Invariants for Jetski & Developers

When modifying or updating this project, strictly follow the rules codified in [`AGENTS.md`](./AGENTS.md):

1. **Pure GFM Code Blocks:** In `lab_instructions.md`, always use standard Markdown fences (```` ```bash ````). Never use `<ql-code-block>` or `templated` tags (which break in the Qwiklabs browser editor).
2. **Variable Resolution:**
   - Inside code blocks: use `$DEVSHELL_PROJECT_ID` and dynamic region discovery via `commonInstanceMetadata[google-compute-default-region]`.
   - Outside code blocks (text/cards): use `<ql-variable key="project_0.project_id"></ql-variable>` and `<ql-variable key="project_0.default_region"></ql-variable>`. (Never write `project_0.region`!).
3. **Markdown List Invariant:** Every list (ordered or unordered) **must** have a blank line (`\n\n`) preceding it, and use hyphen bullets (`- `). Without a blank line, CommonMark merges the list into a single wall of text.
4. **Image Hosting:** Images in `lab_instructions.md` must point to absolute raw GitHub URLs:
   `https://raw.githubusercontent.com/carlosmscabral/workshop-agy/main/assets/imgs/<image_name>.png`.
5. **Startup Packaging Workflow:**
   When updating `terraform/scripts/script.sh` or Terraform files:
   ```bash
   cd terraform && zip -r ../qwiklabs/Archive.zip runtime.yaml main.tf provider.tf variables.tf scripts/script.sh && cd ..
   ```
   *Remember: Pushing to GitHub does not update Qwiklabs; `Archive.zip` must be uploaded to `project_0` in the Qwiklabs UI.*
