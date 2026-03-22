# Execute — Start Building with Parallel Agents

This phase covers analyzing GitHub issues for parallel work streams and launching agents to execute them.

---

## Issue Analysis

**Trigger**: User wants to understand how to parallelize work on an issue before starting.

### Preflight
- Find the local task file with `bash references/scripts/resolve-issue-file.sh <N>`.
- Derive the epic directory from that task file:
  - nested: parent of `issues/`
  - legacy: parent of the task file
- If not found: "❌ No local task for issue #<N>. Run a sync first."

### Process

Get issue details: `gh issue view <N> --json title,body,labels`

Read the local task file fully. Identify independent work streams by asking:
- Which files will be created or modified?
- Which changes can happen simultaneously without conflict?
- What are the dependencies between changes?

Create `<epic-dir>/<N>-analysis.md`:

```markdown
---
issue: <N>
title: <title>
analyzed: <run: date -u +"%Y-%m-%dT%H:%M:%SZ">
estimated_hours: <total>
parallelization_factor: <1.0-5.0>
---

# Parallel Work Analysis: Issue #<N>
...
```

---

## Starting an Issue

**Trigger**: User wants to begin work on a specific GitHub issue.

### Preflight
1. Verify the issue exists and is open.
2. Resolve the local task file.
3. Check for `<epic-dir>/<N>-analysis.md`; create it first if needed.
4. Verify the epic worktree exists.

### Process

Use `<epic-dir>/updates/<N>/` for execution tracking:

```bash
mkdir -p <epic-dir>/updates/<N>
```

Create `<epic-dir>/updates/<N>/stream-<X>.md` files for each active stream and keep `<epic-dir>/updates/<N>/execution.md` as the execution summary.

When launching parallel agents, point them at:
1. the resolved task file
2. `<epic-dir>/<N>-analysis.md`
3. `<epic-dir>/updates/<N>/stream-<X>.md`

Queued streams wait for dependencies to clear.

---

## Starting a Full Epic

**Trigger**: User wants to launch parallel agents across all ready issues in an epic at once.

### Preflight
- Resolve `<epic-dir>` and verify `epic.md` has a `github:` field.
- Check for a clean worktree.

### Process

Read all task files from:
- canonical: `<epic-dir>/issues/*.md`
- legacy fallback: `<epic-dir>/*.md`

Categorize tasks into ready, blocked, in-progress, and complete, then launch agents for all ready tasks and maintain `<epic-dir>/execution-status.md`.
