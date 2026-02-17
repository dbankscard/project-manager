# /board

Display the kanban board for a project.

## Usage

```
/board {project-slug}
```

## Parameters

- **project-slug** (required): The project's kebab-case slug

## Execution

Delegate to the **tasker** agent to:

1. Read `projects/{slug}/board.md`.
2. Count tasks in each column.
3. Calculate progress percentage (done / total).
4. Check for `blocked-by:` metadata on tasks — if the referenced task is NOT in the Done column, display a `BLOCKED` indicator next to the task.
5. Display the board with a summary line.

## Output Format

Display the full board content. Tasks with unresolved `blocked-by:` references show a `BLOCKED` indicator. Summary line:

```
---
Summary: X backlog | Y research | Z in-progress | W review | V done | N total | Progress: XX% | B blocked
```

## Examples

```
/board jamf-migration
/board saas-audit
```
