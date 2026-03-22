# Epic Start Worktree

Start epic execution in a dedicated worktree while keeping planning artifacts in the resolved layout.

## Usage
```bash
/pm:epic-start-worktree <epic_name>
```

## Instructions

1. Resolve the epic:
   ```bash
   EPIC_DIR=$(.cursor/ccpm/scripts/pm/resolve-epic-dir.sh "$ARGUMENTS") || exit 1
   TASK_DIR="$EPIC_DIR/issues"
   [ -d "$TASK_DIR" ] || TASK_DIR="$EPIC_DIR"
   ```
2. Create or reuse a worktree for `epic/$ARGUMENTS`.
3. Read inputs from:
   - `$EPIC_DIR/epic.md`
   - `$TASK_DIR/[0-9]*.md`
   - `$EPIC_DIR/{issue}-analysis.md`
   - `$EPIC_DIR/updates/{issue}/`
4. Track active work in `$EPIC_DIR/execution-status.md`.

## Important Notes

- The worktree changes git execution context, not planning-file location.
- Nested planning files remain under `docs/prds/...` even when code changes happen in a separate worktree.
