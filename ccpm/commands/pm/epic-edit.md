---
allowed-tools: Bash, Read, Write
---

# Epic Edit

Edit the resolved epic document and sync it if needed.

## Usage
```bash
/pm:epic-edit <epic_name>
```

## Instructions

1. Resolve the epic:
   ```bash
   EPIC_DIR=$(.claude/scripts/pm/resolve-epic-dir.sh "$ARGUMENTS") || exit 1
   ```
2. Read and edit:
   ```text
   $EPIC_DIR/epic.md
   ```
3. Preserve existing frontmatter and GitHub metadata.
4. If the epic is synced, update the GitHub issue from the resolved `epic.md`.
