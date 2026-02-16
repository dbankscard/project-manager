# /triage

Scan connected inboxes (Slack, email) and classify items by urgency. Draft responses for actionable items. Never send anything without explicit approval.

## Usage

```
/triage [mode]
```

## Parameters

- **mode** (optional): One of `quick`, `digest`, or `full`. Default: `full`.
  - **quick** — Tier 1 only. Show items that need an immediate response and nothing else.
  - **digest** — One-line summaries per item, grouped by tier. No drafted responses.
  - **full** — Complete triage with context, project cross-references, and drafted responses.

## Execution

Delegate to the **chief-of-staff** agent to:

1. **Scan channels**:
   - If Slack MCP available: use `slack_search_public_and_private` to find recent messages mentioning the user, DMs, and threads the user is part of.
   - If email MCP available: scan inbox for unread items.
   - If no MCP channels are available, inform the user and stop.

2. **Read project context**:
   - Read `projects/_registry.md` to get the list of active projects and their slugs.
   - This is used to cross-reference inbox items with active projects.

3. **Classify each item**:
   - **Tier 1 — Respond Now**: Direct questions needing answers, blocking requests from stakeholders, time-sensitive asks (meetings starting soon, approvals needed), escalations.
   - **Tier 2 — Handle Today**: FYIs that need acknowledgment, requests with end-of-day deadlines, threads where input would be valuable, items related to active projects.
   - **Tier 3 — FYI / Archive**: Informational broadcasts, threads where the user is cc'd but not needed, completed discussion threads, automated notifications.

4. **Cross-reference with projects**:
   - For each item, check if it relates to an active project by matching keywords, project names, or participant names.
   - If it does, tag it with `[project-slug]` in the output.

5. **Draft responses** (full mode only):
   - For Tier 1 and Tier 2 items, draft a suggested response.
   - Keep drafts concise and professional.
   - Present drafts clearly separated from the triage list.

6. **Present results**:
   - Group by tier.
   - Within each tier, sort by relevance/urgency.
   - Never send any drafted response automatically.

## Output Format

### Quick Mode

```markdown
# Triage — Quick — YYYY-MM-DD

## Tier 1 — Respond Now
1. **#channel / DM from Name** — Summary of what's needed
   - Related project: [project-slug]
2. **#channel / Name** — Summary

Nothing else scanned. Run `/triage full` for complete results.
```

### Digest Mode

```markdown
# Triage — Digest — YYYY-MM-DD

## Tier 1 — Respond Now (N items)
1. #channel — Name — Summary [project-slug]
2. DM — Name — Summary

## Tier 2 — Handle Today (N items)
1. #channel — Name — Summary
2. #channel — Name — Summary [project-slug]

## Tier 3 — FYI / Archive (N items)
1. #channel — Summary
2. #channel — Summary
```

### Full Mode

```markdown
# Triage — Full — YYYY-MM-DD

## Tier 1 — Respond Now

### 1. Name in #channel — Subject/Summary
**Context:** Brief background on the thread or message.
**Related project:** [project-slug] (if applicable)
**Action needed:** What the user should do.

> **Draft response:**
> Suggested reply text here.

---

### 2. DM from Name — Subject/Summary
**Context:** Background.
**Action needed:** What's needed.

> **Draft response:**
> Suggested reply text here.

---

## Tier 2 — Handle Today

### 1. Name in #channel — Subject/Summary
**Context:** Background.
**Related project:** [project-slug]

> **Draft response:**
> Suggested reply text here.

---

## Tier 3 — FYI / Archive
- #channel — Summary of informational item
- #channel — Summary of completed thread

---

## Summary
- Tier 1: N items needing response
- Tier 2: N items to handle today
- Tier 3: N items filed as FYI
```

## Approval Flow

After presenting drafted responses:
```
Ready to send? Reply with:
- "send 1" — send draft for item #1
- "send 1,2,3" — send multiple drafts
- "edit 2" — modify draft #2 before sending
- "skip" — don't send anything
```

Drafted responses are NEVER sent without the user explicitly approving them.

## Examples

```
/triage
/triage quick
/triage digest
/triage full
```
