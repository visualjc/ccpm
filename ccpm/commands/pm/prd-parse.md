---
allowed-tools: Bash, Read, Write, LS
---

# PRD Parse

Convert a PRD into a technical implementation epic.

## Usage
```
/pm:prd-parse <feature_name>
```

## Instructions

1. Resolve the PRD path:
   ```bash
   PRD_PATH=$(.claude/scripts/pm/resolve-prd-path.sh $ARGUMENTS)
   EPIC_DIR=$(.claude/scripts/pm/resolve-epic-dir.sh --ensure $ARGUMENTS $ARGUMENTS)
   ```
2. This legacy command remains 1:1: epic name must match the PRD name.
3. If `"$EPIC_DIR/epic.md"` already exists, confirm overwrite.
4. Read the PRD from `PRD_PATH` and create `"$EPIC_DIR/epic.md"` with standard epic frontmatter:
   - `name: $ARGUMENTS`
   - `prd: $PRD_PATH`
   - `progress: 0%`
5. Confirm with:
   - `✅ Epic created: $EPIC_DIR/epic.md`
   - `Next: /pm:epic-decompose $ARGUMENTS`
