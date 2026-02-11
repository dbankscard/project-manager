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
7. **Log entry tags**: `[note]`, `[decision]`, `[result]`, `[blocker]`, `[milestone]` — always lowercase in brackets.

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
- "Move X to done" / "Finish X" → `/task done`
- "What did I do?" / "Standup" → `/standup`
- "Find..." / "Where did I..." → `/search`
- "New project..." / "Start tracking..." → `/new-project`
- "Plan out..." / "Break down..." → `/plan`

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

This system uses 3 specialized agents:

| Agent | Role | When to Use |
|-------|------|-------------|
| `project-manager` | Strategy, planning, project lifecycle | Creating projects, planning, dashboards, status |
| `documenter` | Structured logging, decisions, search | Adding log entries, searching, activity summaries |
| `tasker` | Kanban boards, task CRUD, standups | Managing tasks, viewing boards, generating standups |

## Templates

Templates live in `templates/` and are used when scaffolding new projects. They contain placeholder tokens (`{{name}}`, `{{slug}}`, etc.) that get replaced during project creation.
