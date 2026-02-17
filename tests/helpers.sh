#!/bin/bash
# Test helpers — shared utilities for all test files
# Provides: temp dir management, assertions, fixture builders, stubs

# ── Counters ────────────────────────────────────────────────
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0
CURRENT_TEST=""

# ── Colors ──────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ── Project root (real repo) ────────────────────────────────
REAL_PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ── Temp directory lifecycle ────────────────────────────────

setup_test_dir() {
  TEST_DIR=$(mktemp -d "${TMPDIR:-/tmp}/pm-test.XXXXXX")
  export CLAUDE_PROJECT_DIR="$TEST_DIR"

  # Create standard directory structure
  mkdir -p "$TEST_DIR/projects"
  mkdir -p "$TEST_DIR/sounds"
  mkdir -p "$TEST_DIR/.claude/hooks"

  # Copy hooks from real project
  cp "$REAL_PROJECT_DIR"/.claude/hooks/*.sh "$TEST_DIR/.claude/hooks/" 2>/dev/null || true

  # Stub afplay — no-op script prepended to PATH
  mkdir -p "$TEST_DIR/bin"
  cat > "$TEST_DIR/bin/afplay" << 'STUB'
#!/bin/bash
exit 0
STUB
  chmod +x "$TEST_DIR/bin/afplay"
  export PATH="$TEST_DIR/bin:$PATH"
}

teardown_test_dir() {
  if [[ -n "${TEST_DIR:-}" && -d "$TEST_DIR" ]]; then
    rm -rf "$TEST_DIR"
  fi
  unset CLAUDE_PROJECT_DIR
}

# ── Date stub ───────────────────────────────────────────────
# Creates a date wrapper that intercepts specific format strings
# for deterministic testing, passes everything else to /bin/date

create_date_stub() {
  local hour="${1:-}"
  local dow="${2:-}"
  local fake_today="${3:-}"

  cat > "$TEST_DIR/bin/date" << DATESTUB
#!/bin/bash
# Stub date command for testing
for arg in "\$@"; do
  case "\$arg" in
    +%H)
      echo "${hour:-\$(/bin/date +%H)}"
      exit 0
      ;;
    +%u)
      echo "${dow:-\$(/bin/date +%u)}"
      exit 0
      ;;
    +%Y-%m-%d)
      # Only intercept bare +%Y-%m-%d (no preceding -d/-v flags)
      if [[ "\${*}" == "+%Y-%m-%d" ]]; then
        echo "${fake_today:-\$(/bin/date +%Y-%m-%d)}"
        exit 0
      fi
      ;;
  esac
done
# Pass through to real date for everything else
/bin/date "\$@"
DATESTUB
  chmod +x "$TEST_DIR/bin/date"
}

# ── Assertions ──────────────────────────────────────────────

assert_exit_code() {
  local expected="$1"
  local actual="$2"
  local msg="${3:-exit code should be $expected}"
  if [[ "$actual" -ne "$expected" ]]; then
    printf "  ${RED}FAIL${NC}: %s (expected %s, got %s)\n" "$msg" "$expected" "$actual"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
  return 0
}

assert_output_contains() {
  local output="$1"
  local expected="$2"
  local msg="${3:-output should contain '$expected'}"
  if echo "$output" | grep -qF "$expected"; then
    return 0
  else
    printf "  ${RED}FAIL${NC}: %s\n" "$msg"
    printf "  Expected to find: %s\n" "$expected"
    printf "  Actual output: %.200s\n" "$output"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

assert_output_not_contains() {
  local output="$1"
  local unexpected="$2"
  local msg="${3:-output should not contain '$unexpected'}"
  if echo "$output" | grep -qF "$unexpected"; then
    printf "  ${RED}FAIL${NC}: %s\n" "$msg"
    printf "  Should not contain: %s\n" "$unexpected"
    printf "  Actual output: %.200s\n" "$output"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
  return 0
}

assert_output_empty() {
  local output="$1"
  local msg="${2:-output should be empty}"
  # Trim whitespace
  local trimmed
  trimmed=$(echo "$output" | tr -d '[:space:]')
  if [[ -n "$trimmed" ]]; then
    printf "  ${RED}FAIL${NC}: %s\n" "$msg"
    printf "  Actual output: %.200s\n" "$output"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
  return 0
}

assert_file_contains() {
  local file="$1"
  local expected="$2"
  local msg="${3:-file should contain '$expected'}"
  if [[ ! -f "$file" ]]; then
    printf "  ${RED}FAIL${NC}: %s (file not found: %s)\n" "$msg" "$file"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
  if grep -qF "$expected" "$file"; then
    return 0
  else
    printf "  ${RED}FAIL${NC}: %s\n" "$msg"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

# ── Test runner ─────────────────────────────────────────────

run_test() {
  local test_name="$1"
  local test_func="$2"
  local needs_temp="${3:-true}"
  CURRENT_TEST="$test_name"

  if [[ "$needs_temp" == "true" ]]; then
    setup_test_dir
  fi

  # Run the test function — capture failures
  # Use eval to support "func_name arg1 arg2" strings
  local failed=false
  if ! eval "$test_func"; then
    failed=true
  fi

  if [[ "$needs_temp" == "true" ]]; then
    teardown_test_dir
  fi

  if [[ "$failed" == "false" ]]; then
    printf "  ${GREEN}PASS${NC}: %s\n" "$test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  fi
}

skip_test() {
  local test_name="$1"
  local reason="$2"
  printf "  ${YELLOW}SKIP${NC}: %s (%s)\n" "$test_name" "$reason"
  TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
}

# ── Fixture builders ────────────────────────────────────────

create_registry() {
  local content="${1:-}"
  if [[ -z "$content" ]]; then
    cat > "$TEST_DIR/projects/_registry.md" << 'EOF'
# Project Registry

| Project | Status | Priority | Progress | Next Milestone |
|---------|--------|----------|----------|----------------|
EOF
  else
    echo "$content" > "$TEST_DIR/projects/_registry.md"
  fi
}

create_project() {
  local slug="$1"
  local board_content="${2:-}"
  local log_content="${3:-}"
  local readme_content="${4:-}"

  mkdir -p "$TEST_DIR/projects/$slug"

  # Board
  if [[ -n "$board_content" ]]; then
    echo "$board_content" > "$TEST_DIR/projects/$slug/board.md"
  else
    cat > "$TEST_DIR/projects/$slug/board.md" << 'EOF'
# Test Project — Board

## Backlog

## Research

## In Progress

## Review

## Done
EOF
  fi

  # Log
  if [[ -n "$log_content" ]]; then
    echo "$log_content" > "$TEST_DIR/projects/$slug/log.md"
  else
    # Include a dated entry so hooks with set -euo pipefail don't crash
    # on empty grep pipelines when scanning for ### YYYY-MM-DD patterns
    local today_date
    today_date=$(/bin/date +%Y-%m-%d)
    cat > "$TEST_DIR/projects/$slug/log.md" << LOGEOF
# Test Project — Log

## Log

### ${today_date} 10:00 — [note] Project initialized

Project created for testing.

---
LOGEOF
  fi

  # README
  if [[ -n "$readme_content" ]]; then
    echo "$readme_content" > "$TEST_DIR/projects/$slug/README.md"
  else
    cat > "$TEST_DIR/projects/$slug/README.md" << 'EOF'
# Test Project

| Field | Value |
|-------|-------|
| **Status** | active |
| **Priority** | P2 |
| **Progress** | 0% |
EOF
  fi
}

create_goals_yaml() {
  local content="${1:-}"
  if [[ -z "$content" ]]; then
    cat > "$TEST_DIR/goals.yaml" << EOF
last_updated: $(date +%Y-%m-%d)
quarter: Q1 2026
objectives:
  - name: Test Objective
    key_results:
      - description: Test KR
        progress: 0.5
        status: on_track
EOF
  else
    echo "$content" > "$TEST_DIR/goals.yaml"
  fi
}

# ── JSON builders for stdin-based hooks ─────────────────────

build_tool_input_json() {
  local file_path="$1"
  shift
  # Remaining args are key=value pairs for tool_input
  local json
  json=$(cat << EOF
{
  "tool_input": {
    "file_path": "$file_path"
  }
}
EOF
)
  echo "$json"
}

build_write_input_json() {
  local file_path="$1"
  local content="$2"
  # Escape content for JSON
  local escaped_content
  escaped_content=$(echo "$content" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
  cat << EOF
{
  "tool_input": {
    "file_path": "$file_path",
    "content": $escaped_content
  }
}
EOF
}

build_edit_input_json() {
  local file_path="$1"
  local new_string="$2"
  local escaped_new_string
  escaped_new_string=$(echo "$new_string" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
  cat << EOF
{
  "tool_input": {
    "file_path": "$file_path",
    "new_string": $escaped_new_string
  }
}
EOF
}

# ── macOS detection ─────────────────────────────────────────
is_macos() {
  [[ "$(uname)" == "Darwin" ]]
}

# ── Summary printer ─────────────────────────────────────────

print_section_summary() {
  local section_name="$1"
  local passed="$2"
  local failed="$3"
  local skipped="${4:-0}"

  if [[ "$failed" -gt 0 ]]; then
    printf "  %-20s ${GREEN}%d passed${NC}, ${RED}%d failed${NC}" "$section_name:" "$passed" "$failed"
  else
    printf "  %-20s ${GREEN}%d passed${NC}, %d failed" "$section_name:" "$passed" "$failed"
  fi
  if [[ "$skipped" -gt 0 ]]; then
    printf ", ${YELLOW}%d skipped${NC}" "$skipped"
  fi
  echo ""
}
