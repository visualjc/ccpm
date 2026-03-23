# Track — Know Where Things Stand

Tracking operations use bash scripts directly for speed and consistency.

---

## Script-First Rule

All tracking operations have a corresponding bash script. Run the script; do not reconstruct the output manually.

Scripts live in `references/scripts/` relative to this skill and operate from the project root. They resolve planning paths through:
- `resolve-prd-dir.sh`
- `resolve-prd-path.sh`
- `resolve-epic-dir.sh`
- `resolve-issue-file.sh`

That means they work against both:
- canonical nested storage under `docs/prds/...`
- legacy `.claude/prds` and `.claude/epics` data until migration is complete

---

## Available Reports

- Project status: `bash references/scripts/status.sh`
- Standup report: `bash references/scripts/standup.sh`
- List epics: `bash references/scripts/epic-list.sh`
- Show epic: `bash references/scripts/epic-show.sh <name>`
- Epic status: `bash references/scripts/epic-status.sh <name>`
- List PRDs: `bash references/scripts/prd-list.sh`
- PRD status: `bash references/scripts/prd-status.sh`
- Search: `bash references/scripts/search.sh "<query>"`
- In progress: `bash references/scripts/in-progress.sh`
- What's next: `bash references/scripts/next.sh`
- What's blocked: `bash references/scripts/blocked.sh`
- Validate project state: `bash references/scripts/validate.sh`
- Migrate legacy planning layout: `bash references/scripts/migrate-layout.sh [--apply]`

---

## When Scripts Fail

If a script fails or the user asks for interpretation, explain the output after running the script.

If the repo has no planning root yet, initialize CCPM first so `docs/prds/` and `.claude/.ccpmrc` are created.
