# Epic Oneshot

Execute a small epic end-to-end using the resolved planning paths.

## Usage
```bash
/pm:epic-oneshot <epic_name>
```

## Instructions

1. Resolve the epic:
   ```bash
   EPIC_DIR=$(.cursor/ccpm/scripts/pm/resolve-epic-dir.sh "$ARGUMENTS") || exit 1
   TASK_DIR="$EPIC_DIR/issues"
   [ -d "$TASK_DIR" ] || TASK_DIR="$EPIC_DIR"
   ```
2. Confirm the epic is small enough for a one-shot pass.
3. Read:
   - `$EPIC_DIR/epic.md`
   - `$TASK_DIR/[0-9]*.md`
   - `$EPIC_DIR/{issue}-analysis.md` when present
4. Implement, test, and record progress in `$EPIC_DIR/updates/{issue}/` and `$EPIC_DIR/execution-status.md`.
