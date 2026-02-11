#!/bin/bash
# Hook: SessionStart — show active project summary when session begins
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SOUNDS="$PROJECT_DIR/sounds"
REGISTRY="$PROJECT_DIR/projects/_registry.md"

# Play session start sound
afplay "$SOUNDS/gamestart.mp3" &

if [[ ! -f "$REGISTRY" ]]; then
  echo "Project manager ready. No projects tracked yet. Use /new-project to get started."
  exit 0
fi

# Count projects — data rows contain links like [Name](projects/
PROJECT_COUNT=$(grep -c 'projects/' "$REGISTRY" 2>/dev/null) || PROJECT_COUNT=0

if [[ "$PROJECT_COUNT" -eq 0 ]]; then
  echo "Project manager ready. No projects tracked yet. Use /new-project to get started."
  exit 0
fi

# Gather quick stats
ACTIVE=$(grep -c '| active |' "$REGISTRY" 2>/dev/null) || ACTIVE=0
PLANNING=$(grep -c '| planning |' "$REGISTRY" 2>/dev/null) || PLANNING=0
ON_HOLD=$(grep -c '| on-hold |' "$REGISTRY" 2>/dev/null) || ON_HOLD=0

# Count in-progress tasks across all boards
IN_PROGRESS=0
for board in "$PROJECT_DIR"/projects/*/board.md; do
  [[ -f "$board" ]] || continue
  COUNT=$(awk '
    /^## In Progress$/ { found=1; next }
    found && /^## / { found=0; next }
    found && /^- \[ \]/ { count++ }
    END { print count+0 }
  ' "$board" 2>/dev/null || echo "0")
  IN_PROGRESS=$((IN_PROGRESS + COUNT))
done

# Check for recent blockers across all log files
BLOCKER_COUNT=0
TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "yesterday" +%Y-%m-%d 2>/dev/null || echo "")
for logfile in "$PROJECT_DIR"/projects/*/log.md; do
  [[ -f "$logfile" ]] || continue
  if [[ -n "$YESTERDAY" ]]; then
    COUNT=$(grep -c "\[blocker\]" "$logfile" 2>/dev/null) || COUNT=0
    if [[ "$COUNT" -gt 0 ]]; then
      RECENT=$(grep -E "($TODAY|$YESTERDAY).*\[blocker\]|\[blocker\].*($TODAY|$YESTERDAY)" "$logfile" 2>/dev/null | wc -l | tr -d ' ')
      BLOCKER_COUNT=$((BLOCKER_COUNT + RECENT))
    fi
  fi
done

echo "Project Manager — $PROJECT_COUNT projects ($ACTIVE active, $PLANNING planning, $ON_HOLD on hold) | $IN_PROGRESS tasks in progress | $BLOCKER_COUNT recent blockers"
echo ""
echo "Commands: /dash /new-project /task /log /board /plan /standup /search"
