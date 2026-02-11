# /search

Search across all projects for keywords or phrases.

## Usage

```
/search "query" [--project {slug}] [--type logs|tasks|all]
```

## Parameters

- **query** (required): Search term or phrase
- **--project** (optional): Limit search to a specific project slug
- **--type** (optional): Filter by content type — `logs`, `tasks`, or `all` (default: `all`)

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

## Examples

```
/search "DEP"
/search "license" --project saas-audit
/search "blocker" --type logs
/search "migration runbook" --project jamf-migration --type tasks
```
