# /retro

Run a retrospective analysis of your work patterns and get actionable suggestions.

## Usage

```
/retro [project-slug] [--week] [--tasks] [--logging]
```

## Parameters

- **project-slug** (optional): Focus on a single project. If omitted, reviews all projects.
- **--week** (optional): Review the past 7 days specifically.
- **--tasks** (optional): Focus on task flow — stale tasks, WIP limits, velocity.
- **--logging** (optional): Focus on logging discipline — decision coverage, entry frequency.

## Execution

Delegate to the **advisor** agent to:

1. Read all project boards, logs, READMEs, and the registry.
2. Analyze work patterns across task flow, logging, project health, and work distribution.
3. Generate specific, actionable observations grounded in actual data.
4. Write observations to `projects/_observations.md` for tracking over time.
5. Display the retro in a structured, scannable format.

## Output Format

```markdown
# Retro — YYYY-MM-DD

## What's Working Well
- Positive patterns with evidence

## Needs Attention
- Issues with specific impact

## Suggestions
1. Actionable recommendation
2. Another recommendation
3. One more

## By the Numbers
- Tasks completed this week: X
- Currently in progress: Y
- Average days in "in-progress": Z
- Unresolved blockers: N
- Project progress: Name (X%), Name (Y%)
```

## Examples

```
/retro
/retro jamf-migration
/retro --week
/retro --tasks
/retro jamf-migration --logging
```
