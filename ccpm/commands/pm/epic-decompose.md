---
allowed-tools: Bash, Read, Write, LS, Task
---

# Epic Decompose

Break an epic into numbered task files.

## Usage
```
/pm:epic-decompose <feature_name>
```

## Instructions

1. Resolve the epic:
   ```bash
   EPIC_DIR=$(.claude/scripts/pm/resolve-epic-dir.sh $ARGUMENTS)
   mkdir -p "$EPIC_DIR/issues"
   ```
2. If task files already exist in `"$EPIC_DIR/issues/"` or legacy `"$EPIC_DIR/"`, confirm recreation.
3. Read `"$EPIC_DIR/epic.md"` and create tasks in:
   - `"$EPIC_DIR/issues/001.md"`
   - `"$EPIC_DIR/issues/002.md"`
   - ...
4. Keep the same task frontmatter schema as before.
5. When using Task agents, instruct them to write into `"$EPIC_DIR/issues/"`, not the epic root.
6. Append a task summary to `"$EPIC_DIR/epic.md"` and confirm completion.
