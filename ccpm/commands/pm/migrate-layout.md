---
allowed-tools: Bash(bash .claude/scripts/pm/migrate-layout.sh), Bash(bash .claude/scripts/pm/migrate-layout.sh --apply)
---

# Migrate Layout

Preview or apply the nested planning storage migration.

## Usage
```
/pm:migrate-layout
```

## Instructions

1. Run the migration in dry-run mode first:
   ```bash
   bash .claude/scripts/pm/migrate-layout.sh
   ```
2. Summarize the planned moves and any skipped legacy epics.
3. Ask for confirmation before applying changes.
4. On explicit confirmation, run:
   ```bash
   bash .claude/scripts/pm/migrate-layout.sh --apply
   ```
