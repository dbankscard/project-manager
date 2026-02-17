#!/bin/bash
# Hook: SessionStart — remind user to run /eod in afternoon sessions
# Checks: time of day, unlogged completed tasks from today
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Only nudge after 4 PM local time
HOUR=$(date +%H)
if [[ "$HOUR" -lt 16 ]]; then
  exit 0
fi

# Check if any projects exist
shopt -s nullglob
BOARDS=("$PROJECT_DIR"/projects/*/board.md)
shopt -u nullglob

if [[ ${#BOARDS[@]} -eq 0 ]]; then
  exit 0
fi

TODAY=$(date +%Y-%m-%d)

# Count tasks completed today
TASKS_DONE_TODAY=0
for board in "${BOARDS[@]}"; do
  COUNT=$(grep -c "^\- \[x\].*done:$TODAY" "$board" 2>/dev/null) || COUNT=0
  TASKS_DONE_TODAY=$((TASKS_DONE_TODAY + COUNT))
done

# Count log entries from today
LOG_ENTRIES_TODAY=0
for logfile in "$PROJECT_DIR"/projects/*/log.md; do
  [[ -f "$logfile" ]] || continue
  COUNT=$(grep -c "^### $TODAY" "$logfile" 2>/dev/null) || COUNT=0
  LOG_ENTRIES_TODAY=$((LOG_ENTRIES_TODAY + COUNT))
done

# Count change entries specifically (to detect unlogged work)
CHANGE_ENTRIES_TODAY=0
for logfile in "$PROJECT_DIR"/projects/*/log.md; do
  [[ -f "$logfile" ]] || continue
  COUNT=$(grep -c "^### $TODAY.*\[change\]" "$logfile" 2>/dev/null) || COUNT=0
  CHANGE_ENTRIES_TODAY=$((CHANGE_ENTRIES_TODAY + COUNT))
done

# Detect unlogged work: tasks done today without matching change entries
UNLOGGED=$((TASKS_DONE_TODAY - CHANGE_ENTRIES_TODAY))
if [[ "$UNLOGGED" -lt 0 ]]; then
  UNLOGGED=0
fi

# Build nudge
NUDGE=""

if [[ "$TASKS_DONE_TODAY" -gt 0 && "$UNLOGGED" -gt 0 ]]; then
  NUDGE="[eod] You completed $TASKS_DONE_TODAY task(s) today with $UNLOGGED potentially unlogged. Run /eod to wrap up and capture gaps."
elif [[ "$TASKS_DONE_TODAY" -gt 0 ]]; then
  NUDGE="[eod] You completed $TASKS_DONE_TODAY task(s) today. Run /eod to review your day and plan tomorrow."
elif [[ "$LOG_ENTRIES_TODAY" -gt 0 ]]; then
  NUDGE="[eod] You have $LOG_ENTRIES_TODAY log entries today. Run /eod to wrap up and plan tomorrow."
fi

if [[ -n "$NUDGE" ]]; then
  echo "$NUDGE"
fi

exit 0
