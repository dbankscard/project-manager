# /task

Create, move, or complete tasks on a project's kanban board.

## Usage

```
/task add {project-slug} "Task description" [P1|P2|P3] [#tag ...] [due:YYYY-MM-DD]
/task move {project-slug} "Task description" {target-column}
/task done {project-slug} "Task description"
/task list {project-slug} [--priority P1] [--tag #tag] [--column in-progress]
```

## Actions

### add
Add a new task to the board (default column: Backlog).

### move
Move a task to a different column. Target columns: `backlog`, `research`, `in-progress`, `review`, `done`.

### done
Mark a task as complete — checks the checkbox, adds `done:` date, moves to Done column, updates progress.

### list
List and filter tasks. Supports filtering by priority, tag, and column.

## Parameters

- **action** (required): `add`, `move`, `done`, or `list`
- **project-slug** (required): The project's kebab-case slug
- **description** (required for add/move/done): Task description text — used to match existing tasks
- **priority** (optional): `P0`, `P1`, `P2`, `P3` — default P2
- **tags** (optional): One or more `#tag` values
- **due date** (optional): `due:YYYY-MM-DD`
- **target-column** (required for move): Destination column name

## Execution

Delegate to the **tasker** agent to:

1. Read the project's `board.md`.
2. Perform the requested action.
3. After completing tasks: recalculate progress, update README and registry.
4. Display confirmation.

## Task Format

```markdown
- [ ] Task description `P2` `#tag` `due:2026-03-15`
- [x] Completed task `P1` `#deploy` `done:2026-02-10`
```

## Examples

```
/task add jamf-migration "Test DEP token transfer" P1 #testing
/task add jamf-migration "Create migration runbook" P2 #docs due:2026-03-01
/task move jamf-migration "Test DEP token transfer" in-progress
/task done jamf-migration "Test DEP token transfer"
/task list jamf-migration --priority P1
/task list jamf-migration --tag #testing
```
