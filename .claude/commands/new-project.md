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
2. **Check `~/Projects/` for an existing repo:**
   - Look for `~/Projects/{slug}` or `~/Projects/{name}` (case-insensitive match).
   - If found: link to it — read its git state (branch, remote, tech stack from package.json/go.mod/etc.).
   - If not found: scaffold a new git repo at `~/Projects/{slug}` with `git init`, a README.md, and `.gitignore`.
3. Create `projects/{slug}/` tracking directory in the project-manager repo.
4. Determine template directory: `templates/{template}/` (default: `templates/default/`).
5. Read templates from the selected directory and replace all `{{placeholder}}` tokens:
   - `{{name}}` → project name
   - `{{slug}}` → kebab-case slug
   - `{{description}}` → provided description or "No description provided."
   - `{{date}}` → today's date (YYYY-MM-DD)
   - `{{priority}}` → priority level
   - `{{repo}}` → `~/Projects/{repo-name}` path
6. Write `README.md`, `board.md`, and `log.md` into the tracking directory. README includes frontmatter:
   ```yaml
   ---
   repo: ~/Projects/{repo-name}
   created: YYYY-MM-DD
   ---
   ```
7. Add a row to `projects/_registry.md` including the `Repo` column.
8. Display confirmation with the created file paths, linked repo, and template used.

## Output

```
Created project: {name}
  Slug: {slug}
  Repo: ~/Projects/{repo-name} (linked existing / scaffolded new)
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
