#!/bin/bash
# Main test runner — orchestrates all test suites and reports results
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all test infrastructure
source "$SCRIPT_DIR/helpers.sh"
source "$SCRIPT_DIR/test-structure.sh"
source "$SCRIPT_DIR/test-templates.sh"
source "$SCRIPT_DIR/test-hooks.sh"

echo "================================================"
echo "  Project Manager Test Suite"
echo "================================================"

# Warn about platform
if ! is_macos; then
  printf "\n${YELLOW}WARNING${NC}: Not running on macOS. Some date-math tests will be skipped.\n"
fi

# ── Run all suites ──────────────────────────────────────────

run_structure_tests
run_template_tests
run_hook_tests

# ── Final summary ───────────────────────────────────────────

echo ""
echo "================================================"
echo "  RESULTS"
echo "================================================"
echo ""

print_section_summary "Structure Tests" "$STRUCTURE_PASSED" "$STRUCTURE_FAILED"
print_section_summary "Template Tests" "$TEMPLATE_PASSED" "$TEMPLATE_FAILED"
print_section_summary "Hook Tests" "$HOOK_PASSED" "$HOOK_FAILED" "$HOOK_SKIPPED"

echo ""
echo "────────────────────────────────────────"
printf "  Passed:  ${GREEN}%d${NC}\n" "$TESTS_PASSED"
if [[ "$TESTS_FAILED" -gt 0 ]]; then
  printf "  Failed:  ${RED}%d${NC}\n" "$TESTS_FAILED"
else
  printf "  Failed:  %d\n" "$TESTS_FAILED"
fi
if [[ "$TESTS_SKIPPED" -gt 0 ]]; then
  printf "  Skipped: ${YELLOW}%d${NC}\n" "$TESTS_SKIPPED"
fi
echo ""

if [[ "$TESTS_FAILED" -gt 0 ]]; then
  printf "  STATUS: ${RED}FAILURES DETECTED${NC}\n"
  echo "================================================"
  exit 1
else
  printf "  STATUS: ${GREEN}ALL PASSING${NC}\n"
  echo "================================================"
  exit 0
fi
