# Project Manager System

A file-based project management system operated entirely through Claude Code. Markdown files in a git repo are the data layer. Claude Code is the application.

## System Overview

Every project consists of exactly **3 files**:

| File | Purpose |
|------|---------|
| `projects/{slug}/README.md` | Overview, goals, milestones, status, risks, links |
| `projects/{slug}/board.md` | Kanban board — columns as H2 headers, tasks as checkboxes |
| `projects/{slug}/log.md` | Reverse-chronological structured log entries |

A master registry at `projects/_registry.md` serves as a cached index of all projects.

## Core Rules

1. **Always update the registry** when creating a project, changing status, updating progress, or hitting a milestone.
2. **Logs are reverse-chronological** — newest entries go directly below the `## Log` header.
3. **Task syntax** uses markdown checkboxes with inline metadata:
   ```
   - [ ] Task description `P1` `#tag` `due:2026-03-15`
   - [x] Completed task `P2` `#tag` `done:2026-02-10`
   ```
4. **Progress tracking** — percentage in README and registry, calculated from board task completion.
5. **Slugs are kebab-case** — derived from project name (e.g., "Migrate to Jamf" → `migrate-to-jamf`).
6. **Dates are ISO 8601** — `YYYY-MM-DD` everywhere.
7. **Log entry tags**: `[note]`, `[decision]`, `[research]`, `[change]`, `[result]`, `[blocker]`, `[milestone]` — always lowercase in brackets.

## File Conventions

- Project slugs: kebab-case, lowercase, no special characters
- Timestamps: `YYYY-MM-DD HH:MM` in log entries
- Inline metadata on tasks: backtick-wrapped — `` `P1` `#migration` `due:2026-05-01` ``
- Priority levels: `P0` (critical), `P1` (high), `P2` (medium), `P3` (low)
- Kanban columns: backlog, research, in-progress, review, done

## Natural Language Interpretation

When the user gives vague input, map it to actions:
- "What's going on?" / "Status?" → `/dash`
- "Add a task to..." → `/task add`
- "I decided to..." / "We chose..." → `/log {project} decision`
- "I changed..." / "I updated..." / "Deployed..." → `/log {project} change`
- "I looked into..." / "I found out..." / "Comparing..." → `/log {project} research`
- "Move X to done" / "Finish X" → `/task done`
- "What did I do?" / "Standup" → `/standup`
- "Find..." / "Where did I..." → `/search`
- "New project..." / "Start tracking..." → `/new-project`
- "Plan out..." / "Break down..." → `/plan`
- "How am I doing?" / "What should I improve?" / "Retro" → `/retro`
- "Post standup to Slack" / "Share status" → `/standup --slack`
- "Capture that Slack thread" / "Save that conversation" → `/capture`
- "Good morning" / "Start my day" → `/gm`
- "Inbox" / "Messages" / "Triage" → `/triage`
- "Vendors" / "Renewals" / "Account reps" / "Who haven't I talked to" → `/enrich`
- "Goals" / "Objectives" / "OKRs" → Read `goals.yaml` and report
- "Setup" / "Check connections" / "What's connected" → `/setup`
- "Run this" / "Execute" / "Build the scripts" / "Generate a report" → `/run`

## Dashboard Display Format

```
# Project Dashboard

| Project | Status | Priority | Progress | Next Milestone |
|---------|--------|----------|----------|----------------|
| [Name](projects/slug/README.md) | active | P1 | 35% | Milestone name |

Summary: X active projects, Y tasks in progress, Z blockers
```

## Standup Display Format

```
# Standup — YYYY-MM-DD

## Completed (since last standup)
- [project] Task or log description

## In Progress
- [project] Current tasks in in-progress column

## Blockers
- [project] Any [blocker] log entries

## Up Next
- [project] Top priority tasks from backlog/research
```

## Agents

This system uses 5 specialized agents:

| Agent | Role | When to Use |
|-------|------|-------------|
| `project-manager` | Strategy, planning, project lifecycle | Creating projects, planning, dashboards, status |
| `documenter` | Structured logging, decisions, search | Adding log entries, searching, activity summaries |
| `tasker` | Kanban boards, task CRUD, standups | Managing tasks, viewing boards, generating standups |
| `advisor` | Work pattern analysis, retrospectives | `/retro` reviews, session-start nudges, improvement suggestions |
| `chief-of-staff` | Personal productivity, briefings, triage, contacts | Morning briefings, inbox triage, contact enrichment, goal tracking |

## Slack Integration

The system integrates with Slack via MCP tools. Config is in `projects/_slack.md`.

- **Channel**: `#project-updates` — all project manager output goes here
- **Output**: Add `--slack` to `/standup`, `/dash`, `/log` (blocker/milestone) to post to Slack
- **Input**: Use `/capture` to pull Slack threads into project log entries, `--slack` on `/search` to include Slack results
- **Formatting**: Slack uses `*bold*` not `**bold**`, no tables — use bullet lists
- **Explicit only**: Never post to Slack unless the user passes `--slack` or uses `/capture`

## Templates

Templates live in `templates/` and are used when scaffolding new projects. They contain placeholder tokens (`{{name}}`, `{{slug}}`, etc.) that get replaced during project creation.

## Goals & Objectives

- `goals.yaml` at the project root is the source of truth for priorities.
- Claude references goals when prioritizing tasks, triaging inbox, and during briefings.
- Format: quarter, objectives with key_results, progress (0.0–1.0), status.
- Push back when work drifts from stated priorities.

## Vendor Contacts

- `contacts/` directory at the project root stores one markdown file per vendor.
- Tracks account reps, contracts, renewal dates, escalation paths, and interaction history.
- Tiers control check-in cadence:
  - **T1** — Critical vendors (MDM, identity, security) — monthly check-in
  - **T2** — Important vendors (productivity, collaboration) — quarterly
  - **T3** — Peripheral vendors (misc tools, low-touch) — semi-annual
- `/enrich` command manages the vendor CRM — flags upcoming renewals and stale relationships.
- Filename convention: `vendor-name.md` (kebab-case).

## MCP Integration

This system uses [MCPorter](https://mcporter.com) to manage MCP server connections. MCP servers extend Claude's capabilities to external services like Slack, Gmail, Google Calendar, and more.

- Configure MCP servers via MCPorter for inbox triage, calendar integration, and Slack connectivity.
- The system degrades gracefully — if an MCP server isn't connected, commands skip that channel silently.
- `/triage` and `/gm` automatically detect available MCP tools and adapt their output.

## Chief of Staff Features

- `/gm`: Morning briefing (calendar + projects + tasks + goals + urgent items).
- `/triage`: Inbox triage with tiered prioritization and draft responses.
- `/enrich`: Contact enrichment and relationship health checks.
- Operating modes: Prioritize, Decide, Draft, Coach, Synthesize, Explore.
- `/run`: Execute a task — spawn an agent to build scripts, configs, reports, and runbooks. Output saved to `projects/{slug}/artifacts/`.
- **Message guardrail**: NEVER send messages without explicit approval.
