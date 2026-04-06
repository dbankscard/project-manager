# /focus

Enter an isolated worktree in a tracked project's real repo for focused work. Changes stay on a branch until explicitly merged back.

## Usage

```
/focus {slug}
/focus {slug} {branch-name}
/focus done
/focus discard
/focus status
```

## Parameters

- **slug** (required for start): The project's kebab-case slug — must be a tracked project with a linked repo in `~/Projects/`.
- **branch-name** (optional): Custom branch name. Default: `focus-{slug}-{date}`.
- **done**: Commit changes, merge back to the repo's main branch, and clean up the worktree.
- **discard**: Discard all worktree changes and remove it.
- **status**: List all active worktrees across tracked projects.

## Execution

### Starting a Focus Session

Delegate to the **chief-of-staff** agent to:

1. **Resolve the repo** — look up the project in `projects/_registry.md`, find the `Repo` column to get the `~/Projects/` path.
2. **Validate** — confirm the repo exists and is a git repo.
3. **Create worktree** — run `git worktree add` in the target repo to create an isolated branch.
4. **Enter worktree** — use `EnterWorktree` or switch context to the worktree directory.
5. **Show context** — display the project board and any in-progress tasks.
6. **Log it** — add a `[note]` entry to the project log: "Started focus session on branch {branch}".

### Finishing (`/focus done`)

1. **Check status** — show uncommitted changes in the worktree.
2. **Commit** — stage and commit changes with a descriptive message (confirm with user).
3. **Merge** — switch to main branch, merge the focus branch.
4. **Clean up** — remove the worktree via `git worktree remove`.
5. **Log it** — add a `[change]` entry to the project log summarizing what was done.

### Discarding (`/focus discard`)

1. **Confirm** — show what will be lost (uncommitted changes, commits on the branch).
2. **Remove** — `git worktree remove --force` and delete the branch.
3. **Log it** — add a `[note]` entry: "Discarded focus session on branch {branch}".

### Status (`/focus status`)

1. **Scan tracked repos** — for each project in the registry with a repo path, run `git worktree list`.
2. **Display** — show active worktrees with branch name, age, and uncommitted change count.

## Output Format

### Start

```markdown
# Focus Session Started

Project: {name}
Repo: ~/Projects/{repo-name}
Branch: focus-{slug}-{date}
Worktree: ~/Projects/{repo-name}/.worktrees/focus-{slug}-{date}

## Current Board
(in-progress and backlog tasks shown here)

Ready to work. Use `/focus done` when finished or `/focus discard` to abandon.
```

### Status

```markdown
# Active Worktrees

| Project | Repo | Branch | Age | Changes |
|---------|------|--------|-----|---------|
| jamf-mcp-server | ~/Projects/jamf-mcp-server | focus-jamf-2026-04-06 | 3h | 2 uncommitted |
| project-manager | ~/Projects/project-manager | focus-pm-2026-04-05 | 1d | clean |

Use `/focus done` or `/focus discard` to close a session.
```

### Done

```markdown
# Focus Session Complete

Branch `focus-{slug}-{date}` merged into main.
Worktree removed.

## Changes
- 3 commits, 5 files modified
- Summary of key changes

Logged [change] entry to projects/{slug}/log.md.
```

## Examples

```
/focus jamf-mcp-server
/focus project-manager feature-worktrees
/focus done
/focus discard
/focus status
```
