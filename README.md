# Project Manager + Chief of Staff

A file-based project management and personal productivity system operated entirely through [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Markdown files in a git repo are the data layer. Claude Code is the application.

No databases. No web apps. No subscriptions. Just markdown, git, and AI.

Inspired by [claude-chief-of-staff](https://github.com/mimurchison/claude-chief-of-staff) by Mike Murchison.

---

## How It Works

Every project is 3 markdown files:

```
projects/my-project/
├── README.md    # Goals, milestones, status, risks
├── board.md     # Kanban board (backlog → in-progress → review → done)
└── log.md       # Decisions, research, changes, blockers
```

You interact with them through slash commands in Claude Code. The system reads your files, understands context, and takes action — managing tasks, generating reports, triaging your inbox, and running multi-agent work.

---

## Quick Start

```bash
git clone https://github.com/YOUR_USERNAME/project-manager.git
cd project-manager
claude
```

On first launch, run `/setup` to check system health and MCP connections.

---

## Example Workflow

### Morning

Start your day with a briefing:

```
/gm
```

This pulls your calendar, scans for overdue tasks, checks goal progress, and surfaces anything urgent — all in one view.

### Throughout the Day

```
# Create a new project
/new-project

# Add tasks to a project board
/task add my-project "Evaluate SSO providers" P1 #security

# Log a decision you made
/log my-project decision "Chose Okta over Azure AD — better SCIM support"

# Log research findings
/log my-project research "CrowdStrike vs SentinelOne comparison — see artifacts"

# View your board
/board my-project

# Check the dashboard across all projects
/dash
```

### Executing Real Work

The `/run` command spawns a team of AI agents to do actual work — research, build scripts, generate reports, create config profiles:

```
# Complex task — spawns researcher + builder + writer agents
/run my-project "Audit current endpoint security and build remediation plan"

# Medium task — 2 agents working in parallel
/run my-project "Research EDR solutions and compare CrowdStrike vs SentinelOne"

# Simple task — single agent
/run my-project "Write a new hire laptop provisioning checklist"

# Preview the plan without executing
/run my-project "Generate SSO migration runbook" --dry-run
```

Agents produce artifacts — scripts, reports, config profiles, runbooks — saved to `projects/{slug}/artifacts/`.

### Inbox & Communication

```
# Triage your inbox (Slack, email) with AI prioritization
/triage

# Capture a Slack thread into a project log
/capture

# Post your standup to Slack
/standup --slack
```

### Vendor Management

```
# Track vendor account reps, contracts, and renewals
/enrich "CrowdStrike"

# Check which vendors need follow-up
/enrich stale

# See upcoming renewals
/enrich renewals
```

### End of Day

```
# Generate standup from today's activity
/standup

# Run a retrospective on your work patterns
/retro
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
| `/run` | Execute tasks with a team of agents — research, build, document |

Most commands support `--slack` to post output to a Slack channel.

---

## Agents

The system uses 5 specialized agents under the hood:

| Agent | Role |
|-------|------|
| **project-manager** | Strategy, planning, project lifecycle, dashboards |
| **tasker** | Kanban boards, task CRUD, standups |
| **documenter** | Structured logging, decisions, search |
| **advisor** | Work pattern analysis, retrospectives, improvement suggestions |
| **chief-of-staff** | Morning briefings, inbox triage, vendor CRM, goal tracking |

The `/run` command additionally spawns **researcher**, **builder**, and **writer** agents as needed for task execution.

---

## Project Structure

```
project-manager/
├── CLAUDE.md                     # System instructions — the brain
├── goals.yaml                    # Quarterly objectives
├── schedules.yaml                # Automation schedules
├── contacts/                     # Vendor CRM (one file per vendor)
│   └── example-contact.md        # Template: account rep, contract, escalation
├── projects/
│   ├── _registry.md              # Master index of all projects
│   ├── _observations.md          # Advisor pattern analysis
│   ├── _slack.md                 # Slack integration config
│   └── {project-slug}/
│       ├── README.md             # Overview, goals, milestones
│       ├── board.md              # Kanban board
│       ├── log.md                # Activity log
│       └── artifacts/            # Generated scripts, reports, configs
├── templates/                    # Scaffolding for new projects
├── sounds/                       # Sound effects for hooks
└── .claude/
    ├── settings.json             # Hook config + agent teams
    ├── agents/                   # 5 specialized agent definitions
    ├── commands/                 # 15 slash command definitions
    └── hooks/                    # 6 automation hooks
```

---

## Hooks

Hooks run automatically during your session:

| Hook | Trigger | What It Does |
|------|---------|-------------|
| Session start | On launch | Shows project count, active tasks, blockers |
| Advisor nudge | On launch | Flags overdue tasks, stale goals, WIP overload |
| Recent activity | On launch | Summarizes what you worked on recently |
| Sync progress | After edits | Auto-updates project progress when boards change |
| Validate log | Before edits | Enforces log entry structure |
| Protect registry | Before writes | Prevents registry corruption |

---

## MCP Integration

Connect external services via [MCPorter](https://mcporter.com) for a richer experience:

| Server | What It Enables |
|--------|-----------------|
| Slack | Inbox triage, channel monitoring, posting updates, thread capture |
| Gmail | Email triage, draft responses |
| Google Calendar | Morning briefing calendar view |

The system degrades gracefully — commands skip unavailable services silently.

Run `/setup` to check what's connected.

---

## Setup

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and configured
- Git

### Installation

1. Clone the repo:
   ```bash
   git clone https://github.com/YOUR_USERNAME/project-manager.git
   cd project-manager
   ```

2. Launch Claude Code:
   ```bash
   claude
   ```

3. Run the health check:
   ```
   /setup
   ```

4. (Optional) Connect MCP servers for Slack, Gmail, and Calendar via [MCPorter](https://mcporter.com).

5. Edit `goals.yaml` with your quarterly objectives.

6. Start your first project:
   ```
   /new-project
   ```

### Agent Teams

The `/run` command uses experimental agent teams. This is already enabled in `.claude/settings.json`. If you're running this in a separate Claude Code config, add:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

---

## Customization

| File | What to Customize |
|------|-------------------|
| `goals.yaml` | Your quarterly objectives — everything references these |
| `contacts/` | Add vendor files for account rep and contract tracking |
| `CLAUDE.md` | Core rules, agent behavior, conventions |
| `.claude/commands/` | Modify existing commands or create your own |
| `.claude/agents/` | Adjust agent personalities and responsibilities |
| `sounds/` | Swap out sound effects or remove them |

---

## License

MIT
