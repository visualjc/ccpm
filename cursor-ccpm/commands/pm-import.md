# Import

Import GitHub issues into the nested planning layout.

## Usage
```bash
/pm:import [--epic <epic_name>] [--label <label>]
```

## Instructions

1. Fetch GitHub issues with `gh issue list`.
2. Determine whether each issue maps to a PRD, epic, or task.
3. When creating an epic locally, use:
   ```bash
   EPIC_DIR=$(.cursor/ccpm/scripts/pm/resolve-epic-dir.sh --ensure <prd_name> <epic_name>)
   ```
4. Store imports as:
   - PRD: `docs/prds/<prd>/prd.md`
   - Epic: `docs/prds/<prd>/epics/<epic>/epic.md`
   - Task: `docs/prds/<prd>/epics/<epic>/issues/<number>.md`
5. Preserve GitHub metadata and never overwrite an existing tracked file.
