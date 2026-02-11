# /log

Add a structured log entry to a project.

## Usage

```
/log {project-slug} {tag} "Entry title or content" [--slack]
```

## Parameters

- **project-slug** (required): The project's kebab-case slug
- **tag** (required): One of: `note`, `decision`, `research`, `change`, `result`, `blocker`, `milestone`
- **content** (required): The log entry title or content

## Tags

| Tag | Purpose | Template |
|-----|---------|----------|
| `note` | Quick observations, FYIs | Freeform |
| `decision` | Chose one option over another | Decision/Context/Rationale/Impact |
| `research` | Investigation, troubleshooting, comparisons | Question/Findings/Conclusion |
| `change` | Config change, deployment, script run | What/Where/How to revert |
| `result` | Outcome of an action or experiment | Freeform |
| `blocker` | Something stopping progress | What's blocked + unblock path |
| `milestone` | Checkpoint reached | Freeform |

## Execution

Delegate to the **documenter** agent to:

1. Validate the project exists at `projects/{slug}/`.
2. Read `projects/{slug}/log.md`.
3. Generate a timestamped entry with the correct tag.
4. For `decision` tags — use the full decision template (Decision/Context/Rationale/Impact). Prompt user for missing fields.
5. For `research` tags — use the research template (Question/Findings/Conclusion). Can be freeform for quick investigations.
6. For `change` tags — use the change template (What/Where/How to revert). Can be single-line for trivial changes.
7. For `blocker` tags — include what's blocked and what would unblock it.
8. Insert the entry at the top of the `## Log` section (below the header, above existing entries).
9. Display the formatted entry.

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

## Research Template

```markdown
### YYYY-MM-DD HH:MM — [research] Title

**Question:** What you were trying to find out

**Findings:**
- Key findings listed

**Conclusion:** What you learned and what to do next

---
```

## Change Template

```markdown
### YYYY-MM-DD HH:MM — [change] Title

**What:** What was changed

**Where:** System, server, config file, or environment

**How to revert:** Steps to undo if needed

---
```

## Examples

```
/log jamf-migration blocker "Waiting on ABM access" --slack
/log jamf-migration milestone "Pilot migration complete" --slack
/log jamf-migration decision "Using DEP re-enrollment over manual migration"
/log jamf-migration research "Comparing Jamf enrollment methods"
/log jamf-migration change "Enabled DEP token in Jamf Pro cloud instance"
/log jamf-migration result "Pilot group of 10 Macs migrated successfully"
/log jamf-migration blocker "Waiting on Apple Business Manager access from vendor"
/log saas-audit note "Completed initial inventory of all SaaS tools"
/log internal-tools milestone "v1.0 dashboard deployed to staging"
```
