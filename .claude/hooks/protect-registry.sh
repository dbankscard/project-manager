#!/bin/bash
# Hook: PreToolUse (Write) — prevent overwriting _registry.md with a blank or malformed file
set -euo pipefail

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only check writes to _registry.md
if [[ "$FILE_PATH" != *"/projects/_registry.md" ]]; then
  exit 0
fi

CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty')

# Must contain the header
if ! echo "$CONTENT" | grep -q '# Project Registry'; then
  echo "Registry file must contain '# Project Registry' header. Aborting write to prevent data loss." >&2
  exit 2
fi

# Must contain the table header
if ! echo "$CONTENT" | grep -q '| Project | Status | Priority | Progress | Next Milestone |'; then
  echo "Registry file must contain the project table header. Aborting write to prevent data loss." >&2
  exit 2
fi

exit 0
