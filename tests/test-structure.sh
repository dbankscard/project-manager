#!/bin/bash
# Test: File structure integrity
# Validates that all required project files exist and are well-formed
# These tests run against the REAL project directory (no temp dir needed)

TEMPLATES=("default" "migration" "vendor-eval" "security-audit" "incident")
TEMPLATE_FILES=("project-readme.md" "board.md" "log.md")

HOOKS=(
  "session-start.sh"
  "advisor-nudge.sh"
  "recent-activity.sh"
  "eod-reminder.sh"
  "weekly-reminder.sh"
  "archive-suggestion.sh"
  "sync-progress.sh"
  "validate-log-entry.sh"
  "protect-registry.sh"
)

AGENTS=("advisor" "tasker" "documenter" "chief-of-staff" "project-manager")

COMMANDS=(
  "plan" "retro" "search" "log" "capture" "gm" "triage" "dash" "standup"
  "enrich" "setup" "run" "archive" "weekly" "eod" "handoff" "task" "board"
  "new-project"
)

# ── Test: Template directories and files exist ──────────────

test_templates_exist() {
  for tmpl in "${TEMPLATES[@]}"; do
    for file in "${TEMPLATE_FILES[@]}"; do
      local path="$REAL_PROJECT_DIR/templates/$tmpl/$file"
      if [[ ! -f "$path" ]]; then
        printf "  ${RED}FAIL${NC}: Template file missing: templates/%s/%s\n" "$tmpl" "$file"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
      fi
    done
  done
}

# ── Test: Hooks are executable with correct shebang ─────────

test_hooks_executable() {
  for hook in "${HOOKS[@]}"; do
    local path="$REAL_PROJECT_DIR/.claude/hooks/$hook"
    if [[ ! -f "$path" ]]; then
      printf "  ${RED}FAIL${NC}: Hook missing: .claude/hooks/%s\n" "$hook"
      TESTS_FAILED=$((TESTS_FAILED + 1))
      return 1
    fi
    if [[ ! -x "$path" ]]; then
      printf "  ${RED}FAIL${NC}: Hook not executable: %s\n" "$hook"
      TESTS_FAILED=$((TESTS_FAILED + 1))
      return 1
    fi
    local shebang
    shebang=$(head -1 "$path")
    if [[ "$shebang" != "#!/bin/bash" ]]; then
      printf "  ${RED}FAIL${NC}: Hook missing #!/bin/bash shebang: %s\n" "$hook"
      TESTS_FAILED=$((TESTS_FAILED + 1))
      return 1
    fi
    if ! head -5 "$path" | grep -q 'set -euo pipefail'; then
      printf "  ${RED}FAIL${NC}: Hook missing 'set -euo pipefail': %s\n" "$hook"
      TESTS_FAILED=$((TESTS_FAILED + 1))
      return 1
    fi
  done
}

# ── Test: Agent definitions exist ───────────────────────────

test_agents_exist() {
  for agent in "${AGENTS[@]}"; do
    local path="$REAL_PROJECT_DIR/.claude/agents/$agent.md"
    if [[ ! -f "$path" ]]; then
      printf "  ${RED}FAIL${NC}: Agent definition missing: .claude/agents/%s.md\n" "$agent"
      TESTS_FAILED=$((TESTS_FAILED + 1))
      return 1
    fi
  done
}

# ── Test: Command definitions exist ─────────────────────────

test_commands_exist() {
  for cmd in "${COMMANDS[@]}"; do
    local path="$REAL_PROJECT_DIR/.claude/commands/$cmd.md"
    if [[ ! -f "$path" ]]; then
      printf "  ${RED}FAIL${NC}: Command definition missing: .claude/commands/%s.md\n" "$cmd"
      TESTS_FAILED=$((TESTS_FAILED + 1))
      return 1
    fi
  done
}

# ── Test: settings.json is valid and has all hooks ──────────

test_settings_valid() {
  local settings="$REAL_PROJECT_DIR/.claude/settings.json"
  if [[ ! -f "$settings" ]]; then
    printf "  ${RED}FAIL${NC}: .claude/settings.json not found\n"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi

  # Valid JSON
  if ! python3 -c "import json; json.load(open('$settings'))" 2>/dev/null; then
    printf "  ${RED}FAIL${NC}: settings.json is not valid JSON\n"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi

  # Check hook event counts
  local session_start_count
  session_start_count=$(python3 -c "
import json
with open('$settings') as f:
    d = json.load(f)
print(len(d.get('hooks', {}).get('SessionStart', [])))
")
  if [[ "$session_start_count" != "6" ]]; then
    printf "  ${RED}FAIL${NC}: Expected 6 SessionStart hooks, got %s\n" "$session_start_count"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi

  local post_tool_count
  post_tool_count=$(python3 -c "
import json
with open('$settings') as f:
    d = json.load(f)
print(len(d.get('hooks', {}).get('PostToolUse', [])))
")
  if [[ "$post_tool_count" != "1" ]]; then
    printf "  ${RED}FAIL${NC}: Expected 1 PostToolUse hook, got %s\n" "$post_tool_count"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi

  local pre_tool_count
  pre_tool_count=$(python3 -c "
import json
with open('$settings') as f:
    d = json.load(f)
print(len(d.get('hooks', {}).get('PreToolUse', [])))
")
  if [[ "$pre_tool_count" != "2" ]]; then
    printf "  ${RED}FAIL${NC}: Expected 2 PreToolUse hooks, got %s\n" "$pre_tool_count"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

# ── Test: Registry has correct structure ────────────────────

test_registry_structure() {
  local registry="$REAL_PROJECT_DIR/projects/_registry.md"
  if [[ ! -f "$registry" ]]; then
    printf "  ${RED}FAIL${NC}: projects/_registry.md not found\n"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
  if ! grep -q '# Project Registry' "$registry"; then
    printf "  ${RED}FAIL${NC}: Registry missing header\n"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
  if ! grep -q '| Project | Status | Priority | Progress | Next Milestone |' "$registry"; then
    printf "  ${RED}FAIL${NC}: Registry missing table header\n"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

# ── Run all structure tests ─────────────────────────────────

run_structure_tests() {
  echo ""
  printf "${CYAN}Structure Tests${NC}\n"
  echo "────────────────────────────────────────"

  # Reset counters for this section
  local start_passed=$TESTS_PASSED
  local start_failed=$TESTS_FAILED

  run_test "Template directories and files exist (5 templates × 3 files)" test_templates_exist false
  run_test "Hooks are executable with correct shebang (9 hooks)" test_hooks_executable false
  run_test "Agent definitions exist (5 agents)" test_agents_exist false
  run_test "Command definitions exist (19 commands)" test_commands_exist false
  run_test "settings.json valid with all hook registrations" test_settings_valid false
  run_test "Registry has correct structure" test_registry_structure false

  STRUCTURE_PASSED=$((TESTS_PASSED - start_passed))
  STRUCTURE_FAILED=$((TESTS_FAILED - start_failed))
}
