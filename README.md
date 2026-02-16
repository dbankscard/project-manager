# Project Manager + Chief of Staff

A file-based project management and personal productivity system operated entirely through Claude Code. Markdown files in a git repo are the data layer. Claude Code is the application.

Inspired by [claude-chief-of-staff](https://github.com/mimurchison/claude-chief-of-staff) by Mike Murchison.

---

## What It Does

### Project Management
- **Kanban boards** — Track tasks across backlog, in-progress, review, and done
- **Structured logging** — Decisions, research, changes, blockers, milestones
- **Dashboards & standups** — Auto-generated status reports from your data
- **AI-powered planning** — Break goals into milestones and tasks

### Chief of Staff
- **Morning briefings** (`/gm`) — Calendar, tasks, goals, and urgent items in one view
- **Inbox triage** (`/triage`) — Prioritized inbox processing with draft responses
- **Vendor CRM** (`/enrich`) — Track account reps, contracts, renewals, and escalation paths
- **Goal alignment** — Everything filtered through your stated priorities

---

## Quick Start

```bash
git clone https://github.com/YOUR_USERNAME/project-manager.git
cd project-manager
claude
```

Then try:
```
/gm                    # Morning briefing
/dash                  # Project dashboard
/new-project           # Start tracking a project
/task add slug "Task"  # Add a task
/triage                # Process your inbox
```

---

## Structure

```
project-manager/
├── CLAUDE.md                     # System instructions — the brain
├── goals.yaml                    # Quarterly objectives
├── schedules.yaml                # Automation schedules
├── contacts/                     # Vendor CRM (one file per vendor)
│   └── example-contact.md        # Template with account rep, contract, escalation
├── projects/
│   ├── _registry.md              # Master index of all projects
│   ├── _observations.md          # Advisor pattern analysis
│   ├── _slack.md                 # Slack integration config
│   └── {project-slug}/
│       ├── README.md             # Overview, goals, milestones
│       ├── board.md              # Kanban board
│       └── log.md                # Activity log
├── templates/                    # Scaffolding for new projects
├── sounds/                       # Sound effects for hooks
└── .claude/
    ├── agents/                   # Specialized agent definitions
    │   ├── project-manager.md    # Strategy, planning, dashboards
    │   ├── tasker.md             # Task CRUD, boards, standups
    │   ├── documenter.md         # Logging, decisions, search
    │   ├── advisor.md            # Retros, pattern analysis
    │   └── chief-of-staff.md    # Briefings, triage, contacts
    ├── commands/                  # Slash command definitions
    │   ├── gm.md                 # /gm — morning briefing
    │   ├── triage.md             # /triage — inbox triage
    │   ├── enrich.md             # /enrich — contact enrichment
    │   ├── dash.md               # /dash — dashboard
    │   ├── task.md               # /task — task management
    │   ├── board.md              # /board — view kanban board
    │   ├── log.md                # /log — add log entries
    │   ├── standup.md            # /standup — standup report
    │   ├── plan.md               # /plan — break down work
    │   ├── search.md             # /search — search across projects
    │   ├── retro.md              # /retro — retrospective
    │   ├── new-project.md        # /new-project — create project
    │   └── capture.md            # /capture — capture Slack threads
    ├── hooks/                     # Automation hooks
    │   ├── session-start.sh      # Show status on startup
    │   ├── advisor-nudge.sh      # Surface overdue tasks, stale goals
    │   ├── recent-activity.sh    # Brief on recent work
    │   ├── sync-progress.sh      # Auto-update progress on board edits
    │   ├── validate-log-entry.sh # Enforce log entry structure
    │   └── protect-registry.sh   # Prevent registry corruption
    └── settings.json              # Hook configuration
```

---

## Commands

| Command | Description |
|---------|-------------|
| `/gm` | Morning briefing — calendar, tasks, goals, urgent items |
| `/dash` | Project dashboard with status overview |
| `/triage` | Inbox triage with tiered prioritization |
| `/enrich` | Vendor CRM — renewals, account reps, check-in cadence |
| `/new-project` | Create a new project |
| `/task` | Add, move, or complete tasks |
| `/board` | View a project's kanban board |
| `/log` | Add structured log entries |
| `/standup` | Generate standup from recent activity |
| `/plan` | Break down goals into tasks |
| `/search` | Search across all projects |
| `/retro` | Retrospective and work pattern analysis |
| `/capture` | Capture Slack threads into project logs |
| `/setup` | Check MCP connections, files, agents, and system health |

Most commands support `--slack` to post output to a Slack channel.

---

## MCP Integration

This system uses [MCPorter](https://mcporter.com) to manage MCP server connections. The more services you connect, the more powerful it becomes:

| Server | What It Enables |
|--------|-----------------|
| Slack | Inbox triage, channel monitoring, posting updates |
| Gmail | Email triage, draft responses |
| Google Calendar | Morning briefing calendar view, scheduling |

The system degrades gracefully — commands skip unavailable channels silently.

---

## Customization

- **`goals.yaml`** — Set your quarterly objectives. Everything references these.
- **`contacts/`** — Add vendor files for account rep and contract tracking.
- **`CLAUDE.md`** — The brain. Customize agents, rules, and behavior.
- **`.claude/commands/`** — Modify existing commands or create your own.
- **`sounds/`** — Swap out sound effects or remove them.

---

## License

MIT
