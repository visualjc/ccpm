# Issue Sync

Push local updates as GitHub issue comments.

## Usage
```
/pm:issue-sync <issue_number>
```

## Instructions

1. Validate the issue exists on GitHub.
2. Resolve the task file and epic directory:
   ```bash
   TASK_FILE=$(.cursor/ccpm/scripts/pm/resolve-issue-file.sh $ARGUMENTS)
   EPIC_DIR=$(dirname "$TASK_FILE")
   [ "$(basename "$EPIC_DIR")" = "issues" ] && EPIC_DIR=$(dirname "$EPIC_DIR")
   UPDATES_DIR="$EPIC_DIR/updates/$ARGUMENTS"
   ```
3. Read local updates from `UPDATES_DIR`.
4. Post an incremental progress comment to GitHub.
5. Update `last_sync` in `progress.md` and `updated:` in `TASK_FILE`.
6. If the task is complete, close it and update epic progress.
