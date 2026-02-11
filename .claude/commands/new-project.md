# /new-project

Create and scaffold a new project.

## Usage

```
/new-project "Project Name" [--priority P1|P2|P3] [--description "..."]
```

## Parameters

- **name** (required): The project name, in quotes
- **--priority** (optional): Priority level — P0, P1, P2, P3. Default: P2
- **--description** (optional): Short project description

## Execution

Delegate to the **project-manager** agent to:

1. Parse the project name and derive a kebab-case slug.
2. Create `projects/{slug}/` directory.
3. Read templates from `templates/` and replace all `{{placeholder}}` tokens:
   - `{{name}}` → project name
   - `{{slug}}` → kebab-case slug
   - `{{description}}` → provided description or "No description provided."
   - `{{date}}` → today's date (YYYY-MM-DD)
   - `{{priority}}` → priority level
4. Write `README.md`, `board.md`, and `log.md` into the project directory.
5. Add a row to `projects/_registry.md`.
6. Display confirmation with the created file paths.

## Output

```
Created project: {name}
  Slug: {slug}
  Priority: {priority}
  Files:
    - projects/{slug}/README.md
    - projects/{slug}/board.md
    - projects/{slug}/log.md
  Registry updated.
```

## Examples

```
/new-project "Migrate Mosyle to Jamf Pro" --priority P1
/new-project "SaaS License Audit" --priority P2 --description "Audit all SaaS subscriptions for cost optimization"
/new-project "Internal Tooling Dashboard"
```
