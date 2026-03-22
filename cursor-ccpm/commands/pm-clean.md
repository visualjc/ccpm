# Clean

Archive completed planning artifacts without assuming the old global epic path.

## Usage
```bash
/pm:clean
```

## Instructions

1. Identify completed epics from the current project state.
2. Resolve each epic with:
   ```bash
   EPIC_DIR=$(.cursor/ccpm/scripts/pm/resolve-epic-dir.sh "<epic_name>")
   ```
3. Archive completed epics to:
   ```bash
   $(dirname "$EPIC_DIR")/.archived/$(basename "$EPIC_DIR")
   ```
4. Keep archive notes near the archived epic rather than in a fixed `.cursor/ccpm/epics/.archived/` root.
