# /standup

Generate a standup summary from recent activity across all projects.

## Usage

```
/standup [--days N]
```

## Parameters

- **--days** (optional): Number of days to look back. Default: 1 (since last business day).

## Execution

Delegate to the **tasker** agent to:

1. Read all project boards (`projects/*/board.md`).
2. Read all project logs (`projects/*/log.md`).
3. Identify:
   - **Completed**: Tasks marked done and log entries from the lookback period.
   - **In Progress**: Tasks currently in the `## In Progress` column.
   - **Blockers**: Any `[blocker]` log entries from the lookback period.
   - **Up Next**: Top-priority tasks from Backlog and Research columns.
4. Format and display the standup.

## Output Format

```markdown
# Standup — YYYY-MM-DD

## Completed (since last standup)
- [project-slug] Task or activity description

## In Progress
- [project-slug] Task description

## Blockers
- [project-slug] Blocker description

## Up Next
- [project-slug] Task description `P1`
```

If no activity found:
```
# Standup — YYYY-MM-DD

No recent activity found across projects. Use /task or /log to track your work.
```

## Examples

```
/standup
/standup --days 3
```
