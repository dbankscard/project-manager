#!/bin/bash
# Hook: SessionStart — lightweight advisor nudges based on real-time project checks
# Runs quick checks and surfaces the most important thing to address
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Check if any projects exist
shopt -s nullglob
BOARDS=("$PROJECT_DIR"/projects/*/board.md)
shopt -u nullglob

if [[ ${#BOARDS[@]} -eq 0 ]]; then
  exit 0
fi

TODAY=$(date +%Y-%m-%d)
NUDGES=""

# --- Check 1: WIP overload (more than 3 tasks in-progress across all projects) ---
TOTAL_WIP=0
for board in "${BOARDS[@]}"; do
  COUNT=$(awk '
    /^## In Progress$/ { found=1; next }
    found && /^## / { found=0; next }
    found && /^- \[ \]/ { count++ }
    END { print count+0 }
  ' "$board" 2>/dev/null || echo "0")
  TOTAL_WIP=$((TOTAL_WIP + COUNT))
done

if [[ "$TOTAL_WIP" -gt 3 ]]; then
  NUDGES="${NUDGES}[advisor] You have $TOTAL_WIP tasks in progress. Consider finishing some before starting new work — a WIP limit of 3 helps maintain focus.\n"
fi

# --- Check 2: Overdue tasks ---
OVERDUE=""
for board in "${BOARDS[@]}"; do
  SLUG=$(basename "$(dirname "$board")")
  while IFS= read -r line; do
    DUE_DATE=$(echo "$line" | grep -oE 'due:[0-9]{4}-[0-9]{2}-[0-9]{2}' | cut -d: -f2)
    if [[ -n "$DUE_DATE" && "$DUE_DATE" < "$TODAY" ]]; then
      TASK_DESC=$(echo "$line" | sed 's/^- \[ \] //' | sed 's/ `[^`]*`//g' | head -c 60)
      OVERDUE="${OVERDUE}  - [$SLUG] $TASK_DESC (due $DUE_DATE)\n"
    fi
  done < <(grep '^\- \[ \].*due:' "$board" 2>/dev/null || true)
done

if [[ -n "$OVERDUE" ]]; then
  NUDGES="${NUDGES}[advisor] Overdue tasks:\n${OVERDUE}"
fi

# --- Check 3: Stale blockers (blocker log entries older than 3 days with no resolution) ---
STALE_BLOCKERS=""
for logfile in "$PROJECT_DIR"/projects/*/log.md; do
  [[ -f "$logfile" ]] || continue
  SLUG=$(basename "$(dirname "$logfile")")

  # Find blocker entries with dates
  while IFS= read -r line; do
    BLOCKER_DATE=$(echo "$line" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
    if [[ -n "$BLOCKER_DATE" ]]; then
      # Calculate days since blocker (macOS date math)
      BLOCKER_EPOCH=$(date -j -f "%Y-%m-%d" "$BLOCKER_DATE" "+%s" 2>/dev/null || echo "0")
      TODAY_EPOCH=$(date "+%s")
      if [[ "$BLOCKER_EPOCH" -gt 0 ]]; then
        DAYS_OLD=$(( (TODAY_EPOCH - BLOCKER_EPOCH) / 86400 ))
        if [[ "$DAYS_OLD" -ge 3 ]]; then
          TITLE=$(echo "$line" | sed 's/^### [0-9-]* [0-9:]* — \[blocker\] //')
          STALE_BLOCKERS="${STALE_BLOCKERS}  - [$SLUG] $TITLE (${DAYS_OLD} days)\n"
        fi
      fi
    fi
  done < <(grep '\[blocker\]' "$logfile" 2>/dev/null || true)
done

if [[ -n "$STALE_BLOCKERS" ]]; then
  NUDGES="${NUDGES}[advisor] Unresolved blockers aging out:\n${STALE_BLOCKERS}"
fi

# --- Check 4: Dormant projects (no log entries in 5+ days) ---
for logfile in "$PROJECT_DIR"/projects/*/log.md; do
  [[ -f "$logfile" ]] || continue
  SLUG=$(basename "$(dirname "$logfile")")

  LATEST_DATE=$(grep -oE '^### [0-9]{4}-[0-9]{2}-[0-9]{2}' "$logfile" 2>/dev/null | head -1 | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
  if [[ -n "$LATEST_DATE" ]]; then
    LATEST_EPOCH=$(date -j -f "%Y-%m-%d" "$LATEST_DATE" "+%s" 2>/dev/null || echo "0")
    TODAY_EPOCH=$(date "+%s")
    if [[ "$LATEST_EPOCH" -gt 0 ]]; then
      DAYS_DORMANT=$(( (TODAY_EPOCH - LATEST_EPOCH) / 86400 ))
      if [[ "$DAYS_DORMANT" -ge 5 ]]; then
        NUDGES="${NUDGES}[advisor] Project \"$SLUG\" has had no activity for $DAYS_DORMANT days. Still active?\n"
      fi
    fi
  fi
done

# --- Check 5: Priority inversion (P3 in-progress while P1 in backlog) ---
HAS_P1_BACKLOG=false
HAS_LOW_PRI_WIP=false
for board in "${BOARDS[@]}"; do
  P1_BACKLOG=$(awk '
    /^## Backlog$/ { found=1; next }
    found && /^## / { found=0; next }
    found && /`P1`|`P0`/ { count++ }
    END { print count+0 }
  ' "$board" 2>/dev/null || echo "0")

  LOW_PRI_WIP=$(awk '
    /^## In Progress$/ { found=1; next }
    found && /^## / { found=0; next }
    found && /`P3`/ { count++ }
    END { print count+0 }
  ' "$board" 2>/dev/null || echo "0")

  [[ "$P1_BACKLOG" -gt 0 ]] && HAS_P1_BACKLOG=true
  [[ "$LOW_PRI_WIP" -gt 0 ]] && HAS_LOW_PRI_WIP=true
done

if [[ "$HAS_P1_BACKLOG" == true && "$HAS_LOW_PRI_WIP" == true ]]; then
  NUDGES="${NUDGES}[advisor] You have P1 tasks waiting in backlog while P3 tasks are in progress. Consider reprioritizing.\n"
fi

# --- Output nudges (limit to top 3 to avoid noise) ---
if [[ -n "$NUDGES" ]]; then
  # Play nudge sound
  afplay "$PROJECT_DIR/sounds/retro-cartoon-jump.mp3" &
  echo ""
  printf "$NUDGES" | head -12
fi

exit 0
