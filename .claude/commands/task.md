# /task

Create, move, or complete tasks on a project's kanban board.

## Usage

```
/task add {project-slug} "Task description" [P1|P2|P3] [#tag ...] [due:YYYY-MM-DD] [goal:goal-name] [recur:weekly|monthly|quarterly] [blocked-by:Task text]
/task move {project-slug} "Task description" {target-column}
/task done {project-slug} "Task description"
/task list {project-slug} [--priority P1] [--tag #tag] [--column in-progress] [--blocked]
```

## Actions

### add
Add a new task to the board (default column: Backlog).

### move
Move a task to a different column. Target columns: `backlog`, `research`, `in-progress`, `review`, `done`.

### done
Mark a task as complete — checks the checkbox, adds `done:` date, moves to Done column, updates progress. If the task has `recur:`, a new instance is auto-created in Backlog with the next due date. After completion, checks all boards for tasks with `blocked-by:` matching this task and flags newly unblocked tasks.

### list
List and filter tasks. Supports filtering by priority, tag, and column.

## Parameters

- **action** (required): `add`, `move`, `done`, or `list`
- **project-slug** (required): The project's kebab-case slug
- **description** (required for add/move/done): Task description text — used to match existing tasks
- **priority** (optional): `P0`, `P1`, `P2`, `P3` — default P2
- **tags** (optional): One or more `#tag` values
- **due date** (optional): `due:YYYY-MM-DD`
- **goal** (optional): `goal:goal-name` — link the task to a goal from `goals.yaml`
- **recurrence** (optional): `recur:weekly`, `recur:monthly`, `recur:quarterly` — auto-regenerate on completion
- **dependency** (optional): `blocked-by:Task text fragment` — marks task as blocked until the referenced task is done
- **--blocked** (optional, list only): Show only blocked tasks
- **target-column** (required for move): Destination column name

## Execution

Delegate to the **tasker** agent to:

1. Read the project's `board.md`.
2. For `add` actions: check `goals.yaml` and flag if the task doesn't align with any active goal.
3. Perform the requested action.
4. After completing tasks: recalculate progress, update README and registry.
5. Display confirmation.

## Task Format

```markdown
- [ ] Task description `P2` `#tag` `due:2026-03-15`
- [ ] Recurring task `P2` `#security` `due:2026-03-15` `recur:monthly`
- [ ] Blocked task `P1` `blocked-by:Other task description`
- [x] Completed task `P1` `#deploy` `done:2026-02-10`
```

## Examples

```
/task add jamf-migration "Test DEP token transfer" P1 #testing
/task add jamf-migration "Create migration runbook" P2 #docs due:2026-03-01
/task add jamf-migration "Review patch compliance" P2 #security due:2026-03-12 recur:monthly
/task add jamf-migration "Deploy profiles to prod" P1 blocked-by:Test profiles on pilot
/task move jamf-migration "Test DEP token transfer" in-progress
/task done jamf-migration "Test DEP token transfer"
/task list jamf-migration --priority P1
/task list jamf-migration --tag #testing
/task list jamf-migration --blocked
```
