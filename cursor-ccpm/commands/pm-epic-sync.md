# Epic Sync

Push an epic and its tasks to GitHub.

## Usage
```
/pm:epic-sync <feature_name>
```

## Instructions

1. Resolve the epic directory:
   ```bash
   EPIC_DIR=$(.cursor/ccpm/scripts/pm/resolve-epic-dir.sh $ARGUMENTS)
   ```
2. Use `"$EPIC_DIR/issues/"` as the canonical task directory.
3. Create the parent epic issue from `"$EPIC_DIR/epic.md"`.
4. Create task issues from numbered task files.
5. Rename task files inside `issues/` from `001.md` to `<issue-number>.md`.
6. Update task dependencies/conflicts to real issue numbers.
7. Write `"$EPIC_DIR/github-mapping.md"`.
8. Update `github:` and `updated:` in `"$EPIC_DIR/epic.md"` and each resolved task file.
