# /setup

Check system health — verify MCP server connections, local file setup, and guide through anything missing.

## Usage

```
/setup
```

## Parameters

None.

## Execution

Delegate to the **chief-of-staff** agent to perform the following checks in order:

### 1. Core Files Check

Verify the following files exist and are non-empty at the project root:

| File | Required | Purpose |
|------|----------|---------|
| `CLAUDE.md` | Yes | System instructions |
| `goals.yaml` | Yes | Quarterly objectives |
| `schedules.yaml` | No | Automation config |
| `contacts/` | No | Vendor CRM directory |
| `projects/_registry.md` | Yes | Project index |
| `projects/_slack.md` | No | Slack integration config |

For missing required files, offer to create them from templates.
For missing optional files, note them as recommendations.

### 2. MCP Server Checks

Test each MCP server by attempting a lightweight read-only call. Do NOT send any messages or modify any data.

**Slack**
- Try: `slack_search_channels` with a simple query like "general"
- If it works: report Connected, show workspace name if available
- If it fails: report Not Connected

**Gmail** (if available)
- Try: a simple email search or list
- If it works: report Connected
- If it fails: report Not Connected

**Google Calendar** (if available)
- Try: `get-current-time` or `list-events` for today
- If it works: report Connected
- If it fails: report Not Connected

**Important:** If an MCP tool doesn't exist at all (no matching tool available), report "Not Installed" rather than "Not Connected". Only test tools that are actually available.

### 3. Hook Verification

Check that hook scripts exist and are executable:

| Hook | File |
|------|------|
| Session start | `.claude/hooks/session-start.sh` |
| Advisor nudge | `.claude/hooks/advisor-nudge.sh` |
| Recent activity | `.claude/hooks/recent-activity.sh` |
| Sync progress | `.claude/hooks/sync-progress.sh` |
| Validate log entry | `.claude/hooks/validate-log-entry.sh` |
| Protect registry | `.claude/hooks/protect-registry.sh` |

### 4. Agent Verification

Check that all agent definition files exist in `.claude/agents/`:

- `project-manager.md`
- `tasker.md`
- `documenter.md`
- `advisor.md`
- `chief-of-staff.md`

### 5. Commands Verification

Check that all command files exist in `.claude/commands/`:

- `gm.md`, `triage.md`, `enrich.md`, `dash.md`, `task.md`, `board.md`
- `log.md`, `standup.md`, `plan.md`, `search.md`, `retro.md`
- `new-project.md`, `capture.md`, `setup.md`

## Output Format

```markdown
# System Setup — YYYY-MM-DD

## MCP Servers

| Server | Status | Notes |
|--------|--------|-------|
| Slack | Connected | workspace: your-workspace |
| Gmail | Not Installed | — |
| Google Calendar | Not Installed | — |

## Core Files

| File | Status |
|------|--------|
| CLAUDE.md | OK |
| goals.yaml | OK |
| projects/_registry.md | OK |
| contacts/ | OK (1 vendor file) |
| schedules.yaml | OK |

## Agents — 5/5 OK
## Commands — 14/14 OK
## Hooks — 6/6 OK (all executable)

## Recommendations

1. **Install Gmail MCP** — Enables /triage email scanning and /gm inbox briefing
   ```
   npx mcporter list --http-url https://gmail-mcp-url --name gmail
   ```

2. **Install Google Calendar MCP** — Enables /gm calendar view
   ```
   npx mcporter list --http-url https://calendar-mcp-url --name google-calendar
   ```

3. **Add vendor contacts** — Run `/enrich "Vendor Name"` to start tracking vendors

## Quick Fixes

- [if applicable] Run `chmod +x .claude/hooks/*.sh` to fix hook permissions
- [if applicable] Create goals.yaml with `/setup` or copy from template
```

## Guidelines

- Be factual — report exactly what's connected and what's not.
- Don't try to install or configure anything automatically — just report and guide.
- For MCP servers, provide the MCPorter command to install each missing server.
- Keep the output scannable — the user should know system health in 10 seconds.
- If everything is healthy, say so clearly and keep it short.

## Examples

```
/setup
```
