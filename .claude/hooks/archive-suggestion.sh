#!/bin/bash
# Hook: SessionStart — suggest archiving done or deeply dormant projects
# Checks: projects with "done" status, projects with no activity for 30+ days
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
REGISTRY="$PROJECT_DIR/projects/_registry.md"

if [[ ! -f "$REGISTRY" ]]; then
  exit 0
fi

TODAY_EPOCH=$(date "+%s")
SUGGESTIONS=""

# --- Check 1: Projects with "done" status still in active registry ---
DONE_PROJECTS=""
while IFS= read -r line; do
  SLUG=$(echo "$line" | grep -oE '\(projects/[^/]+/README.md\)' | sed 's|(projects/||;s|/README.md)||')
  if [[ -n "$SLUG" ]]; then
    DONE_PROJECTS="${DONE_PROJECTS}  - $SLUG\n"
  fi
done < <(grep '| done |' "$REGISTRY" 2>/dev/null || true)

if [[ -n "$DONE_PROJECTS" ]]; then
  SUGGESTIONS="${SUGGESTIONS}[archive] Completed projects still in active registry:\n${DONE_PROJECTS}  Run /archive {slug} to move them to the archive.\n"
fi

# --- Check 2: Projects with no log activity for 30+ days ---
DORMANT=""
for logfile in "$PROJECT_DIR"/projects/*/log.md; do
  [[ -f "$logfile" ]] || continue
  SLUG=$(basename "$(dirname "$logfile")")
  [[ "$SLUG" == _* ]] && continue

  # Skip projects already flagged as done
  if grep -q "| done |" "$REGISTRY" 2>/dev/null && grep -q "$SLUG" <<< "$(grep '| done |' "$REGISTRY")"; then
    continue
  fi

  LATEST_DATE=$(grep -oE '^### [0-9]{4}-[0-9]{2}-[0-9]{2}' "$logfile" 2>/dev/null | head -1 | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
  if [[ -n "$LATEST_DATE" ]]; then
    LATEST_EPOCH=$(date -j -f "%Y-%m-%d" "$LATEST_DATE" "+%s" 2>/dev/null || echo "0")
    if [[ "$LATEST_EPOCH" -gt 0 ]]; then
      DAYS_DORMANT=$(( (TODAY_EPOCH - LATEST_EPOCH) / 86400 ))
      if [[ "$DAYS_DORMANT" -ge 30 ]]; then
        DORMANT="${DORMANT}  - $SLUG (${DAYS_DORMANT} days inactive)\n"
      fi
    fi
  fi
done

if [[ -n "$DORMANT" ]]; then
  SUGGESTIONS="${SUGGESTIONS}[archive] Deeply dormant projects (30+ days inactive):\n${DORMANT}  Consider archiving with /archive {slug} or updating status.\n"
fi

if [[ -n "$SUGGESTIONS" ]]; then
  printf "$SUGGESTIONS"
fi

exit 0
