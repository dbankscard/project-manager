#!/bin/bash
# Hook: SessionStart — gather recent project activity so Claude can brief the user
# Outputs structured context about what happened in the last 2 days
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Check if any projects exist
shopt -s nullglob
PROJECT_DIRS=("$PROJECT_DIR"/projects/*/board.md)
shopt -u nullglob

if [[ ${#PROJECT_DIRS[@]} -eq 0 ]]; then
  exit 0
fi

TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "yesterday" +%Y-%m-%d 2>/dev/null || echo "")
DAY_BEFORE=$(date -v-2d +%Y-%m-%d 2>/dev/null || date -d "2 days ago" +%Y-%m-%d 2>/dev/null || echo "")

# Build a date pattern for grep (last 2 days)
DATE_PATTERN="$TODAY"
[[ -n "$YESTERDAY" ]] && DATE_PATTERN="$DATE_PATTERN|$YESTERDAY"
[[ -n "$DAY_BEFORE" ]] && DATE_PATTERN="$DATE_PATTERN|$DAY_BEFORE"

HAS_ACTIVITY=false
OUTPUT=""

for board in "$PROJECT_DIR"/projects/*/board.md; do
  [[ -f "$board" ]] || continue
  SLUG=$(basename "$(dirname "$board")")
  [[ "$SLUG" == "_registry.md" ]] && continue

  LOGFILE="$PROJECT_DIR/projects/$SLUG/log.md"
  README="$PROJECT_DIR/projects/$SLUG/README.md"
  PROJECT_OUTPUT=""

  # Get project name from README
  PROJECT_NAME="$SLUG"
  if [[ -f "$README" ]]; then
    FIRST_LINE=$(head -1 "$README" 2>/dev/null || echo "")
    if [[ "$FIRST_LINE" =~ ^#\  ]]; then
      PROJECT_NAME="${FIRST_LINE#\# }"
    fi
  fi

  # --- Recent log entries (last 2 days) ---
  RECENT_LOGS=""
  if [[ -f "$LOGFILE" ]]; then
    # Extract log entries with dates matching the last 2 days
    # Log entry headers look like: ### YYYY-MM-DD HH:MM — [tag] Title
    RECENT_LOGS=$(awk -v pattern="($DATE_PATTERN)" '
      /^### [0-9]{4}-[0-9]{2}-[0-9]{2}/ {
        if (match($0, pattern)) {
          printing = 1
          print
          next
        } else {
          printing = 0
        }
      }
      /^---$/ {
        if (printing) { print ""; printing = 0 }
        next
      }
      printing { print }
    ' "$LOGFILE" 2>/dev/null || echo "")
  fi

  # --- Recently completed tasks (have done: date in last 2 days) ---
  DONE_TASKS=""
  DONE_TASKS=$(grep -E "^\- \[x\].*done:($DATE_PATTERN)" "$board" 2>/dev/null || echo "")

  # --- Current in-progress tasks ---
  IN_PROGRESS_TASKS=""
  IN_PROGRESS_TASKS=$(awk '
    /^## In Progress$/ { found=1; next }
    found && /^## / { found=0; next }
    found && /^- \[/ { print }
  ' "$board" 2>/dev/null || echo "")

  # --- Current review tasks ---
  REVIEW_TASKS=""
  REVIEW_TASKS=$(awk '
    /^## Review$/ { found=1; next }
    found && /^## / { found=0; next }
    found && /^- \[/ { print }
  ' "$board" 2>/dev/null || echo "")

  # --- Active blockers ---
  BLOCKERS=""
  if [[ -f "$LOGFILE" ]]; then
    BLOCKERS=$(awk -v pattern="($DATE_PATTERN)" '
      /^### [0-9]{4}-[0-9]{2}-[0-9]{2}.*\[blocker\]/ {
        if (match($0, pattern)) {
          printing = 1
          print
          next
        } else {
          printing = 0
        }
      }
      /^---$/ { printing = 0; next }
      printing { print }
    ' "$LOGFILE" 2>/dev/null || echo "")
  fi

  # --- Board progress ---
  TOTAL=$(grep -c '^\- \[[ x]\]' "$board" 2>/dev/null) || TOTAL=0
  DONE_COUNT=$(grep -c '^\- \[x\]' "$board" 2>/dev/null) || DONE_COUNT=0
  if [[ "$TOTAL" -gt 0 ]]; then
    PROGRESS=$(( (DONE_COUNT * 100) / TOTAL ))
  else
    PROGRESS=0
  fi

  # Only include projects with some activity or work in progress
  if [[ -n "$RECENT_LOGS" || -n "$DONE_TASKS" || -n "$IN_PROGRESS_TASKS" || -n "$REVIEW_TASKS" || -n "$BLOCKERS" ]]; then
    HAS_ACTIVITY=true
    PROJECT_OUTPUT="## $PROJECT_NAME ($SLUG) — ${PROGRESS}% complete"
    PROJECT_OUTPUT="$PROJECT_OUTPUT
"

    if [[ -n "$DONE_TASKS" ]]; then
      PROJECT_OUTPUT="$PROJECT_OUTPUT
### Recently Completed
$DONE_TASKS
"
    fi

    if [[ -n "$IN_PROGRESS_TASKS" ]]; then
      PROJECT_OUTPUT="$PROJECT_OUTPUT
### In Progress
$IN_PROGRESS_TASKS
"
    fi

    if [[ -n "$REVIEW_TASKS" ]]; then
      PROJECT_OUTPUT="$PROJECT_OUTPUT
### In Review
$REVIEW_TASKS
"
    fi

    if [[ -n "$BLOCKERS" ]]; then
      PROJECT_OUTPUT="$PROJECT_OUTPUT
### Blockers
$BLOCKERS
"
    fi

    if [[ -n "$RECENT_LOGS" ]]; then
      PROJECT_OUTPUT="$PROJECT_OUTPUT
### Recent Log Entries
$RECENT_LOGS
"
    fi

    OUTPUT="$OUTPUT
$PROJECT_OUTPUT"
  fi
done

if [[ "$HAS_ACTIVITY" == true ]]; then
  echo "# Recent Activity (last 2 days)"
  echo ""
  echo "Review the following and give the user a brief summary of where they left off, what's in progress, and any blockers. Keep it conversational."
  echo "$OUTPUT"
fi

exit 0
