---
allowed-tools: Bash, Read, Write
---

# Epic Merge

Merge a completed epic branch or worktree back to `main` while keeping planning data in the resolved layout.

## Usage
```bash
/pm:epic-merge <epic_name>
```

## Instructions

1. Resolve the epic:
   ```bash
   EPIC_DIR=$(.claude/scripts/pm/resolve-epic-dir.sh "$ARGUMENTS") || exit 1
   TASK_DIR="$EPIC_DIR/issues"
   [ -d "$TASK_DIR" ] || TASK_DIR="$EPIC_DIR"
   ```
2. Check `$EPIC_DIR/execution-status.md` before merging to ensure there is no active work left running.
3. Validate the branch or worktree is clean, then merge `epic/$ARGUMENTS` into `main`.
4. Update `$EPIC_DIR/epic.md` to completed state before cleanup.
5. Build merge notes from `$TASK_DIR/[0-9]*.md`.
6. After a successful merge:
   - remove the worktree if one exists
   - delete the `epic/$ARGUMENTS` branch if appropriate
   - archive the epic to `$(dirname "$EPIC_DIR")/.archived/$(basename "$EPIC_DIR")`
7. Close synced GitHub epic and task issues using the resolved files.

## Important Notes

- Do not assume numbered tasks are in the epic root.
- Keep archive handling relative to `EPIC_DIR` so nested and legacy fallback layouts both work.
