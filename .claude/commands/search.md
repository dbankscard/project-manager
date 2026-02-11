# /search

Search across all projects for keywords or phrases.

## Usage

```
/search "query" [--project {slug}] [--type logs|tasks|all] [--slack]
```

## Parameters

- **query** (required): Search term or phrase
- **--project** (optional): Limit search to a specific project slug
- **--type** (optional): Filter by content type — `logs`, `tasks`, or `all` (default: `all`)
- **--slack** (optional): Also search Slack for the query and include results

## Execution

Delegate to the **documenter** agent to:

1. Determine the search scope:
   - All projects: search `projects/*/`
   - Specific project: search `projects/{slug}/`
2. Use Grep to search for the query across relevant files.
3. Group results by project.
4. Show surrounding context for each match.
5. Format and display results.

## Output Format

```markdown
# Search Results: "query"

## project-slug (X matches)

**log.md** — YYYY-MM-DD [tag] Entry title
> ...matching context...

**board.md** — Column Name
> - [ ] Task with matching text `P1`

---
No more results. Searched X projects, Y files.
```

If no results:
```
No results found for "query" across X projects.
```

## Slack Search

When `--slack` is provided:
1. Search project files as normal.
2. Also search Slack using `slack_search_public` for the same query.
3. Present Slack results in a separate section, labeled with channel name, author, and date.
4. If a Slack thread looks relevant, suggest using `/capture` to save it as a log entry.

## Examples

```
/search "DEP"
/search "license" --project saas-audit
/search "blocker" --type logs
/search "migration runbook" --project jamf-migration --type tasks
/search "Jamf" --slack
```
