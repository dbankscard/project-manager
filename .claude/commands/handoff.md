# /handoff

Generate a comprehensive knowledge transfer document for a project.

## Usage

```
/handoff {slug} [--output path]
```

## Parameters

- **slug** (required): The project's kebab-case slug
- **--output** (optional): Custom output path. Default: `projects/{slug}/artifacts/handoff-{slug}-{date}.md`

## Execution

Delegate to the **documenter** agent to:

1. **Read the entire project:**
   - `projects/{slug}/README.md` — goals, milestones, status, risks
   - `projects/{slug}/board.md` — all tasks and their states
   - `projects/{slug}/log.md` — full activity history

2. **Cross-reference:**
   - `contacts/*.md` — find vendor contacts mentioned in log entries
   - `goals.yaml` — find related objectives

3. **Synthesize into a handoff document** with the sections below.

4. **Write output** to `projects/{slug}/artifacts/handoff-{slug}-{date}.md` (create `artifacts/` directory if needed).

## Output Format

```markdown
# Handoff: {Project Name}

> Generated YYYY-MM-DD

## Executive Summary
High-level summary from README goals and current status. 2-3 sentences covering what the project is, where it stands, and key outcomes.

## Current State

| Field | Value |
|-------|-------|
| Status | active |
| Progress | 65% |
| Priority | P1 |
| Open Blockers | 2 |
| Remaining Tasks | 12 |

## Key Decisions
(From [decision] log entries, most recent first)

### YYYY-MM-DD — Decision Title
**Decision:** What was decided
**Rationale:** Why
**Impact:** What changed

## What's Been Done
(From completed tasks + [change] entries, grouped by theme)

### Phase/Theme Name
- Completed task or change description
- Another completed item

## What's Left
(Remaining tasks grouped by board column)

### In Progress
- [ ] Task `P1`

### Backlog
- [ ] Task `P2`

## Known Risks and Blockers
(From README risks + open [blocker] entries)

- **Risk:** Description — mitigation
- **Blocker:** Description — unblock path

## Important Research
(From [research] entries, summarized)

- **Topic:** Key findings and conclusions

## Key Contacts
(Cross-referenced from contacts/ directory)

- **Vendor Name** — Rep Name, role — last contact date

## How to Revert
(Aggregated from [change] entry revert sections)

- **Change:** How to revert description
```

## Examples

```
/handoff jamf-migration
/handoff jamf-migration --output docs/jamf-handoff.md
```
