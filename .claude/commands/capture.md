# /capture

Capture a Slack thread or conversation as a structured log entry in a project.

## Usage

```
/capture {slack-url-or-query} {project-slug} [--tag decision|research|note|change|result]
```

## Parameters

- **source** (required): Either a Slack message URL, a channel name + topic to search, or a description of the conversation
- **project-slug** (required): The project to add the log entry to
- **--tag** (optional): Force a specific tag. If omitted, the agent analyzes the thread content and picks the best tag.

## Execution

Delegate to the **documenter** agent to:

1. **Locate the thread:**
   - If given a Slack URL: extract channel ID and message timestamp, use `slack_read_thread` to fetch it.
   - If given a channel + topic: use `slack_search_public` to find the relevant thread, then `slack_read_thread` to get the full conversation.
   - If given a description: search Slack for the most relevant thread.

2. **Analyze the content:**
   - Determine the best log tag based on the thread content:
     - Thread where a choice was made → `[decision]`
     - Thread with investigation or troubleshooting → `[research]`
     - Thread about a deployment or config change → `[change]`
     - Thread about outcomes or test results → `[result]`
     - General discussion → `[note]`
   - Override with `--tag` if specified.

3. **Transform to log entry:**
   - Distill the thread into the appropriate template format.
   - Attribute key points to participants by name (e.g., "Per Jane: ...").
   - Preserve important technical details, links, and decisions.
   - Don't just dump the raw thread — synthesize it into a useful record.

4. **Write the entry:**
   - Insert into `projects/{slug}/log.md` at the top of the `## Log` section.
   - Use the current timestamp for the entry.
   - Add a source reference: `_Captured from Slack: #channel-name, YYYY-MM-DD_`

5. **Confirm:**
   - Display the formatted entry.
   - Show what tag was selected and why (if auto-detected).

## Output Format

The log entry will follow the standard template for its tag, with an added source line:

```markdown
### YYYY-MM-DD HH:MM — [decision] Title derived from thread

**Decision:** Synthesized decision from the thread

**Context:** Background from the discussion

**Rationale:** Arguments made in the thread

**Impact:** Outcomes discussed

_Captured from Slack: #channel-name, YYYY-MM-DD_

---
```

## Examples

```
/capture "https://myteam.slack.com/archives/C123/p1234567890" jamf-migration
/capture "the Jamf vs Mosyle discussion in #it-infra" jamf-migration --tag decision
/capture "#it-infra DEP enrollment" jamf-migration --tag research
/capture "yesterday's thread about the firewall rules" network-upgrade
```
