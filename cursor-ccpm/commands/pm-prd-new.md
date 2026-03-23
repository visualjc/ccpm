# PRD New

Launch brainstorming for a new product requirement document.

## Usage
```
/pm:prd-new <feature_name>
```

## Instructions

1. Validate `$ARGUMENTS` is kebab-case.
2. Resolve the planning root:
   ```bash
   PRD_DIR=$(.cursor/ccpm/scripts/pm/resolve-prd-dir.sh --ensure)
   PRD_PATH="$PRD_DIR/$ARGUMENTS/prd.md"
   LEGACY_PATH="$PRD_DIR/$ARGUMENTS.md"
   ```
3. If either `PRD_PATH` or `LEGACY_PATH` already exists, confirm overwrite.
4. Brainstorm thoroughly with the user before writing.
5. Save the PRD to `PRD_PATH`.
6. Confirm with:
   - `✅ PRD created: $PRD_PATH`
   - `Next: /pm:prd-parse $ARGUMENTS`
