#!/bin/bash
# Hook: SessionStart — remind user to run /weekly on Fridays or Mondays
# Checks: day of week, whether a weekly report exists for the current week
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Only nudge on Fridays (5) and Mondays (1)
DOW=$(date +%u)
if [[ "$DOW" != "5" && "$DOW" != "1" ]]; then
  exit 0
fi

# Check if any projects exist
shopt -s nullglob
BOARDS=("$PROJECT_DIR"/projects/*/board.md)
shopt -u nullglob

if [[ ${#BOARDS[@]} -eq 0 ]]; then
  exit 0
fi

# Calculate the Monday of the current week (for checking if report already exists)
if [[ "$DOW" == "1" ]]; then
  # It's Monday — check for last week's report
  WEEK_START=$(date -v-7d +%Y-%m-%d 2>/dev/null || date -d "7 days ago" +%Y-%m-%d 2>/dev/null || echo "")
else
  # It's Friday — check for this week's report
  WEEK_START=$(date -v-$((DOW-1))d +%Y-%m-%d 2>/dev/null || date -d "$((DOW-1)) days ago" +%Y-%m-%d 2>/dev/null || echo "")
fi

# Count log entries from the past 7 days to see if there's reportable activity
WEEK_ACTIVITY=0
for logfile in "$PROJECT_DIR"/projects/*/log.md; do
  [[ -f "$logfile" ]] || continue
  # Count entries from the last 7 days
  for i in $(seq 0 6); do
    CHECK_DATE=$(date -v-${i}d +%Y-%m-%d 2>/dev/null || date -d "$i days ago" +%Y-%m-%d 2>/dev/null || echo "")
    if [[ -n "$CHECK_DATE" ]]; then
      COUNT=$(grep -c "^### $CHECK_DATE" "$logfile" 2>/dev/null) || COUNT=0
      WEEK_ACTIVITY=$((WEEK_ACTIVITY + COUNT))
    fi
  done
done

# Count tasks completed this week
TASKS_DONE_WEEK=0
for board in "${BOARDS[@]}"; do
  for i in $(seq 0 6); do
    CHECK_DATE=$(date -v-${i}d +%Y-%m-%d 2>/dev/null || date -d "$i days ago" +%Y-%m-%d 2>/dev/null || echo "")
    if [[ -n "$CHECK_DATE" ]]; then
      COUNT=$(grep -c "done:$CHECK_DATE" "$board" 2>/dev/null) || COUNT=0
      TASKS_DONE_WEEK=$((TASKS_DONE_WEEK + COUNT))
    fi
  done
done

# Only nudge if there's activity worth reporting
if [[ "$WEEK_ACTIVITY" -eq 0 && "$TASKS_DONE_WEEK" -eq 0 ]]; then
  exit 0
fi

if [[ "$DOW" == "5" ]]; then
  echo "[weekly] It's Friday. You have $WEEK_ACTIVITY log entries and $TASKS_DONE_WEEK completed tasks this week. Run /weekly to generate your status report."
else
  echo "[weekly] It's Monday. Last week: $WEEK_ACTIVITY log entries, $TASKS_DONE_WEEK tasks completed. Run /weekly if you haven't sent your status report yet."
fi

exit 0
