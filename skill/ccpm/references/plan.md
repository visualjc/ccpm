# Plan — Capture Requirements

This phase turns an idea into a structured PRD, then converts the PRD into one or more technical epics ready for decomposition.

---

## Writing a PRD

**Trigger**: User wants to plan a new feature, product requirement, or area of work.

### Preflight
- Resolve the planning root with `bash references/scripts/resolve-prd-dir.sh --ensure`.
- Use `<PRD_DIR>/<name>/prd.md` as the canonical PRD path.
- If `<PRD_DIR>/<name>/prd.md` or legacy `<PRD_DIR>/<name>.md` already exists, confirm overwrite before proceeding.
- Feature name must be kebab-case.

### Process

Conduct a genuine brainstorming session before writing anything. Ask the user:
- What problem does this solve?
- Who are the users affected?
- What does success look like?
- What's explicitly out of scope?
- What are the constraints (tech, time, resources)?

Then write `<PRD_DIR>/<name>/prd.md` with:

```markdown
---
name: <feature-name>
description: <one-line summary>
status: backlog
created: <run: date -u +"%Y-%m-%dT%H:%M:%SZ">
---

# PRD: <feature-name>

## Executive Summary
## Problem Statement
## User Stories
## Functional Requirements
## Non-Functional Requirements
## Success Criteria
## Constraints & Assumptions
## Out of Scope
## Dependencies
```

**After creation**: Confirm the resolved PRD path and suggest parsing it into an epic.

---

## Parsing a PRD into a Technical Epic

**Trigger**: User wants to convert an existing PRD into a technical implementation plan.

### Preflight
- Resolve the PRD with `bash references/scripts/resolve-prd-path.sh <prd-name>`.
- Determine the epic name:
  - default: same as the PRD name
  - if the user clearly requests a named epic, use that epic name instead
- Resolve the epic directory with `bash references/scripts/resolve-epic-dir.sh --ensure <prd-name> <epic-name>`.
- If `epic.md` already exists there, confirm overwrite before proceeding.

### Process

Read the PRD fully, then produce `<epic-dir>/epic.md`:

```markdown
---
name: <epic-name>
status: backlog
created: <run: date -u +"%Y-%m-%dT%H:%M:%SZ">
updated: <same as created>
progress: 0%
prd: <resolved prd path>
github: (will be set on sync)
---

# Epic: <epic-name>

## Overview
## Architecture Decisions
## Technical Approach
### Frontend Components
### Backend Services
### Infrastructure
## Implementation Strategy
## Task Breakdown Preview
## Dependencies
## Success Criteria (Technical)
## Estimated Effort
```

**Key constraints:**
- Aim for ≤10 tasks total.
- Prefer existing functionality over new surface area.
- Identify parallelization opportunities.

**After creation**: Confirm the resolved epic path and suggest decomposition.

---

## Editing a PRD or Epic

Read the resolved file first. Make targeted edits while preserving frontmatter and update `updated:` with the current datetime.
