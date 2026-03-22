---
allowed-tools: Bash, Read, Write, LS
---

# Issue Close

Mark an issue complete locally and on GitHub.

## Usage
```
/pm:issue-close <issue_number> [completion_notes]
```

## Instructions

1. Resolve the task file and epic directory:
   ```bash
   TASK_FILE=$(.claude/scripts/pm/resolve-issue-file.sh $ARGUMENTS)
   EPIC_DIR=$(dirname "$TASK_FILE")
   [ "$(basename "$EPIC_DIR")" = "issues" ] && EPIC_DIR=$(dirname "$EPIC_DIR")
   ```
2. Update `status: closed` and `updated:` in `TASK_FILE`.
3. If `"$EPIC_DIR/updates/$ARGUMENTS/progress.md"` exists, set completion to `100%`.
4. Close the GitHub issue and update the parent epic issue body using `"$EPIC_DIR/epic.md"`.
5. Recalculate epic progress based on `"$EPIC_DIR/issues/"` or the legacy fallback task set.
