# /run

Execute a task — spawn a team of agents to do the actual work in parallel, produce artifacts, and log results.

## Usage

```
/run {project-slug} "Task description or search text" [--dry-run]
```

## Parameters

- **project-slug** (required): The project to work within.
- **task** (required): Task description — matched against board tasks. If no exact match, uses the text as the work instruction.
- **--dry-run** (optional): Show the execution plan without doing the work. Good for reviewing before committing agent time.

## Execution

### Step 1: Find the Task

1. Read `projects/{slug}/board.md`.
2. Fuzzy-match the provided text against existing tasks.
3. If a match is found: use that task's description, priority, tags, and context.
4. If no match: treat the input text as an ad-hoc work instruction.
5. Move the matched task to `## In Progress` if not already there.

### Step 2: Gather Context

Before starting work, read:
- `projects/{slug}/README.md` — project goals, milestones, risks
- `projects/{slug}/log.md` — recent decisions, research, and blockers
- `projects/{slug}/board.md` — related tasks and current state
- `projects/{slug}/artifacts/` — any existing artifacts to build on
- `goals.yaml` — confirm goal alignment
- `contacts/` — relevant vendor info if the task involves a vendor

### Step 3: Plan the Work

Analyze the task and break it into parallel workstreams. Present an execution plan:

```
Ready to work on: [task title]
Project: [project-slug] | Priority: [P1] | Goal: [goal-name]

Team:
- researcher — Web research, vendor docs, API exploration
- builder — Scripts, automation, config profiles
- writer — Reports, runbooks, documentation

Plan:
1. [researcher] Research vendor documentation and best practices
2. [builder] Build scripts and configuration files
3. [writer] Generate audit report and runbook
   (2 and 3 run in parallel after 1 completes, or all run in parallel if independent)

Artifacts to create:
- artifacts/reports/filename.md — Description
- artifacts/scripts/script.sh — Description
- artifacts/configs/profile.mobileconfig — Description

Proceed? [Y/n]
```

Wait for user confirmation unless `--dry-run` is set (in which case, stop here).

**Team sizing:** Not every task needs 3 agents. Scale the team to the work:
- **Simple task** (single script, one report): 1 agent, no team needed
- **Medium task** (research + build): 2 agents in parallel
- **Complex task** (audit + build + document): 3+ agents with dependencies

### Step 4: Spawn the Team

Create a team using TeamCreate and spawn agents based on the plan:

1. **Create team**: `run-{slug}` (e.g., `run-mosyle-to-jamf`)
2. **Create tasks** in the team task list — one per workstream, with dependencies set via `blockedBy` where outputs feed into other agents.
3. **Spawn agents** with clear, specific prompts including:
   - The full project context gathered in Step 2
   - Their specific workstream and expected output
   - File paths for where to save artifacts (`projects/{slug}/artifacts/`)
   - Instructions to mark their task complete when done

**Agent types to use:**
- **researcher** (`general-purpose`): Web research, doc analysis, API exploration. Reads and reports, does not write artifacts.
- **builder** (`general-purpose`): Writes scripts, configs, automation. Has full file access.
- **writer** (`general-purpose`): Generates reports, runbooks, documentation. Has full file access.

Agents run in the background. Monitor via TaskList and collect results as they complete.

### Step 5: Collect and Assemble

As agents complete their work:

1. **Review artifacts** — Check that output files were created in `projects/{slug}/artifacts/`.
2. **Log results** — Add a `[result]` entry to the project log with:
   - What was produced
   - File paths to artifacts
   - Any assumptions or caveats
   - Suggested next steps
3. **Shut down the team** — Send shutdown requests to all agents, then TeamDelete.

### Step 6: Close Out

1. If the task is fully complete: offer to mark it done via `/task done`.
2. If partially complete: update the task with progress notes.
3. If the work revealed new tasks: suggest adding them to the board.
4. Display a summary of what was produced.

## Artifact Conventions

Artifacts are stored in `projects/{slug}/artifacts/`:

```
projects/my-project/artifacts/
├── reports/
│   ├── mosyle-audit-2026-02-16.md
│   └── device-inventory.csv
├── scripts/
│   ├── migrate-device.sh
│   ├── verify-enrollment.py
│   └── bulk-enroll.sh
├── configs/
│   ├── wifi-corporate.mobileconfig
│   ├── filevault-enforcement.mobileconfig
│   └── firewall-policy.xml
├── runbooks/
│   └── migration-runbook.md
└── templates/
    └── user-notification-email.md
```

**Naming conventions:**
- Use descriptive kebab-case filenames
- Include dates on reports: `audit-2026-02-16.md`
- Group by type in subdirectories when a project has many artifacts
- For simple projects, flat files in `artifacts/` are fine

**Artifact metadata:**
Each artifact should include a header comment or frontmatter noting:
- What it is and what it's for
- When it was generated
- What task/context produced it
- Any manual steps required before use

## Work Types

The team adapts its composition based on what's being asked:

### Audit / Report
- **researcher**: Pull data from connected APIs (MCP) or analyze provided input
- **writer**: Generate structured markdown reports with findings and recommendations
- Output: `artifacts/reports/`

### Script / Automation
- **researcher**: Research API docs, schemas, and best practices
- **builder**: Write shell scripts, Python, or other automation with error handling
- Output: `artifacts/scripts/`

### Configuration
- **researcher**: Research vendor-specific schemas and requirements
- **builder**: Generate config profiles (mobileconfig, XML, JSON, YAML)
- Output: `artifacts/configs/`

### Runbook / Documentation
- **researcher**: Gather prerequisites, dependencies, and verification steps
- **writer**: Create step-by-step procedures with rollback plans
- Output: `artifacts/runbooks/`

### Full Migration / Complex Work
- **researcher**: Audit source system, document current state
- **builder**: Build scripts, configs, and automation for target system
- **writer**: Generate migration runbook, audit report, and communication templates
- All agents work in parallel where possible, with dependencies managed via task list

## Output Format

After execution:

```markdown
# Run Complete — [task title]

## Team
- researcher — completed in X min
- builder — completed in X min
- writer — completed in X min

## Artifacts Created
- `artifacts/reports/mosyle-audit-2026-02-16.md` — Full audit of deployed profiles and apps
- `artifacts/scripts/export-mosyle-inventory.sh` — Script to pull device inventory via API
- `artifacts/configs/wifi-corporate.mobileconfig` — Recreated Wi-Fi profile for Jamf
- `artifacts/runbooks/migration-runbook.md` — Step-by-step migration procedure

## Logged
- [result] entry added to projects/mosyle-to-jamf/log.md

## Next Steps
- [ ] Review the audit report for accuracy
- [ ] Test the export script against Mosyle sandbox
- [ ] Suggested new task: "Build Jamf Smart Groups from Mosyle device groups"

Mark task done? [Y/n]
```

## Guidelines

- **Always plan before executing.** Show the plan and wait for approval.
- **Scale the team to the task.** Don't spawn 3 agents for a single script.
- **Set dependencies correctly.** If the builder needs research output, block it on the researcher.
- **Never send messages, deploy, or modify external systems** without explicit approval.
- **Artifacts should be usable immediately** — not drafts that need heavy editing.
- **Log everything.** Every run produces a `[result]` log entry.
- **Build on existing work.** Check `artifacts/` for prior output before starting fresh.
- **Be specific about assumptions.** If an agent had to guess (e.g., network SSID, server URL), flag it clearly.
- **Suggest follow-up tasks.** Good execution reveals the next step.
- **Clean up teams.** Always shut down agents and delete the team when work is done.

## Examples

```
# Complex — spawns a 3-agent team
/run mosyle-to-jamf "Audit Mosyle and build Jamf migration package"

# Medium — spawns 2 agents (research + build)
/run endpoint-security "Research EDR solutions and compare CrowdStrike vs SentinelOne"

# Simple — single agent, no team needed
/run onboarding "Write new hire laptop provisioning checklist"

# Dry run — show plan without executing
/run sso-rollout "Generate Okta SCIM provisioning script for Jamf" --dry-run
```
