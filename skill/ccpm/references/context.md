# Context — Capture and Reload Project Knowledge

Use this workflow when the user wants CCPM to build or refresh durable context about the repository, or to load that context into a fresh session.

Context files live in `.claude/context/` regardless of which harness installed the skill.

---

## Create Initial Context

**Trigger**: "create project context", "set up context files", "document this repo for future sessions"

### Preflight
- Check whether `.claude/context/` already exists and contains markdown files.
- If context already exists, ask before overwriting all files.
- Confirm the repo is writable and collect a real timestamp with `date -u +"%Y-%m-%dT%H:%M:%SZ"`.

### Process

Inspect the repo before writing:
- `git status --short`
- `git branch --show-current`
- `git remote -v`
- `ls -la`
- `find . -maxdepth 2` for likely manifests, docs, and code roots
- Read `README.md` if present

Generate these files in `.claude/context/` with frontmatter:

```yaml
---
created: <ISO 8601>
last_updated: <ISO 8601>
version: 1.0
author: CCPM
---
```

Create:
- `progress.md`
- `project-structure.md`
- `tech-context.md`
- `system-patterns.md`
- `product-context.md`
- `project-brief.md`
- `project-overview.md`
- `project-vision.md`
- `project-style-guide.md`

Quality rules:
- No placeholder text
- Minimum useful content in every file
- Use evidence from the repo, not guesses
- Note uncertainties explicitly

### Output
- Summarize what was created
- Call out detected stack, repo state, and any missing information
- Suggest using context update/prime later

---

## Update Existing Context

**Trigger**: "update project context", "refresh context", "keep our context current"

### Preflight
- If `.claude/context/` is missing, tell the user to create context first.
- Gather current repo state:
  - `git status --short`
  - `git log --oneline -10`
  - `git diff --name-only HEAD~5..HEAD 2>/dev/null || true`

### Process

Update only files that actually need changes.

Always update:
- `progress.md`

Update conditionally:
- `project-structure.md` if directories/files moved or were added
- `tech-context.md` if dependency manifests changed
- `system-patterns.md` if architecture changed
- `product-context.md` if requirements or implemented features changed
- `project-overview.md` for major milestones
- `project-style-guide.md` if conventions changed

Preserve `created`, update `last_updated`, and keep edits surgical rather than regenerating everything.

### Output
- Report updated vs skipped files
- Summarize major repo changes captured in context
- Note any gaps or corrupted files

---

## Prime Context For A Session

**Trigger**: "prime context", "load project context", "bring me up to speed"

### Preflight
- Verify `.claude/context/` exists and contains readable markdown files.
- Note any missing or empty files.

### Load order
1. `project-overview.md`
2. `project-brief.md`
3. `tech-context.md`
4. `progress.md`
5. `project-structure.md`
6. `system-patterns.md`
7. `product-context.md`
8. `project-style-guide.md`
9. `project-vision.md`

### Process
- Read available files in priority order
- Validate frontmatter if present
- Supplement with `README.md` and current git state if context is incomplete

### Output
- Summarize project purpose, current branch, current status, and important warnings
- Clearly state what context was missing or stale
