#!/bin/bash
# Test: Template validation
# Read-only checks against real template files

TEMPLATES=("default" "migration" "vendor-eval" "security-audit" "incident")
POPULATED_TEMPLATES=("migration" "vendor-eval" "security-audit" "incident")
REQUIRED_COLUMNS=("## Backlog" "## Research" "## In Progress" "## Review" "## Done")

# ── Test: Placeholders present in each template set ─────────

test_template_placeholders() {
  local tmpl="$1"
  local dir="$REAL_PROJECT_DIR/templates/$tmpl"

  # Check across all files in the template
  local all_content
  all_content=$(cat "$dir"/*)

  for placeholder in '{{name}}' '{{slug}}' '{{date}}' '{{priority}}'; do
    if ! echo "$all_content" | grep -qF "$placeholder"; then
      printf "  ${RED}FAIL${NC}: Template '%s' missing placeholder %s\n" "$tmpl" "$placeholder"
      TESTS_FAILED=$((TESTS_FAILED + 1))
      return 1
    fi
  done
}

# ── Test: Board has all 5 kanban columns ────────────────────

test_template_board_columns() {
  local tmpl="$1"
  local board="$REAL_PROJECT_DIR/templates/$tmpl/board.md"

  for col in "${REQUIRED_COLUMNS[@]}"; do
    if ! grep -qF "$col" "$board"; then
      printf "  ${RED}FAIL${NC}: Template '%s' board.md missing column: %s\n" "$tmpl" "$col"
      TESTS_FAILED=$((TESTS_FAILED + 1))
      return 1
    fi
  done
}

# ── Test: Log has ## Log header ─────────────────────────────

test_template_log_header() {
  local tmpl="$1"
  local logfile="$REAL_PROJECT_DIR/templates/$tmpl/log.md"

  if ! grep -qF '## Log' "$logfile"; then
    printf "  ${RED}FAIL${NC}: Template '%s' log.md missing '## Log' header\n" "$tmpl"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

# ── Test: README has progress field ─────────────────────────

test_template_readme_progress() {
  local tmpl="$1"
  local readme="$REAL_PROJECT_DIR/templates/$tmpl/project-readme.md"

  if ! grep -qF '| **Progress** |' "$readme"; then
    printf "  ${RED}FAIL${NC}: Template '%s' project-readme.md missing progress field\n" "$tmpl"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

# ── Test: Pre-populated templates have 10+ tasks ────────────

test_template_prepopulated_tasks() {
  local tmpl="$1"
  local board="$REAL_PROJECT_DIR/templates/$tmpl/board.md"

  local task_count
  task_count=$(grep -c '^\- \[ \]' "$board" 2>/dev/null) || task_count=0

  if [[ "$task_count" -lt 10 ]]; then
    printf "  ${RED}FAIL${NC}: Template '%s' board.md has only %d tasks (expected 10+)\n" "$tmpl" "$task_count"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

# ── Run all template tests ──────────────────────────────────

run_template_tests() {
  echo ""
  printf "${CYAN}Template Tests${NC}\n"
  echo "────────────────────────────────────────"

  local start_passed=$TESTS_PASSED
  local start_failed=$TESTS_FAILED

  # Placeholders (5 templates)
  for tmpl in "${TEMPLATES[@]}"; do
    run_test "Placeholders present: $tmpl" "test_template_placeholders $tmpl" false
  done

  # Board columns (5 templates)
  for tmpl in "${TEMPLATES[@]}"; do
    run_test "Board columns correct: $tmpl" "test_template_board_columns $tmpl" false
  done

  # Log header (5 templates)
  for tmpl in "${TEMPLATES[@]}"; do
    run_test "Log header present: $tmpl" "test_template_log_header $tmpl" false
  done

  # README progress (5 templates)
  for tmpl in "${TEMPLATES[@]}"; do
    run_test "README progress field: $tmpl" "test_template_readme_progress $tmpl" false
  done

  # Pre-populated tasks (4 non-default templates)
  for tmpl in "${POPULATED_TEMPLATES[@]}"; do
    run_test "Pre-populated tasks (10+): $tmpl" "test_template_prepopulated_tasks $tmpl" false
  done

  TEMPLATE_PASSED=$((TESTS_PASSED - start_passed))
  TEMPLATE_FAILED=$((TESTS_FAILED - start_failed))
}
