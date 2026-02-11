#!/bin/bash
# Hook: PreToolUse (Edit) — validate log entries have required structure
set -euo pipefail

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Get the file path and new content
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
NEW_STRING=$(echo "$INPUT" | jq -r '.tool_input.new_string // empty')

# Only check edits to log.md files
if [[ -z "$FILE_PATH" ]] || [[ "$FILE_PATH" != *"/projects/"*"/log.md" ]]; then
  exit 0
fi

# If the edit contains a [decision] tag, verify the template fields are present
if echo "$NEW_STRING" | grep -q '\[decision\]'; then
  MISSING=""
  echo "$NEW_STRING" | grep -q '\*\*Decision:\*\*' || MISSING="Decision"
  echo "$NEW_STRING" | grep -q '\*\*Context:\*\*' || MISSING="${MISSING:+$MISSING, }Context"
  echo "$NEW_STRING" | grep -q '\*\*Rationale:\*\*' || MISSING="${MISSING:+$MISSING, }Rationale"
  echo "$NEW_STRING" | grep -q '\*\*Impact:\*\*' || MISSING="${MISSING:+$MISSING, }Impact"

  if [[ -n "$MISSING" ]]; then
    echo "Decision log entry is missing required fields: $MISSING. Decision entries must include Decision, Context, Rationale, and Impact sections." >&2
    exit 2
  fi
fi

# If the edit contains a [blocker] tag, check for actionable content
if echo "$NEW_STRING" | grep -q '\[blocker\]'; then
  # Blockers should be more than just a title — need some body content
  LINE_COUNT=$(echo "$NEW_STRING" | wc -l | tr -d ' ')
  if [[ "$LINE_COUNT" -lt 3 ]]; then
    echo "Blocker entries should include what is blocked and what would unblock it. Add more detail." >&2
    exit 2
  fi
fi

exit 0
