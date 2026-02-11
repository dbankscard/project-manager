# /plan

AI-powered project planning — break down a description into goals, milestones, and tasks.

## Usage

```
/plan "Description of what needs to be accomplished" [--project {slug}]
```

## Parameters

- **description** (required): A natural language description of the project or initiative
- **--project** (optional): Existing project slug to plan into. If omitted, creates a new project first.

## Execution

Delegate to the **project-manager** agent to:

1. If no `--project` specified, create a new project from the description.
2. Analyze the description and generate:
   - **3-5 concrete goals** — measurable outcomes
   - **Milestones** with target dates — key checkpoints
   - **Tasks** with priorities and tags — actionable work items
3. Write goals and milestones to the project's `README.md`.
4. Populate the kanban board (`board.md`) with tasks in the Backlog column.
5. Add a `[note]` log entry documenting the plan.
6. Update progress in the registry.
7. Display the generated plan.

## Output Format

```markdown
# Plan: {Project Name}

## Goals
1. Goal one
2. Goal two
3. Goal three

## Milestones
| Milestone | Target Date | Tasks |
|-----------|-------------|-------|
| First milestone | 2026-03-01 | 3 tasks |

## Tasks Added (X total)
- [ ] Task one `P1` `#tag`
- [ ] Task two `P2` `#tag`
...

Plan saved to projects/{slug}/
```

## Examples

```
/plan "Migrate 450 Macs from Mosyle to Jamf Pro before May 1st"
/plan "Audit all SaaS subscriptions and reduce spend by 20%" --project saas-audit
/plan "Build an internal IT dashboard for tracking hardware inventory"
```
