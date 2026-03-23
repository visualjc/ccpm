# Epic Decompose

Break an epic into numbered task files.

## Usage
```
/pm:epic-decompose <feature_name>
```

## Instructions

1. Resolve the epic:
   ```bash
   EPIC_DIR=$(.cursor/ccpm/scripts/pm/resolve-epic-dir.sh $ARGUMENTS)
   mkdir -p "$EPIC_DIR/issues"
   ```
2. If task files already exist in `"$EPIC_DIR/issues/"` or legacy `"$EPIC_DIR/"`, confirm recreation.
3. Create task files in `"$EPIC_DIR/issues/"`.
4. When using Task agents, instruct them to write into `issues/`, not the epic root.
5. Append a task summary to `"$EPIC_DIR/epic.md"` and confirm completion.
