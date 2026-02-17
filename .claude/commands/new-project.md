# /new-project

Create and scaffold a new project.

## Usage

```
/new-project "Project Name" [--priority P1|P2|P3] [--description "..."] [--template default|migration|vendor-eval|security-audit|incident]
```

## Parameters

- **name** (required): The project name, in quotes
- **--priority** (optional): Priority level — P0, P1, P2, P3. Default: P2
- **--description** (optional): Short project description
- **--template** (optional): Project template to use. Default: `default`
  - `default` — Empty board, generic README
  - `migration` — Pre-populated with audit, pilot, rollout, cutover, decommission phases
  - `vendor-eval` — Pre-populated with requirements, RFP, demos, POC, security review, procurement
  - `security-audit` — Pre-populated with scope, inventory, assess, findings, remediate, verify
  - `incident` — Pre-populated with detect, triage, contain, eradicate, recover, post-mortem

## Execution

Delegate to the **project-manager** agent to:

1. Parse the project name and derive a kebab-case slug.
2. Create `projects/{slug}/` directory.
3. Determine template directory: `templates/{template}/` (default: `templates/default/`).
4. Read templates from the selected directory and replace all `{{placeholder}}` tokens:
   - `{{name}}` → project name
   - `{{slug}}` → kebab-case slug
   - `{{description}}` → provided description or "No description provided."
   - `{{date}}` → today's date (YYYY-MM-DD)
   - `{{priority}}` → priority level
5. Write `README.md`, `board.md`, and `log.md` into the project directory.
6. Add a row to `projects/_registry.md`.
7. Display confirmation with the created file paths and template used.

## Output

```
Created project: {name}
  Slug: {slug}
  Priority: {priority}
  Files:
    - projects/{slug}/README.md
    - projects/{slug}/board.md
    - projects/{slug}/log.md
  Registry updated.
```

## Examples

```
/new-project "Migrate Mosyle to Jamf Pro" --priority P1 --template migration
/new-project "SaaS License Audit" --priority P2 --description "Audit all SaaS subscriptions for cost optimization"
/new-project "EDR Vendor Evaluation" --template vendor-eval
/new-project "Q1 Security Audit" --priority P1 --template security-audit
/new-project "Production Outage 2026-02-15" --priority P0 --template incident
```
