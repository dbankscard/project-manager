#!/bin/bash
# Hook: PreToolUse (Edit) — validate log entries have required structure
set -euo pipefail

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
BLOCK_SOUND="$PROJECT_DIR/sounds/retro-fart.mp3"

# Get the file path and new content
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
NEW_STRING=$(echo "$INPUT" | jq -r '.tool_input.new_string // empty')

# Only check edits to log.md files
if [[ -z "$FILE_PATH" ]] || [[ "$FILE_PATH" != *"/projects/"*"/log.md" ]]; then
  exit 0
fi

# [decision] — require full template
if echo "$NEW_STRING" | grep -q '\[decision\]'; then
  MISSING=""
  echo "$NEW_STRING" | grep -q '\*\*Decision:\*\*' || MISSING="Decision"
  echo "$NEW_STRING" | grep -q '\*\*Context:\*\*' || MISSING="${MISSING:+$MISSING, }Context"
  echo "$NEW_STRING" | grep -q '\*\*Rationale:\*\*' || MISSING="${MISSING:+$MISSING, }Rationale"
  echo "$NEW_STRING" | grep -q '\*\*Impact:\*\*' || MISSING="${MISSING:+$MISSING, }Impact"

  if [[ -n "$MISSING" ]]; then
    afplay "$BLOCK_SOUND" &
    echo "Decision log entry is missing required fields: $MISSING. Decision entries must include Decision, Context, Rationale, and Impact sections." >&2
    exit 2
  fi
fi

# [blocker] — require actionable detail
if echo "$NEW_STRING" | grep -q '\[blocker\]'; then
  LINE_COUNT=$(echo "$NEW_STRING" | wc -l | tr -d ' ')
  if [[ "$LINE_COUNT" -lt 3 ]]; then
    afplay "$BLOCK_SOUND" &
    echo "Blocker entries should include what is blocked and what would unblock it. Add more detail." >&2
    exit 2
  fi
fi

# [change] — require What/Where/How to revert for non-trivial entries
if echo "$NEW_STRING" | grep -q '\[change\]'; then
  LINE_COUNT=$(echo "$NEW_STRING" | wc -l | tr -d ' ')
  # Only enforce template for entries longer than 2 lines (non-trivial)
  if [[ "$LINE_COUNT" -gt 2 ]]; then
    MISSING=""
    echo "$NEW_STRING" | grep -q '\*\*What:\*\*' || MISSING="What"
    echo "$NEW_STRING" | grep -q '\*\*Where:\*\*' || MISSING="${MISSING:+$MISSING, }Where"
    echo "$NEW_STRING" | grep -q '\*\*How to revert:\*\*' || MISSING="${MISSING:+$MISSING, }How to revert"

    if [[ -n "$MISSING" ]]; then
      afplay "$BLOCK_SOUND" &
      echo "Change log entry is missing required fields: $MISSING. Non-trivial change entries should include What, Where, and How to revert sections." >&2
      exit 2
    fi
  fi
fi

# [research] — soft check: warn if no conclusion on substantial entries
if echo "$NEW_STRING" | grep -q '\[research\]'; then
  LINE_COUNT=$(echo "$NEW_STRING" | wc -l | tr -d ' ')
  if [[ "$LINE_COUNT" -gt 5 ]]; then
    if ! echo "$NEW_STRING" | grep -q '\*\*Conclusion:\*\*\|\*\*Findings:\*\*'; then
      afplay "$BLOCK_SOUND" &
      echo "Research entries with substantial content should include Findings and/or Conclusion sections to capture what you learned." >&2
      exit 2
    fi
  fi
fi

exit 0
