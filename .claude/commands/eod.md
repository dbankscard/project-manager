# /eod

End-of-day wrap-up — review today's work, detect gaps, and plan tomorrow.

## Usage

```
/eod [--commit]
```

## Parameters

- **--commit** (optional): Stage all project file changes, commit with today's summary, and push.

## Execution

Delegate to the **chief-of-staff** agent to:

1. **Review today's activity:**
   - Read all `projects/*/log.md` — find entries with today's date.
   - Read all `projects/*/board.md` — find tasks with `done:` today's date.
   - Summarize what was accomplished.

2. **Detect unlogged work:**
   - Compare tasks marked done today against `[change]` log entries for today.
   - If a task was completed but has no corresponding log entry, flag it as a gap.
   - Suggest log entries for each gap (with pre-filled tag and content).

3. **Plan tomorrow:**
   - Identify the top 3 highest-priority tasks from in-progress and backlog columns across all active projects.
   - Surface any tasks due tomorrow or the next business day.
   - Flag upcoming blockers or deadlines.

4. **If `--commit` is passed:**
   - Stage all changes in `projects/` and `contacts/` directories.
   - Create a git commit with message: `Daily update — YYYY-MM-DD: X tasks completed, Y log entries`
   - Push to remote.
   - **Always confirm with the user before pushing.**

## Output Format

```markdown
# End of Day — YYYY-MM-DD

## Completed Today
- [project] Task or activity description

## Unlogged Work
- [project] "Task description" was completed but has no [change] entry
  Suggested: [change] Task description — details

## Tomorrow's Focus
1. [project] Task description `P1` `due:YYYY-MM-DD`
2. [project] Task description `P1`
3. [project] Task description `P2`

## Upcoming
- [project] Task due YYYY-MM-DD (in X days)
- [project] Blocker needs resolution by YYYY-MM-DD
```

## Examples

```
/eod
/eod --commit
```
