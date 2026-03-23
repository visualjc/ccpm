# Issue Analyze

Analyze an issue to identify parallel work streams.

## Usage
```
/pm:issue-analyze <issue_number>
```

## Instructions

1. Resolve the task file:
   ```bash
   TASK_FILE=$(.cursor/ccpm/scripts/pm/resolve-issue-file.sh $ARGUMENTS)
   EPIC_DIR=$(dirname "$TASK_FILE")
   [ "$(basename "$EPIC_DIR")" = "issues" ] && EPIC_DIR=$(dirname "$EPIC_DIR")
   ```
2. Read the GitHub issue and the resolved task file.
3. Create `"$EPIC_DIR/$ARGUMENTS-analysis.md"` with streams, dependencies, and conflict notes.
4. Confirm completion and point the user to `/pm:issue-start $ARGUMENTS`.
