# Issue Show

Display local and GitHub context for an issue.

## Usage
```
/pm:issue-show <issue_number>
```

## Instructions

1. Fetch GitHub issue details with `gh issue view #$ARGUMENTS`.
2. Resolve the local task file:
   ```bash
   TASK_FILE=$(.cursor/ccpm/scripts/pm/resolve-issue-file.sh $ARGUMENTS)
   EPIC_DIR=$(dirname "$TASK_FILE")
   [ "$(basename "$EPIC_DIR")" = "issues" ] && EPIC_DIR=$(dirname "$EPIC_DIR")
   ```
3. If found, display:
   - `Task file: $TASK_FILE`
   - `Updates: $EPIC_DIR/updates/$ARGUMENTS/`
4. Summarize acceptance criteria, dependencies, and recent activity.
