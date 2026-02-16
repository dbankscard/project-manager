# /standup

Generate a standup summary from recent activity across all projects.

## Usage

```
/standup [--days N] [--slack]
```

## Parameters

- **--days** (optional): Number of days to look back. Default: 1 (since last business day).
- **--slack** (optional): Also post the standup to the `#project-updates` Slack channel.

## Execution

Delegate to the **tasker** agent to:

1. Read all project boards (`projects/*/board.md`).
2. Read all project logs (`projects/*/log.md`).
3. Identify:
   - **Completed**: Tasks marked done and log entries from the lookback period.
   - **In Progress**: Tasks currently in the `## In Progress` column.
   - **Blockers**: Any `[blocker]` log entries from the lookback period.
   - **Up Next**: Top-priority tasks from Backlog and Research columns.
   - **Goals Progress**: Read `goals.yaml` and show progress on active objectives.
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

## Goals Progress
- Objective name — 60% (on track)
- Objective name — 40% (at risk)
```

If no activity found:
```
# Standup — YYYY-MM-DD

No recent activity found across projects. Use /task or /log to track your work.
```

## Slack Posting

When `--slack` is provided:
1. Generate the standup as normal.
2. Reformat for Slack markdown (`*bold*` instead of `**bold**`, no tables).
3. Look up the `#project-updates` channel ID using `slack_search_channels`.
4. Post to the channel using `slack_send_message`.
5. Confirm the post with a message link.

## Examples

```
/standup
/standup --days 3
/standup --slack
/standup --days 2 --slack
```
