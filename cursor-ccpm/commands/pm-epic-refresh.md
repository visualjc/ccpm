# Epic Refresh

Refresh epic status from the resolved task files.

## Usage
```bash
/pm:epic-refresh <epic_name>
```

## Instructions

1. Resolve the epic and task roots:
   ```bash
   EPIC_DIR=$(.cursor/ccpm/scripts/pm/resolve-epic-dir.sh "$ARGUMENTS") || exit 1
   TASK_DIR="$EPIC_DIR/issues"
   [ -d "$TASK_DIR" ] || TASK_DIR="$EPIC_DIR"
   ```
2. Count open and closed tasks from `$TASK_DIR/[0-9]*.md`.
3. Compute progress from `closed / total`.
4. Update `$EPIC_DIR/epic.md` with the new `status`, `progress`, and `updated` values.
5. If the epic has a GitHub issue, sync its checklist from the resolved local task files.

## Important Notes

- In nested mode, numbered tasks live under `issues/`.
- Legacy fallback epics may still keep task files directly under the epic root.
