# /weekly

Generate a weekly summary report for stakeholders.

## Usage

```
/weekly [--project {slug}] [--slack]
```

## Parameters

- **--project** (optional): Limit report to a single project. Without this, reports across all active projects.
- **--slack** (optional): Post the report to the `#project-updates` Slack channel.

## Execution

Delegate to the **documenter** agent to:

1. **Collect data from the past 7 days:**
   - Read all `projects/*/log.md` files — parse `### YYYY-MM-DD HH:MM` headers to filter entries from the last 7 days.
   - Read all `projects/*/board.md` files — find tasks with `done:` dates in the past 7 days.
   - Read `goals.yaml` for current goal progress.
   - Read `projects/_registry.md` for project status and progress.

2. **Generate the report** with the sections below.

3. If `--slack` is passed, format for Slack (`*bold*`, no tables, bullet lists) and post to `#project-updates`.

## Output Format

```markdown
# Weekly Summary — YYYY-MM-DD to YYYY-MM-DD

## Highlights
- Milestones reached and blockers resolved this week

## Completed
- [project] Task description `P1`
- [project] Task description `P2`
(grouped by project, sorted by priority)

## Decisions
- [project] Decision title — rationale summary
(from [decision] log entries)

## Blockers
### Resolved
- [project] Blocker that was resolved

### Open
- [project] Blocker still active — unblock path

## Progress

| Project | Start | End | Delta |
|---------|-------|-----|-------|
| project-name | 25% | 40% | +15% |

## Goal Progress
- Objective: Key result — progress
(from goals.yaml)

## Next Week Focus
1. Top priority item
2. Second priority
3. Third priority
(highest priority unfinished tasks across all projects)
```

## Examples

```
/weekly
/weekly --project jamf-migration
/weekly --slack
```
