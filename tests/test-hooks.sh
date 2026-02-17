#!/bin/bash
# Test: Hook scripts (62 tests)
# Each hook is tested in an isolated temp directory

# ── macOS guard for date-math hooks ─────────────────────────
MACOS_ONLY_REASON="requires macOS date -j -f"

# ═════════════════════════════════════════════════════════════
# session-start.sh (6 tests)
# ═════════════════════════════════════════════════════════════

test_session_start_no_registry() {
  # No registry file at all
  local output
  output=$(bash "$TEST_DIR/.claude/hooks/session-start.sh" 2>&1)
  assert_output_contains "$output" "No projects tracked yet"
}

test_session_start_empty_registry() {
  create_registry
  local output
  output=$(bash "$TEST_DIR/.claude/hooks/session-start.sh" 2>&1)
  assert_output_contains "$output" "No projects tracked yet"
}

test_session_start_one_active_project() {
  create_registry "# Project Registry

| Project | Status | Priority | Progress | Next Milestone |
|---------|--------|----------|----------|----------------|
| [Test Project](projects/test-proj/README.md) | active | P1 | 25% | Phase 1 |"

  create_project "test-proj" "# Test — Board

## Backlog

## Research

## In Progress

- [ ] Task one \`P1\`
- [ ] Task two \`P2\`

## Review

## Done
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/session-start.sh" 2>&1)
  assert_output_contains "$output" "1 projects" && \
  assert_output_contains "$output" "1 active" && \
  assert_output_contains "$output" "2 tasks in progress"
}

test_session_start_multiple_statuses() {
  create_registry "# Project Registry

| Project | Status | Priority | Progress | Next Milestone |
|---------|--------|----------|----------|----------------|
| [Project A](projects/proj-a/README.md) | active | P1 | 25% | M1 |
| [Project B](projects/proj-b/README.md) | active | P2 | 50% | M2 |
| [Project C](projects/proj-c/README.md) | planning | P2 | 0% | M3 |"

  create_project "proj-a"
  create_project "proj-b"
  create_project "proj-c"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/session-start.sh" 2>&1)
  assert_output_contains "$output" "2 active" && \
  assert_output_contains "$output" "1 planning"
}

test_session_start_recent_blocker() {
  local today
  today=$(date +%Y-%m-%d)

  create_registry "# Project Registry

| Project | Status | Priority | Progress | Next Milestone |
|---------|--------|----------|----------|----------------|
| [Test](projects/test-proj/README.md) | active | P1 | 0% | M1 |"

  create_project "test-proj" "" "# Test — Log

## Log

### $today 10:00 — [blocker] Something is blocked

Blocked because reasons.

---
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/session-start.sh" 2>&1)
  assert_output_contains "$output" "1 recent blockers"
}

test_session_start_commands_shown() {
  create_registry "# Project Registry

| Project | Status | Priority | Progress | Next Milestone |
|---------|--------|----------|----------|----------------|
| [Test](projects/test-proj/README.md) | active | P1 | 0% | M1 |"

  create_project "test-proj"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/session-start.sh" 2>&1)
  assert_output_contains "$output" "/weekly" && \
  assert_output_contains "$output" "/eod" && \
  assert_output_contains "$output" "/archive" && \
  assert_output_contains "$output" "/handoff"
}


# ═════════════════════════════════════════════════════════════
# advisor-nudge.sh (13 tests)
# ═════════════════════════════════════════════════════════════

test_advisor_no_projects() {
  local output
  output=$(bash "$TEST_DIR/.claude/hooks/advisor-nudge.sh" 2>&1)
  assert_output_empty "$output"
}

test_advisor_healthy_state() {
  create_project "healthy-proj" "# Board

## Backlog

- [ ] Task A \`P2\`

## Research

## In Progress

- [ ] Task B \`P2\`

## Review

## Done
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/advisor-nudge.sh" 2>&1)
  assert_output_empty "$output"
}

test_advisor_wip_overload() {
  create_project "busy-proj" "# Board

## Backlog

## Research

## In Progress

- [ ] Task 1 \`P2\`
- [ ] Task 2 \`P2\`
- [ ] Task 3 \`P2\`
- [ ] Task 4 \`P2\`

## Review

## Done
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/advisor-nudge.sh" 2>&1)
  assert_output_contains "$output" "WIP limit of 3"
}

test_advisor_wip_at_threshold() {
  create_project "ok-proj" "# Board

## Backlog

## Research

## In Progress

- [ ] Task 1 \`P2\`
- [ ] Task 2 \`P2\`
- [ ] Task 3 \`P2\`

## Review

## Done
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/advisor-nudge.sh" 2>&1)
  assert_output_not_contains "$output" "WIP limit"
}

test_advisor_overdue_task() {
  create_project "overdue-proj" "# Board

## Backlog

- [ ] Overdue task \`P1\` \`due:2020-01-01\`

## Research

## In Progress

## Review

## Done
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/advisor-nudge.sh" 2>&1)
  assert_output_contains "$output" "Overdue tasks"
}

test_advisor_future_due_date() {
  create_project "future-proj" "# Board

## Backlog

- [ ] Future task \`P2\` \`due:2099-12-31\`

## Research

## In Progress

## Review

## Done
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/advisor-nudge.sh" 2>&1)
  assert_output_not_contains "$output" "Overdue"
}

test_advisor_stale_blocker() {
  if ! is_macos; then
    skip_test "Stale blocker detection" "$MACOS_ONLY_REASON"
    return 0
  fi

  local five_days_ago
  five_days_ago=$(date -v-5d +%Y-%m-%d)

  create_project "blocked-proj" "" "# Log

## Log

### $five_days_ago 10:00 — [blocker] Vendor not responding

Still waiting on vendor.

---
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/advisor-nudge.sh" 2>&1)
  assert_output_contains "$output" "Unresolved blockers aging out"
}

test_advisor_fresh_blocker() {
  if ! is_macos; then
    skip_test "Fresh blocker (no nudge)" "$MACOS_ONLY_REASON"
    return 0
  fi

  local yesterday
  yesterday=$(date -v-1d +%Y-%m-%d)

  create_project "fresh-block" "" "# Log

## Log

### $yesterday 10:00 — [blocker] Minor issue

Something minor.

---
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/advisor-nudge.sh" 2>&1)
  assert_output_not_contains "$output" "Unresolved blockers"
}

test_advisor_dormant_project() {
  if ! is_macos; then
    skip_test "Dormant project detection" "$MACOS_ONLY_REASON"
    return 0
  fi

  local seven_days_ago
  seven_days_ago=$(date -v-7d +%Y-%m-%d)

  create_project "stale-proj" "" "# Log

## Log

### $seven_days_ago 10:00 — [note] Last entry

Nothing since then.

---
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/advisor-nudge.sh" 2>&1)
  assert_output_contains "$output" "no activity for"
}

test_advisor_active_project() {
  if ! is_macos; then
    skip_test "Active project (no nudge)" "$MACOS_ONLY_REASON"
    return 0
  fi

  local today
  today=$(date +%Y-%m-%d)

  create_project "active-proj" "" "# Log

## Log

### $today 10:00 — [note] Just did something

Active today.

---
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/advisor-nudge.sh" 2>&1)
  assert_output_not_contains "$output" "no activity for"
}

test_advisor_goals_stale() {
  if ! is_macos; then
    skip_test "Goals staleness check" "$MACOS_ONLY_REASON"
    return 0
  fi

  local old_date
  old_date=$(date -v-20d +%Y-%m-%d)

  create_project "any-proj"
  create_goals_yaml "last_updated: $old_date
quarter: Q1 2026
objectives:
  - name: Test
    key_results:
      - description: KR1
        progress: 0.5
        status: on_track"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/advisor-nudge.sh" 2>&1)
  assert_output_contains "$output" "goals.yaml hasn't been updated"
}

test_advisor_unblocked_dependency() {
  create_project "dep-proj" "# Board

## Backlog

- [ ] Blocked task \`P1\` \`blocked-by:Setup complete\`

## Research

## In Progress

## Review

## Done

- [x] Setup complete \`P1\` \`done:2026-01-01\`
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/advisor-nudge.sh" 2>&1)
  assert_output_contains "$output" "Task unblocked"
}

test_advisor_priority_inversion() {
  create_project "inversion-proj" "# Board

## Backlog

- [ ] Critical task \`P1\` \`#urgent\`

## Research

## In Progress

- [ ] Low priority task \`P3\` \`#optional\`

## Review

## Done
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/advisor-nudge.sh" 2>&1)
  assert_output_contains "$output" "reprioritizing"
}


# ═════════════════════════════════════════════════════════════
# recent-activity.sh (7 tests)
# ═════════════════════════════════════════════════════════════

test_recent_no_projects() {
  local output
  output=$(bash "$TEST_DIR/.claude/hooks/recent-activity.sh" 2>&1)
  assert_output_empty "$output"
}

test_recent_todays_log_entry() {
  local today
  today=$(date +%Y-%m-%d)

  create_project "log-proj" "" "# Log

## Log

### $today 09:00 — [note] Morning standup

Discussed priorities for the day.

---
" "# Log Project

> A test project

## Status

| Field | Value |
|-------|-------|
| **Status** | active |
| **Progress** | 0% |"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/recent-activity.sh" 2>&1)
  assert_output_contains "$output" "Recent Log Entries"
}

test_recent_completed_task_today() {
  local today
  today=$(date +%Y-%m-%d)

  create_project "done-proj" "# Board

## Backlog

## Research

## In Progress

## Review

## Done

- [x] Finished task \`P2\` \`done:$today\`
" "" "# Done Project

## Status

| Field | Value |
|-------|-------|
| **Status** | active |
| **Progress** | 100% |"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/recent-activity.sh" 2>&1)
  assert_output_contains "$output" "Recently Completed"
}

test_recent_in_progress_tasks() {
  local today
  today=$(date +%Y-%m-%d)

  create_project "wip-proj" "# Board

## Backlog

## Research

## In Progress

- [ ] Working on this \`P1\`

## Review

## Done

- [x] Something \`done:$today\`
" "" "# WIP Project

## Status

| Field | Value |
|-------|-------|
| **Status** | active |
| **Progress** | 50% |"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/recent-activity.sh" 2>&1)
  assert_output_contains "$output" "In Progress"
}

test_recent_review_tasks() {
  local today
  today=$(date +%Y-%m-%d)

  create_project "review-proj" "# Board

## Backlog

## Research

## In Progress

## Review

- [ ] Reviewing this \`P2\`

## Done

- [x] Earlier task \`done:$today\`
" "" "# Review Project

## Status

| Field | Value |
|-------|-------|
| **Status** | active |
| **Progress** | 50% |"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/recent-activity.sh" 2>&1)
  assert_output_contains "$output" "In Review"
}

test_recent_no_recent_activity() {
  create_project "old-proj" "" "# Log

## Log

### 2020-01-01 10:00 — [note] Ancient entry

Very old.

---
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/recent-activity.sh" 2>&1)
  assert_output_empty "$output" "no output when all activity is old"
}

test_recent_todays_blocker() {
  local today
  today=$(date +%Y-%m-%d)

  create_project "blocker-proj" "" "# Log

## Log

### $today 14:00 — [blocker] API is down

The API vendor is experiencing outages.

---
" "# Blocker Project

## Status

| Field | Value |
|-------|-------|
| **Status** | active |
| **Progress** | 25% |"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/recent-activity.sh" 2>&1)
  assert_output_contains "$output" "Blockers"
}


# ═════════════════════════════════════════════════════════════
# eod-reminder.sh (6 tests)
# ═════════════════════════════════════════════════════════════

test_eod_before_4pm() {
  create_date_stub "10" "" "$(date +%Y-%m-%d)"
  create_project "any-proj"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/eod-reminder.sh" 2>&1)
  assert_output_empty "$output" "should be silent before 4 PM"
}

test_eod_after_4pm_unlogged_tasks() {
  local today
  today=$(/bin/date +%Y-%m-%d)
  create_date_stub "17" "" "$today"

  create_project "eod-proj" "# Board

## Backlog

## Research

## In Progress

## Review

## Done

- [x] Task A \`done:$today\`
- [x] Task B \`done:$today\`
- [x] Task C \`done:$today\`
" "# Log

## Log

### $today 10:00 — [change] Deployed update

Pushed code.

---
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/eod-reminder.sh" 2>&1)
  assert_output_contains "$output" "3 task(s) today" && \
  assert_output_contains "$output" "2 potentially unlogged"
}

test_eod_after_4pm_all_logged() {
  local today
  today=$(/bin/date +%Y-%m-%d)
  create_date_stub "17" "" "$today"

  create_project "logged-proj" "# Board

## Backlog

## Research

## In Progress

## Review

## Done

- [x] Task A \`done:$today\`
- [x] Task B \`done:$today\`
" "# Log

## Log

### $today 10:00 — [change] Did task A

Changed things.

---

### $today 11:00 — [change] Did task B

Changed more things.

---
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/eod-reminder.sh" 2>&1)
  assert_output_contains "$output" "completed 2 task(s)" && \
  assert_output_not_contains "$output" "unlogged"
}

test_eod_after_4pm_logs_only() {
  local today
  today=$(/bin/date +%Y-%m-%d)
  create_date_stub "17" "" "$today"

  create_project "log-only" "" "# Log

## Log

### $today 10:00 — [note] Morning notes

Jotted stuff down.

---

### $today 11:00 — [research] Looked into options

Researched things.

---

### $today 14:00 — [note] Afternoon review

Reviewed progress.

---
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/eod-reminder.sh" 2>&1)
  assert_output_contains "$output" "3 log entries today"
}

test_eod_after_4pm_no_activity() {
  local today
  today=$(/bin/date +%Y-%m-%d)
  create_date_stub "17" "" "$today"

  create_project "quiet-proj" "" "# Log

## Log

### 2020-01-01 10:00 — [note] Old entry

Nothing today.

---
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/eod-reminder.sh" 2>&1)
  assert_output_empty "$output" "should be silent when no today's activity"
}

test_eod_after_4pm_no_projects() {
  local today
  today=$(/bin/date +%Y-%m-%d)
  create_date_stub "17" "" "$today"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/eod-reminder.sh" 2>&1)
  assert_output_empty "$output" "should be silent with no projects"
}


# ═════════════════════════════════════════════════════════════
# weekly-reminder.sh (6 tests)
# ═════════════════════════════════════════════════════════════

test_weekly_tuesday() {
  create_date_stub "" "2"  # Tuesday = 2
  create_project "any-proj"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/weekly-reminder.sh" 2>&1)
  assert_output_empty "$output" "should be silent on Tuesday"
}

test_weekly_friday_with_activity() {
  if ! is_macos; then
    skip_test "Weekly Friday with activity" "$MACOS_ONLY_REASON"
    return 0
  fi

  local today
  today=$(/bin/date +%Y-%m-%d)
  create_date_stub "" "5" "$today"  # Friday = 5

  create_project "weekly-proj" "# Board

## Backlog

## Research

## In Progress

## Review

## Done

- [x] Completed this week \`done:$today\`
" "# Log

## Log

### $today 10:00 — [note] Did something

Details.

---
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/weekly-reminder.sh" 2>&1)
  assert_output_contains "$output" "It's Friday"
}

test_weekly_monday_with_activity() {
  if ! is_macos; then
    skip_test "Weekly Monday with activity" "$MACOS_ONLY_REASON"
    return 0
  fi

  local today
  today=$(/bin/date +%Y-%m-%d)
  create_date_stub "" "1" "$today"  # Monday = 1

  create_project "weekly-proj" "# Board

## Backlog

## Research

## In Progress

## Review

## Done

- [x] Completed last week \`done:$today\`
" "# Log

## Log

### $today 10:00 — [note] Entry from this week

Details.

---
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/weekly-reminder.sh" 2>&1)
  assert_output_contains "$output" "It's Monday" && \
  assert_output_contains "$output" "Last week"
}

test_weekly_friday_no_activity() {
  create_date_stub "" "5"  # Friday

  create_project "quiet-proj" "" "# Log

## Log

### 2020-01-01 10:00 — [note] Ancient entry

Very old.

---
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/weekly-reminder.sh" 2>&1)
  assert_output_empty "$output" "should be silent with no recent activity"
}

test_weekly_saturday() {
  create_date_stub "" "6"  # Saturday
  create_project "any-proj"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/weekly-reminder.sh" 2>&1)
  assert_output_empty "$output" "should be silent on Saturday"
}

test_weekly_no_projects() {
  create_date_stub "" "5"  # Friday

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/weekly-reminder.sh" 2>&1)
  assert_output_empty "$output" "should be silent with no projects"
}


# ═════════════════════════════════════════════════════════════
# archive-suggestion.sh (5 tests)
# ═════════════════════════════════════════════════════════════

test_archive_no_registry() {
  local output
  output=$(bash "$TEST_DIR/.claude/hooks/archive-suggestion.sh" 2>&1)
  assert_output_empty "$output"
}

test_archive_done_project() {
  create_registry "# Project Registry

| Project | Status | Priority | Progress | Next Milestone |
|---------|--------|----------|----------|----------------|
| [Finished](projects/finished-proj/README.md) | done | P2 | 100% | — |"

  create_project "finished-proj"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/archive-suggestion.sh" 2>&1)
  assert_output_contains "$output" "Completed projects" && \
  assert_output_contains "$output" "finished-proj"
}

test_archive_dormant_project() {
  if ! is_macos; then
    skip_test "Dormant project archive suggestion" "$MACOS_ONLY_REASON"
    return 0
  fi

  local old_date
  old_date=$(date -v-35d +%Y-%m-%d)

  create_registry "# Project Registry

| Project | Status | Priority | Progress | Next Milestone |
|---------|--------|----------|----------|----------------|
| [Stale](projects/stale-proj/README.md) | active | P3 | 10% | — |"

  create_project "stale-proj" "" "# Log

## Log

### $old_date 10:00 — [note] Last activity

Nothing since.

---
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/archive-suggestion.sh" 2>&1)
  assert_output_contains "$output" "Deeply dormant" && \
  assert_output_contains "$output" "35 days inactive"
}

test_archive_active_recent_project() {
  if ! is_macos; then
    skip_test "Active recent project (no suggestion)" "$MACOS_ONLY_REASON"
    return 0
  fi

  local today
  today=$(date +%Y-%m-%d)

  create_registry "# Project Registry

| Project | Status | Priority | Progress | Next Milestone |
|---------|--------|----------|----------|----------------|
| [Active](projects/active-proj/README.md) | active | P1 | 50% | Phase 2 |"

  create_project "active-proj" "" "# Log

## Log

### $today 10:00 — [note] Working today

Active project.

---
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/archive-suggestion.sh" 2>&1)
  assert_output_empty "$output" "no suggestion for active project"
}

test_archive_both_done_and_dormant() {
  if ! is_macos; then
    skip_test "Both done + dormant suggestions" "$MACOS_ONLY_REASON"
    return 0
  fi

  local old_date
  old_date=$(date -v-35d +%Y-%m-%d)

  create_registry "# Project Registry

| Project | Status | Priority | Progress | Next Milestone |
|---------|--------|----------|----------|----------------|
| [Finished](projects/done-proj/README.md) | done | P2 | 100% | — |
| [Stale](projects/dormant-proj/README.md) | active | P3 | 10% | — |"

  create_project "done-proj"
  create_project "dormant-proj" "" "# Log

## Log

### $old_date 10:00 — [note] Last entry

Nothing since.

---
"

  local output
  output=$(bash "$TEST_DIR/.claude/hooks/archive-suggestion.sh" 2>&1)
  assert_output_contains "$output" "Completed projects" && \
  assert_output_contains "$output" "Deeply dormant"
}


# ═════════════════════════════════════════════════════════════
# sync-progress.sh (7 tests)
# ═════════════════════════════════════════════════════════════

test_sync_non_board_file() {
  local json
  json=$(build_tool_input_json "$TEST_DIR/projects/test-proj/README.md")

  local output
  output=$(echo "$json" | bash "$TEST_DIR/.claude/hooks/sync-progress.sh" 2>&1)
  local rc=$?
  assert_exit_code 0 "$rc" "non-board file should exit 0"
}

test_sync_board_50_percent() {
  create_project "sync-proj" "# Board

## Backlog

- [ ] Task 1
- [ ] Task 2

## Research

## In Progress

## Review

## Done

- [x] Task 3
- [x] Task 4
"

  create_registry "# Project Registry

| Project | Status | Priority | Progress | Next Milestone |
|---------|--------|----------|----------|----------------|
| [Sync](projects/sync-proj/README.md) | active | P1 | 0% | M1 |"

  local json
  json=$(build_tool_input_json "$TEST_DIR/projects/sync-proj/board.md")

  echo "$json" | bash "$TEST_DIR/.claude/hooks/sync-progress.sh" 2>&1

  assert_file_contains "$TEST_DIR/projects/sync-proj/README.md" "50%" && \
  assert_file_contains "$TEST_DIR/projects/_registry.md" "50%"
}

test_sync_board_100_percent() {
  create_project "done-proj" "# Board

## Backlog

## Research

## In Progress

## Review

## Done

- [x] Task 1
- [x] Task 2
- [x] Task 3
"

  create_registry "# Project Registry

| Project | Status | Priority | Progress | Next Milestone |
|---------|--------|----------|----------|----------------|
| [Done](projects/done-proj/README.md) | active | P1 | 0% | M1 |"

  local json
  json=$(build_tool_input_json "$TEST_DIR/projects/done-proj/board.md")

  echo "$json" | bash "$TEST_DIR/.claude/hooks/sync-progress.sh" 2>&1

  assert_file_contains "$TEST_DIR/projects/done-proj/README.md" "100%"
}

test_sync_empty_board() {
  create_project "empty-proj" "# Board

## Backlog

## Research

## In Progress

## Review

## Done
"

  local json
  json=$(build_tool_input_json "$TEST_DIR/projects/empty-proj/board.md")

  echo "$json" | bash "$TEST_DIR/.claude/hooks/sync-progress.sh" 2>&1

  assert_file_contains "$TEST_DIR/projects/empty-proj/README.md" "0%"
}

test_sync_no_readme() {
  mkdir -p "$TEST_DIR/projects/no-readme"
  cat > "$TEST_DIR/projects/no-readme/board.md" << 'EOF'
# Board

## Backlog

## Research

## In Progress

## Review

## Done

- [x] Task 1
- [x] Task 2
EOF

  create_registry "# Project Registry

| Project | Status | Priority | Progress | Next Milestone |
|---------|--------|----------|----------|----------------|
| [NoReadme](projects/no-readme/README.md) | active | P1 | 0% | M1 |"

  local json
  json=$(build_tool_input_json "$TEST_DIR/projects/no-readme/board.md")

  local output
  output=$(echo "$json" | bash "$TEST_DIR/.claude/hooks/sync-progress.sh" 2>&1)
  local rc=$?
  assert_exit_code 0 "$rc" "should not crash without README" && \
  assert_file_contains "$TEST_DIR/projects/_registry.md" "100%"
}

test_sync_no_registry() {
  create_project "no-reg" "# Board

## Backlog

## Research

## In Progress

## Review

## Done

- [x] Task 1
- [ ] Task 2
"
  # Don't create registry

  local json
  json=$(build_tool_input_json "$TEST_DIR/projects/no-reg/board.md")

  local output
  output=$(echo "$json" | bash "$TEST_DIR/.claude/hooks/sync-progress.sh" 2>&1)
  local rc=$?
  assert_exit_code 0 "$rc" "should not crash without registry" && \
  assert_file_contains "$TEST_DIR/projects/no-reg/README.md" "50%"
}

test_sync_missing_file_path() {
  local json='{"tool_input": {}}'

  local output
  output=$(echo "$json" | bash "$TEST_DIR/.claude/hooks/sync-progress.sh" 2>&1)
  local rc=$?
  assert_exit_code 0 "$rc" "should silently skip with missing file_path"
}


# ═════════════════════════════════════════════════════════════
# validate-log-entry.sh (14 tests)
# ═════════════════════════════════════════════════════════════

test_validate_non_log_file() {
  local json
  json=$(build_edit_input_json "$TEST_DIR/projects/test-proj/README.md" "Some content")

  local output
  output=$(echo "$json" | bash "$TEST_DIR/.claude/hooks/validate-log-entry.sh" 2>&1)
  local rc=$?
  assert_exit_code 0 "$rc" "non-log file should pass"
}

test_validate_decision_complete() {
  local new_string='### 2026-02-15 10:00 — [decision] Use Jamf Pro

**Decision:** Migrate to Jamf Pro
**Context:** Current MDM is outdated
**Rationale:** Better integration
**Impact:** All managed devices affected'

  local json
  json=$(build_edit_input_json "$TEST_DIR/projects/test-proj/log.md" "$new_string")

  local output
  output=$(echo "$json" | bash "$TEST_DIR/.claude/hooks/validate-log-entry.sh" 2>&1)
  local rc=$?
  assert_exit_code 0 "$rc" "complete decision should pass"
}

test_validate_decision_missing_decision() {
  local new_string='### 2026-02-15 10:00 — [decision] Use Jamf Pro

**Context:** Current MDM is outdated
**Rationale:** Better integration
**Impact:** All managed devices affected'

  local json
  json=$(build_edit_input_json "$TEST_DIR/projects/test-proj/log.md" "$new_string")

  local output
  output=$(echo "$json" | bash "$TEST_DIR/.claude/hooks/validate-log-entry.sh" 2>&1)
  local rc=$?
  assert_exit_code 2 "$rc" "missing Decision field should block"
}

test_validate_decision_missing_context() {
  local new_string='### 2026-02-15 10:00 — [decision] Use Jamf Pro

**Decision:** Migrate to Jamf Pro
**Rationale:** Better integration
**Impact:** All managed devices affected'

  local json
  json=$(build_edit_input_json "$TEST_DIR/projects/test-proj/log.md" "$new_string")

  local output
  output=$(echo "$json" | bash "$TEST_DIR/.claude/hooks/validate-log-entry.sh" 2>&1)
  local rc=$?
  assert_exit_code 2 "$rc" "missing Context field should block"
}

test_validate_decision_missing_rationale() {
  local new_string='### 2026-02-15 10:00 — [decision] Use Jamf Pro

**Decision:** Migrate to Jamf Pro
**Context:** Current MDM is outdated
**Impact:** All managed devices affected'

  local json
  json=$(build_edit_input_json "$TEST_DIR/projects/test-proj/log.md" "$new_string")

  local output
  output=$(echo "$json" | bash "$TEST_DIR/.claude/hooks/validate-log-entry.sh" 2>&1)
  local rc=$?
  assert_exit_code 2 "$rc" "missing Rationale field should block"
}

test_validate_decision_missing_impact() {
  local new_string='### 2026-02-15 10:00 — [decision] Use Jamf Pro

**Decision:** Migrate to Jamf Pro
**Context:** Current MDM is outdated
**Rationale:** Better integration'

  local json
  json=$(build_edit_input_json "$TEST_DIR/projects/test-proj/log.md" "$new_string")

  local output
  output=$(echo "$json" | bash "$TEST_DIR/.claude/hooks/validate-log-entry.sh" 2>&1)
  local rc=$?
  assert_exit_code 2 "$rc" "missing Impact field should block"
}

test_validate_decision_missing_multiple() {
  local new_string='### 2026-02-15 10:00 — [decision] Use Jamf Pro

**Decision:** Migrate to Jamf Pro'

  local json
  json=$(build_edit_input_json "$TEST_DIR/projects/test-proj/log.md" "$new_string")

  local output
  output=$(echo "$json" | bash "$TEST_DIR/.claude/hooks/validate-log-entry.sh" 2>&1)
  local rc=$?
  assert_exit_code 2 "$rc" "missing multiple fields should block" && \
  assert_output_contains "$output" "Context" && \
  assert_output_contains "$output" "Rationale"
}

test_validate_blocker_complete() {
  local new_string='### 2026-02-15 10:00 — [blocker] API vendor outage

The vendor API is down.
This blocks all integration testing.
Workaround: use mock server.
ETA unknown.'

  local json
  json=$(build_edit_input_json "$TEST_DIR/projects/test-proj/log.md" "$new_string")

  local output
  output=$(echo "$json" | bash "$TEST_DIR/.claude/hooks/validate-log-entry.sh" 2>&1)
  local rc=$?
  assert_exit_code 0 "$rc" "complete blocker should pass"
}

test_validate_blocker_too_short() {
  local new_string='### 2026-02-15 10:00 — [blocker] Blocked
Stuck.'

  local json
  json=$(build_edit_input_json "$TEST_DIR/projects/test-proj/log.md" "$new_string")

  local output
  output=$(echo "$json" | bash "$TEST_DIR/.claude/hooks/validate-log-entry.sh" 2>&1)
  local rc=$?
  assert_exit_code 2 "$rc" "short blocker should be rejected"
}

test_validate_change_short_exempt() {
  local new_string='### 2026-02-15 10:00 — [change] Quick fix
Bumped version.'

  local json
  json=$(build_edit_input_json "$TEST_DIR/projects/test-proj/log.md" "$new_string")

  local output
  output=$(echo "$json" | bash "$TEST_DIR/.claude/hooks/validate-log-entry.sh" 2>&1)
  local rc=$?
  assert_exit_code 0 "$rc" "short change entry should be exempt"
}

test_validate_change_complete() {
  local new_string='### 2026-02-15 10:00 — [change] Updated auth config

**What:** Changed OAuth provider settings
**Where:** auth-service/config.yaml
**How to revert:** Restore from git (commit abc123)
Additional notes here.'

  local json
  json=$(build_edit_input_json "$TEST_DIR/projects/test-proj/log.md" "$new_string")

  local output
  output=$(echo "$json" | bash "$TEST_DIR/.claude/hooks/validate-log-entry.sh" 2>&1)
  local rc=$?
  assert_exit_code 0 "$rc" "complete change should pass"
}

test_validate_change_missing_what() {
  local new_string='### 2026-02-15 10:00 — [change] Updated auth config

Did some changes.
**Where:** auth-service/config.yaml
**How to revert:** Restore from git
More context.'

  local json
  json=$(build_edit_input_json "$TEST_DIR/projects/test-proj/log.md" "$new_string")

  local output
  output=$(echo "$json" | bash "$TEST_DIR/.claude/hooks/validate-log-entry.sh" 2>&1)
  local rc=$?
  assert_exit_code 2 "$rc" "change missing What should block"
}

test_validate_research_complete() {
  local new_string='### 2026-02-15 10:00 — [research] Evaluated MDM options

Compared three vendors.
Feature comparison shows Jamf leads.
Pricing is competitive.
Integration is straightforward.
Security review passed.
**Findings:** Jamf Pro is the best fit.
Recommend proceeding with evaluation.'

  local json
  json=$(build_edit_input_json "$TEST_DIR/projects/test-proj/log.md" "$new_string")

  local output
  output=$(echo "$json" | bash "$TEST_DIR/.claude/hooks/validate-log-entry.sh" 2>&1)
  local rc=$?
  assert_exit_code 0 "$rc" "complete research should pass"
}

test_validate_research_no_findings() {
  local new_string='### 2026-02-15 10:00 — [research] Evaluated MDM options

Compared three vendors.
Feature comparison shows Jamf leads.
Pricing is competitive.
Integration is straightforward.
Security review passed.
Documentation is good.
Recommend proceeding with evaluation.'

  local json
  json=$(build_edit_input_json "$TEST_DIR/projects/test-proj/log.md" "$new_string")

  local output
  output=$(echo "$json" | bash "$TEST_DIR/.claude/hooks/validate-log-entry.sh" 2>&1)
  local rc=$?
  assert_exit_code 2 "$rc" "research without Findings/Conclusion should block"
}


# ═════════════════════════════════════════════════════════════
# protect-registry.sh (5 tests)
# ═════════════════════════════════════════════════════════════

test_protect_non_registry_file() {
  local json
  json=$(build_write_input_json "$TEST_DIR/projects/test-proj/README.md" "# Some content")

  local output
  output=$(echo "$json" | bash "$TEST_DIR/.claude/hooks/protect-registry.sh" 2>&1)
  local rc=$?
  assert_exit_code 0 "$rc" "non-registry file should pass"
}

test_protect_valid_write() {
  local content='# Project Registry

| Project | Status | Priority | Progress | Next Milestone |
|---------|--------|----------|----------|----------------|
| [Test](projects/test/README.md) | active | P1 | 50% | M1 |'

  local json
  json=$(build_write_input_json "$TEST_DIR/projects/_registry.md" "$content")

  local output
  output=$(echo "$json" | bash "$TEST_DIR/.claude/hooks/protect-registry.sh" 2>&1)
  local rc=$?
  assert_exit_code 0 "$rc" "valid registry write should pass"
}

test_protect_missing_header() {
  local content='Some random content without the header

| Project | Status | Priority | Progress | Next Milestone |
|---------|--------|----------|----------|----------------|'

  local json
  json=$(build_write_input_json "$TEST_DIR/projects/_registry.md" "$content")

  local output
  output=$(echo "$json" | bash "$TEST_DIR/.claude/hooks/protect-registry.sh" 2>&1)
  local rc=$?
  assert_exit_code 2 "$rc" "missing header should block"
}

test_protect_missing_table_header() {
  local content='# Project Registry

Some content but no table.'

  local json
  json=$(build_write_input_json "$TEST_DIR/projects/_registry.md" "$content")

  local output
  output=$(echo "$json" | bash "$TEST_DIR/.claude/hooks/protect-registry.sh" 2>&1)
  local rc=$?
  assert_exit_code 2 "$rc" "missing table header should block"
}

test_protect_empty_content() {
  local json
  json=$(build_write_input_json "$TEST_DIR/projects/_registry.md" "")

  local output
  output=$(echo "$json" | bash "$TEST_DIR/.claude/hooks/protect-registry.sh" 2>&1)
  local rc=$?
  assert_exit_code 2 "$rc" "empty content should block"
}


# ═════════════════════════════════════════════════════════════
# Run all hook tests
# ═════════════════════════════════════════════════════════════

run_hook_tests() {
  echo ""
  printf "${CYAN}Hook Tests${NC}\n"
  echo "────────────────────────────────────────"

  local start_passed=$TESTS_PASSED
  local start_failed=$TESTS_FAILED
  local start_skipped=$TESTS_SKIPPED

  # session-start.sh
  printf "\n  ${CYAN}session-start.sh${NC}\n"
  run_test "No registry → 'No projects tracked yet'" test_session_start_no_registry
  run_test "Empty registry → 'No projects tracked yet'" test_session_start_empty_registry
  run_test "1 active project with 2 WIP tasks" test_session_start_one_active_project
  run_test "Multiple statuses → '2 active, 1 planning'" test_session_start_multiple_statuses
  run_test "Recent blocker → '1 recent blockers'" test_session_start_recent_blocker
  run_test "Commands list always shown" test_session_start_commands_shown

  # advisor-nudge.sh
  printf "\n  ${CYAN}advisor-nudge.sh${NC}\n"
  run_test "No projects → silent" test_advisor_no_projects
  run_test "Healthy state → silent" test_advisor_healthy_state
  run_test "4 WIP tasks → 'WIP limit of 3' nudge" test_advisor_wip_overload
  run_test "3 WIP tasks → no nudge (at threshold)" test_advisor_wip_at_threshold
  run_test "Overdue task → 'Overdue tasks' nudge" test_advisor_overdue_task
  run_test "Future due dates → no nudge" test_advisor_future_due_date
  run_test "Stale blocker (5 days) → 'Unresolved blockers'" test_advisor_stale_blocker
  run_test "Fresh blocker (1 day) → no nudge" test_advisor_fresh_blocker
  run_test "Dormant project (7 days) → 'no activity for'" test_advisor_dormant_project
  run_test "Active project (today) → no nudge" test_advisor_active_project
  run_test "Goals stale (14+ days) → nudge" test_advisor_goals_stale
  run_test "Unblocked dependency → 'Task unblocked'" test_advisor_unblocked_dependency
  run_test "Priority inversion (P3 WIP + P1 backlog)" test_advisor_priority_inversion

  # recent-activity.sh
  printf "\n  ${CYAN}recent-activity.sh${NC}\n"
  run_test "No projects → silent" test_recent_no_projects
  run_test "Today's log entry → 'Recent Log Entries'" test_recent_todays_log_entry
  run_test "Completed task today → 'Recently Completed'" test_recent_completed_task_today
  run_test "In-progress tasks → 'In Progress'" test_recent_in_progress_tasks
  run_test "Review tasks → 'In Review'" test_recent_review_tasks
  run_test "No recent activity → silent" test_recent_no_recent_activity
  run_test "Today's blocker → 'Blockers'" test_recent_todays_blocker

  # eod-reminder.sh
  printf "\n  ${CYAN}eod-reminder.sh${NC}\n"
  run_test "Before 4 PM (hour=10) → silent" test_eod_before_4pm
  run_test "After 4 PM, 3 done + 1 change → unlogged" test_eod_after_4pm_unlogged_tasks
  run_test "After 4 PM, 2 done + 2 change → no unlogged" test_eod_after_4pm_all_logged
  run_test "After 4 PM, 0 tasks + 3 log entries" test_eod_after_4pm_logs_only
  run_test "After 4 PM, no activity → silent" test_eod_after_4pm_no_activity
  run_test "After 4 PM, no projects → silent" test_eod_after_4pm_no_projects

  # weekly-reminder.sh
  printf "\n  ${CYAN}weekly-reminder.sh${NC}\n"
  run_test "Tuesday (dow=2) → silent" test_weekly_tuesday
  run_test "Friday with activity → 'It's Friday'" test_weekly_friday_with_activity
  run_test "Monday with activity → 'It's Monday'" test_weekly_monday_with_activity
  run_test "Friday no activity → silent" test_weekly_friday_no_activity
  run_test "Saturday (dow=6) → silent" test_weekly_saturday
  run_test "No projects → silent" test_weekly_no_projects

  # archive-suggestion.sh
  printf "\n  ${CYAN}archive-suggestion.sh${NC}\n"
  run_test "No registry → silent" test_archive_no_registry
  run_test "Done project → 'Completed projects'" test_archive_done_project
  run_test "Dormant project 35 days → 'Deeply dormant'" test_archive_dormant_project
  run_test "Active recent project → silent" test_archive_active_recent_project
  run_test "Both done + dormant → both messages" test_archive_both_done_and_dormant

  # sync-progress.sh
  printf "\n  ${CYAN}sync-progress.sh${NC}\n"
  run_test "Non-board file → skip" test_sync_non_board_file
  run_test "Board with 2/4 done → 50%" test_sync_board_50_percent
  run_test "Board with 3/3 done → 100%" test_sync_board_100_percent
  run_test "Empty board → 0%" test_sync_empty_board
  run_test "No README → no crash, registry updated" test_sync_no_readme
  run_test "No registry → no crash, README updated" test_sync_no_registry
  run_test "Missing file_path in JSON → silent skip" test_sync_missing_file_path

  # validate-log-entry.sh
  printf "\n  ${CYAN}validate-log-entry.sh${NC}\n"
  run_test "Non-log file → pass" test_validate_non_log_file
  run_test "[decision] complete → pass" test_validate_decision_complete
  run_test "[decision] missing Decision → exit 2" test_validate_decision_missing_decision
  run_test "[decision] missing Context → exit 2" test_validate_decision_missing_context
  run_test "[decision] missing Rationale → exit 2" test_validate_decision_missing_rationale
  run_test "[decision] missing Impact → exit 2" test_validate_decision_missing_impact
  run_test "[decision] missing multiple → exit 2 with names" test_validate_decision_missing_multiple
  run_test "[blocker] 4 lines → pass" test_validate_blocker_complete
  run_test "[blocker] 2 lines → exit 2" test_validate_blocker_too_short
  run_test "[change] 2 lines → pass (short exempt)" test_validate_change_short_exempt
  run_test "[change] 4 lines complete → pass" test_validate_change_complete
  run_test "[change] 4 lines missing What → exit 2" test_validate_change_missing_what
  run_test "[research] 7 lines with Findings → pass" test_validate_research_complete
  run_test "[research] 7 lines no Findings → exit 2" test_validate_research_no_findings

  # protect-registry.sh
  printf "\n  ${CYAN}protect-registry.sh${NC}\n"
  run_test "Non-registry file → pass" test_protect_non_registry_file
  run_test "Valid write → pass" test_protect_valid_write
  run_test "Missing header → exit 2" test_protect_missing_header
  run_test "Missing table header → exit 2" test_protect_missing_table_header
  run_test "Empty content → exit 2" test_protect_empty_content

  HOOK_PASSED=$((TESTS_PASSED - start_passed))
  HOOK_FAILED=$((TESTS_FAILED - start_failed))
  HOOK_SKIPPED=$((TESTS_SKIPPED - start_skipped))
}
