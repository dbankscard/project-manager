#!/bin/bash
# Hook: PostToolUse (Edit|Write) — auto-sync progress when board.md files change
set -euo pipefail

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Get the file path that was edited/written
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only act on board.md files within projects/
if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

if [[ "$FILE_PATH" != *"/projects/"*"/board.md" ]]; then
  exit 0
fi

# Extract the project slug from the path
SLUG=$(echo "$FILE_PATH" | sed -n 's|.*/projects/\([^/]*\)/board.md|\1|p')

if [[ -z "$SLUG" ]]; then
  exit 0
fi

BOARD_FILE="$PROJECT_DIR/projects/$SLUG/board.md"
README_FILE="$PROJECT_DIR/projects/$SLUG/README.md"
REGISTRY="$PROJECT_DIR/projects/_registry.md"

if [[ ! -f "$BOARD_FILE" ]]; then
  exit 0
fi

# Get previous done count from README (before this edit)
PREV_PROGRESS=$(grep -oE '[0-9]+%' "$README_FILE" 2>/dev/null | head -1 | tr -d '%') || PREV_PROGRESS=0

# Count tasks
TOTAL=$(grep -c '^\- \[[ x]\]' "$BOARD_FILE" 2>/dev/null || echo 0)
DONE=$(grep -c '^\- \[x\]' "$BOARD_FILE" 2>/dev/null || echo 0)

if [[ "$TOTAL" -eq 0 ]]; then
  PROGRESS="0"
else
  PROGRESS=$(( (DONE * 100) / TOTAL ))
fi

# Update README progress if it exists
if [[ -f "$README_FILE" ]]; then
  sed -i '' "s/| \*\*Progress\*\* | [0-9]*% |/| **Progress** | ${PROGRESS}% |/" "$README_FILE" 2>/dev/null || true
fi

# Update registry progress for this project
if [[ -f "$REGISTRY" ]]; then
  # Match the row containing the slug and update the progress column
  # Registry format: | [Name](projects/slug/README.md) | status | priority | XX% | milestone |
  sed -i '' "s|\(| \[.*\](projects/${SLUG}/README.md) |[^|]*|[^|]*| \)[0-9]*%\( |.*\)|\1${PROGRESS}%\2|" "$REGISTRY" 2>/dev/null || true
fi

# Play task completion sound if progress increased
if [[ "$PROGRESS" -gt "$PREV_PROGRESS" && "$DONE" -gt 0 ]]; then
  afplay "$PROJECT_DIR/sounds/ready-set-go-sound.mp3" &
fi

exit 0
