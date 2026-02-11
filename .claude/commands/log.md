# /log

Add a structured log entry to a project.

## Usage

```
/log {project-slug} {tag} "Entry title or content"
```

## Parameters

- **project-slug** (required): The project's kebab-case slug
- **tag** (required): One of: `note`, `decision`, `result`, `blocker`, `milestone`
- **content** (required): The log entry title or content

## Execution

Delegate to the **documenter** agent to:

1. Validate the project exists at `projects/{slug}/`.
2. Read `projects/{slug}/log.md`.
3. Generate a timestamped entry with the correct tag.
4. For `decision` tags, use the full decision template (Decision/Context/Rationale/Impact) — prompt user for missing fields.
5. For `blocker` tags, include what's blocked and what would unblock it.
6. Insert the entry at the top of the `## Log` section (below the header, above existing entries).
7. Display the formatted entry.

## Log Entry Format

```markdown
### YYYY-MM-DD HH:MM — [tag] Title

Content here.

---
```

## Decision Template

```markdown
### YYYY-MM-DD HH:MM — [decision] Title

**Decision:** What was decided

**Context:** Why this came up

**Rationale:** Why this option was chosen

**Impact:** What changes as a result

---
```

## Examples

```
/log jamf-migration decision "Using DEP re-enrollment over manual migration"
/log saas-audit note "Completed initial inventory of all SaaS tools"
/log jamf-migration blocker "Waiting on Apple Business Manager access from vendor"
/log internal-tools milestone "v1.0 dashboard deployed to staging"
/log jamf-migration result "Pilot group of 10 Macs migrated successfully"
```
