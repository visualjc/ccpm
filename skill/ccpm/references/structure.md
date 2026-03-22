# Structure — Break Down an Epic

This phase converts a technical epic into concrete, numbered task files with dependency and parallelization metadata.

---

## Epic Decomposition

**Trigger**: User wants to break an epic into actionable tasks.

### Preflight
- Resolve the epic with `bash references/scripts/resolve-epic-dir.sh <epic-name>`.
- Use `<epic-dir>/issues/` as the canonical task directory.
- If numbered task files already exist in `issues/` or legacy epic root, list them and confirm deletion before recreating.
- If the epic is completed, warn before proceeding.

### Process

Read the epic fully. Analyze which work can happen simultaneously without file conflicts.

Create task files as:
- `<epic-dir>/issues/001.md`
- `<epic-dir>/issues/002.md`
- ...

Task file format:

```markdown
---
name: <Task Title>
status: open
created: <run: date -u +"%Y-%m-%dT%H:%M:%SZ">
updated: <same as created>
github: (will be set on sync)
depends_on: []
parallel: true
conflicts_with: []
---

# Task: <Task Title>

## Description

## Acceptance Criteria
- [ ]

## Technical Details

## Dependencies

## Effort Estimate
- Size: XS/S/M/L/XL
- Hours: N

## Definition of Done
- [ ] Code implemented
- [ ] Tests written and passing
- [ ] Code reviewed
```

### Parallelization Strategy

- Small epic: create sequentially
- Medium epic: batch into 2–3 groups
- Large epic: analyze dependencies first, then parallelize

### After Creating All Tasks

Append a summary to `<epic-dir>/epic.md`:

```markdown
## Tasks Created
- [ ] 001.md - <Title> (parallel: true/false)
- [ ] 002.md - <Title> (parallel: true/false)

Total tasks: N
Parallel tasks: N
Sequential tasks: N
Estimated total effort: N hours
```

**After completion**: Confirm the resolved `issues/` path and suggest syncing the epic to GitHub.
