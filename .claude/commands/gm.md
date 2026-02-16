# /gm

Morning briefing — a concise one-screen overview of your day: calendar, projects, tasks, goals, and a focus recommendation.

## Usage

```
/gm
```

## Parameters

None.

## Execution

Delegate to the **chief-of-staff** agent to:

1. **Calendar** (if Google Calendar MCP available):
   - Fetch today's events.
   - List meetings with times, attendees, and any prep notes.
   - Flag conflicts or back-to-back blocks.
   - If MCP not available, skip this section silently.

2. **Projects**:
   - Read `projects/_registry.md`.
   - For each active project, read `projects/{slug}/board.md` and `projects/{slug}/log.md`.
   - Identify tasks due today, overdue tasks, and tasks currently in-progress.
   - Note any `[blocker]` or `[milestone]` log entries from the last 48 hours.

3. **Goals**:
   - Read `goals.yaml` from the project root.
   - Show each goal with its current status and any alignment notes.
   - Flag goals that are at risk or behind schedule.
   - If `goals.yaml` doesn't exist, skip this section silently.

4. **Inbox scan** (if Slack/email MCP available):
   - Quick scan for unread messages or mentions since last session.
   - Surface anything urgent or time-sensitive.
   - Do NOT read every message in detail — just flag what needs attention.
   - If MCP not available, skip this section silently.

5. **Synthesize**:
   - Identify the most urgent items across all sources.
   - Generate a focus recommendation for the day.

## Output Format

```markdown
# Good Morning — YYYY-MM-DD

## Calendar
- 09:00 — Team standup (30m)
- 11:00 — 1:1 with Jane (30m) — prep: review Q1 metrics
- 14:00 — Vendor demo (1h)

## Projects
- [project-slug] 3 tasks in-progress, 1 due today, 0 overdue
- [project-slug] [blocker] Description from recent log entry

## Tasks Due Today
- [project-slug] Task description `P1`
- [project-slug] Task description `P2`

## Overdue
- [project-slug] Task description `P1` `due:2026-02-14` (2 days overdue)

## Goals
- Goal name — on track (65%)
- Goal name — at risk (30%, behind by 2 weeks)

## Urgent
- [blocker] Project X: blocking issue description
- [calendar] Back-to-back meetings 11:00-15:00 — plan deep work for morning
- [inbox] 2 Slack mentions needing response

## Focus Recommendation
Top 3 things to prioritize today, based on urgency, deadlines, and goals.
```

Sections with no items should be omitted entirely. The briefing should fit on one screen.

## Closing Offer

After the briefing, offer:
```
Ready to dive in? I can:
- Run a full /triage on your inbox
- Prep you for your next meeting
- Pull up any project board
```

## Examples

```
/gm
```
