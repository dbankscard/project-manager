#!/bin/bash
# Scan ~/Projects/ for active worktrees and uncommitted changes on session start

PROJECTS_DIR="$HOME/Projects"

if [ ! -d "$PROJECTS_DIR" ]; then
  exit 0
fi

worktrees=""
uncommitted=""

for dir in "$PROJECTS_DIR"/*/; do
  [ -d "$dir" ] || continue

  # Check if it's a git repo
  if [ ! -d "$dir/.git" ] && [ ! -f "$dir/.git" ]; then
    continue
  fi

  repo_name=$(basename "$dir")

  # Check for active worktrees (more than just the main one)
  wt_count=$(git -C "$dir" worktree list 2>/dev/null | wc -l | tr -d ' ')
  if [ "$wt_count" -gt 1 ]; then
    # Get non-main worktrees
    while IFS= read -r line; do
      wt_path=$(echo "$line" | awk '{print $1}')
      wt_branch=$(echo "$line" | grep -o '\[.*\]' | tr -d '[]')
      # Skip the main worktree
      if [ "$wt_path" = "${dir%/}" ]; then
        continue
      fi
      worktrees="${worktrees}\n- ${repo_name}: ${wt_branch}"
    done <<< "$(git -C "$dir" worktree list 2>/dev/null)"
  fi

  # Check for uncommitted changes
  changes=$(git -C "$dir" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "$changes" -gt 0 ]; then
    branch=$(git -C "$dir" branch --show-current 2>/dev/null)
    uncommitted="${uncommitted}\n- ${repo_name}: ${changes} modified files on ${branch:-detached}"
  fi
done

# Only output if there's something to report
if [ -n "$worktrees" ] || [ -n "$uncommitted" ]; then
  echo "# Workspace Status"
  if [ -n "$worktrees" ]; then
    echo ""
    echo "Active worktrees:"
    echo -e "$worktrees"
  fi
  if [ -n "$uncommitted" ]; then
    echo ""
    echo "Uncommitted changes:"
    echo -e "$uncommitted"
  fi
fi
