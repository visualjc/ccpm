---
allowed-tools: Bash, Read, Write, LS
---

# Epic Close

Close a completed epic using the resolved nested layout.

## Usage
```bash
/pm:epic-close <epic_name>
```

## Instructions

1. Resolve the epic:
   ```bash
   EPIC_DIR=$(.claude/scripts/pm/resolve-epic-dir.sh "$ARGUMENTS") || exit 1
   TASK_DIR="$EPIC_DIR/issues"
   [ -d "$TASK_DIR" ] || TASK_DIR="$EPIC_DIR"
   ```
2. Verify every task in `$TASK_DIR/[0-9]*.md` is closed.
3. Update `$EPIC_DIR/epic.md` to `status: completed` and `progress: 100%`.
4. Close the GitHub epic issue if one is linked.
5. If archiving is requested, move the epic to:
   ```bash
   $(dirname "$EPIC_DIR")/.archived/$(basename "$EPIC_DIR")
   ```

## Important Notes

- Nested epics archive under `<prd>/epics/.archived/<epic>/`.
- Legacy fallback epics may still archive from `.claude/epics/archived/<epic>/`.
