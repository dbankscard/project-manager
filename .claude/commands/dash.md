# /dash

Display the project dashboard — an overview of all tracked projects.

## Usage

```
/dash
```

## Parameters

None.

## Execution

Delegate to the **project-manager** agent to:

1. Read `projects/_registry.md`.
2. For each project, optionally read the README for additional context.
3. Format and display using the dashboard format.
4. Include summary counts.

## Output Format

```markdown
# Project Dashboard

| Project | Status | Priority | Progress | Next Milestone |
|---------|--------|----------|----------|----------------|
| [Project Name](projects/slug/README.md) | active | P1 | 35% | Milestone name |

---
Summary: X active projects | Y tasks in progress | Z blockers
```

If no projects exist, display:
```
No projects tracked yet. Use /new-project to create one.
```

## Examples

```
/dash
```
