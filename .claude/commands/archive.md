# /archive

Archive, restore, or list archived projects.

## Usage

```
/archive {slug}
/archive --list
/archive --restore {slug}
```

## Actions

### Archive a project

Move a project to the archive:

1. Move `projects/{slug}/` directory to `projects/_archive/{slug}/`.
2. Remove the project's row from `projects/_registry.md`.
3. Add a row to `projects/_archive/_index.md` (create the file if it doesn't exist) with columns: Name, Slug, Archived Date, Final Status, Final Progress.
4. Log is preserved inside the archived directory — no data is lost.

### Restore a project (`--restore`)

Reverse the archive:

1. Move `projects/_archive/{slug}/` back to `projects/{slug}/`.
2. Remove the row from `projects/_archive/_index.md`.
3. Add the project back to `projects/_registry.md` with status `on-hold`.
4. Display confirmation.

### List archived projects (`--list`)

1. Read `projects/_archive/_index.md`.
2. Display the archive index table.
3. If no archived projects exist, say so.

## Archive Index Format

```markdown
# Archived Projects

| Project | Slug | Archived | Final Status | Final Progress |
|---------|------|----------|--------------|----------------|
| Project Name | slug | 2026-02-16 | done | 100% |
```

## Parameters

- **slug** (required for archive/restore): The project's kebab-case slug
- **--list**: List all archived projects
- **--restore**: Restore an archived project instead of archiving

## Execution

Delegate to the **project-manager** agent to:

1. Validate the project exists (in `projects/` for archive, in `projects/_archive/` for restore).
2. Perform the file move.
3. Update the registry and archive index.
4. Display confirmation.

## Examples

```
/archive old-migration
/archive --list
/archive --restore old-migration
```
