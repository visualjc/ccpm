# Conventions — File Formats, Paths & Rules

Read this before doing any file operations across all phases.

---

## Planning Storage

Use resolver scripts instead of hardcoded planning paths:

```bash
PRD_DIR=$(bash references/scripts/resolve-prd-dir.sh)
PRD_PATH=$(bash references/scripts/resolve-prd-path.sh <prd-name>)
EPIC_DIR=$(bash references/scripts/resolve-epic-dir.sh <epic-name>)
ISSUE_FILE=$(bash references/scripts/resolve-issue-file.sh <issue-number>)
```

For new repos, planning artifacts live under `docs/prds/` by default. `.claude/` remains for config, context, and testing.

### Canonical Layout

```text
<PRD_DIR>/
└── <prd-name>/
    ├── prd.md
    └── epics/
        ├── <epic-name>/
        │   ├── epic.md
        │   ├── issues/
        │   │   └── <N>.md
        │   ├── <N>-analysis.md
        │   ├── github-mapping.md
        │   ├── execution-status.md
        │   └── updates/
        │       └── <issue_N>/
        │           ├── stream-A.md
        │           ├── progress.md
        │           └── execution.md
        └── .archived/
            └── <epic-name>/
```

### Compatibility Rules

- Prefer `<PRD_DIR>/<name>/prd.md` over flat `<PRD_DIR>/<name>.md`.
- Prefer `<PRD_DIR>/<prd>/epics/<epic>/` over `.claude/epics/<epic>/`.
- Prefer `<epic>/issues/<N>.md` over `<epic>/<N>.md`.
- Preserve backward compatibility for reading until the repo is explicitly migrated.

---

## Frontmatter Schemas

### PRD (`<PRD_DIR>/<name>/prd.md`)
```yaml
---
name: <feature-name>
description: <one-liner>
status: backlog | active | completed
created: <ISO 8601>
---
```

### Epic (`<PRD_DIR>/<prd>/epics/<epic>/epic.md`)
```yaml
---
name: <epic-name>
status: backlog | in-progress | completed
created: <ISO 8601>
updated: <ISO 8601>
progress: 0%
prd: <PRD_DIR>/<prd>/prd.md
github: https://github.com/<owner>/<repo>/issues/<N>
---
```

### Task (`<epic>/issues/<N>.md`)
```yaml
---
name: <Task Title>
status: open | in-progress | closed
created: <ISO 8601>
updated: <ISO 8601>
github: https://github.com/<owner>/<repo>/issues/<N>
depends_on: []
parallel: true
conflicts_with: []
---
```

### Progress (`<epic>/updates/<N>/progress.md`)
```yaml
---
issue: <N>
started: <ISO 8601>
last_sync: <ISO 8601>
completion: 0%
---
```

### Testing Config (`.claude/testing-config.md`)
```yaml
---
framework: <name>
test_command: <command>
test_directory: <path>
config_file: <path or none>
last_updated: <ISO 8601>
---
```

---

## Datetime Rule

Always get real current datetime from the system:

```bash
date -u +"%Y-%m-%dT%H:%M:%SZ"
```

---

## GitHub Operations

### Repository Safety Check
```bash
remote_url=$(git remote get-url origin 2>/dev/null || echo "")
if [[ "$remote_url" == *"automazeio/ccpm"* ]] || [[ "$remote_url" == *"visualjc/ccpm"* ]]; then
  echo "❌ Cannot write to the CCPM template repository."
  echo "Update remote: git remote set-url origin https://github.com/YOUR/REPO.git"
  exit 1
fi
REPO=$(echo "$remote_url" | sed 's|.*github.com[:/]||' | sed 's|\.git$||')
```

### Authentication
Run the `gh` command directly and handle failure:

```bash
gh <command> || echo "❌ GitHub CLI failed. Run: gh auth login"
```

---

## Git / Worktree Conventions

- One branch per epic: `epic/<name>`
- Worktrees live at `../epic-<name>/`
- Commit format inside epics: `Issue #<N>: <description>`
- Never use `--force` in git operations

---

## Naming Conventions

- PRD names: kebab-case and unique within the project
- Epic names: kebab-case and unique across the project
- Task files before sync: `001.md`, `002.md`, ...
- Task files after sync: renamed to GitHub issue numbers
- Archived epics move to `<PRD_DIR>/<prd>/epics/.archived/<epic>/`

---

## Epic Progress Calculation

```bash
total=$(find <epic>/issues -mindepth 1 -maxdepth 1 -name '[0-9]*.md' | wc -l)
closed=$(grep -l '^status: closed' <epic>/issues/[0-9]*.md 2>/dev/null | wc -l)
progress=$((closed * 100 / total))
```

Update epic frontmatter when any task closes.
