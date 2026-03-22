---
allowed-tools: Bash, Read, Write, LS, Task
---

# Issue Start

Begin work on a GitHub issue with parallel agents based on local issue analysis.

## Usage
```
/pm:issue-start <issue_number>
```

## Instructions

1. Resolve the local task file and epic directory:
   ```bash
   TASK_FILE=$(.claude/scripts/pm/resolve-issue-file.sh $ARGUMENTS)
   EPIC_DIR=$(dirname "$TASK_FILE")
   [ "$(basename "$EPIC_DIR")" = "issues" ] && EPIC_DIR=$(dirname "$EPIC_DIR")
   ANALYSIS_FILE="$EPIC_DIR/$ARGUMENTS-analysis.md"
   UPDATES_DIR="$EPIC_DIR/updates/$ARGUMENTS"
   ```
2. Require `ANALYSIS_FILE` unless the user explicitly asks to analyze inline first.
3. Respect `PARALLEL_MODE` and `WORKTREE_MODE` from `.claude/scripts/pm/resolve-config.sh`.
4. Create `UPDATES_DIR` and `stream-*.md` files there.
5. When launching agents, point them at:
   - the resolved `TASK_FILE`
   - `ANALYSIS_FILE`
   - `UPDATES_DIR/stream-<X>.md`
6. Confirm with the epic name, work location, and progress-tracking directory.
