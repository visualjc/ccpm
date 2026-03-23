# Epic Start

Launch work on a resolved epic without hardcoding legacy planning paths.

## Usage
```bash
/pm:epic-start <epic_name>
```

## Instructions

1. Resolve the epic directory:
   ```bash
   EPIC_DIR=$(.cursor/ccpm/scripts/pm/resolve-epic-dir.sh "$ARGUMENTS") || exit 1
   TASK_DIR="$EPIC_DIR/issues"
   [ -d "$TASK_DIR" ] || TASK_DIR="$EPIC_DIR"
   ```
2. Refuse to start if the repo is dirty or the epic is not synced when sync is required.
3. Build the dependency view from `$TASK_DIR/[0-9]*.md`.
4. Use these resolved paths during execution:
   - epic: `$EPIC_DIR/epic.md`
   - analysis: `$EPIC_DIR/{issue}-analysis.md`
   - updates: `$EPIC_DIR/updates/{issue}/stream-{X}.md`
   - execution tracker: `$EPIC_DIR/execution-status.md`
5. If `PARALLEL_MODE=true`, launch one agent per approved stream and keep ownership in `execution-status.md`.
6. If `PARALLEL_MODE=false`, execute issue streams sequentially in the current session.

## Important Notes

- Nested mode stores tasks under `docs/prds/<prd>/epics/<epic>/issues/`.
- Legacy fallback epics under `.cursor/ccpm/epics/<epic>/` and `.claude/epics/<epic>/` still resolve through `resolve-epic-dir.sh`.
