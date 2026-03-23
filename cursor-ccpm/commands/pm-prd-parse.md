# PRD Parse

Convert a PRD into a technical implementation epic.

## Usage
```
/pm:prd-parse <feature_name>
```

## Instructions

1. Resolve the PRD path and matching epic directory:
   ```bash
   PRD_PATH=$(.cursor/ccpm/scripts/pm/resolve-prd-path.sh $ARGUMENTS)
   EPIC_DIR=$(.cursor/ccpm/scripts/pm/resolve-epic-dir.sh --ensure $ARGUMENTS $ARGUMENTS)
   ```
2. This legacy Cursor command remains 1:1: epic name must match the PRD name.
3. If `"$EPIC_DIR/epic.md"` already exists, confirm overwrite.
4. Read the PRD and write `"$EPIC_DIR/epic.md"` with standard epic frontmatter.
5. Confirm with:
   - `✅ Epic created: $EPIC_DIR/epic.md`
   - `Next: /pm:epic-decompose $ARGUMENTS`
