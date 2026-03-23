# Sync — Push to GitHub & Track Progress

This phase covers pushing local epics/tasks to GitHub as issues, syncing progress as comments, and closing issues when work is done.

---

## Repository Safety Check

Always run this before any GitHub write operation:

```bash
remote_url=$(git remote get-url origin 2>/dev/null || echo "")
if [[ "$remote_url" == *"automazeio/ccpm"* ]] || [[ "$remote_url" == *"visualjc/ccpm"* ]]; then
  echo "❌ Cannot sync to the CCPM template repository."
  echo "Update remote: git remote set-url origin https://github.com/YOUR/REPO.git"
  exit 1
fi
REPO=$(echo "$remote_url" | sed 's|.*github.com[:/]||' | sed 's|\.git$||')
```

---

## Epic Sync — Push Epic + Tasks to GitHub

**Trigger**: User wants to push a local epic and its tasks to GitHub as issues.

### Preflight
- Resolve `EPIC_DIR` with `bash references/scripts/resolve-epic-dir.sh <epic-name>`.
- Verify `EPIC_DIR/epic.md` exists.
- Use `EPIC_DIR/issues/*.md` as the canonical task set; fall back to legacy task files only if `issues/` does not exist.

### Process

1. Create the epic issue from `EPIC_DIR/epic.md`.
2. Create task issues from `EPIC_DIR/issues/*.md`.
3. Rename task files from `001.md` to `<issue-number>.md` within `EPIC_DIR/issues/`.
4. Update `depends_on` / `conflicts_with` references to real GitHub issue numbers.
5. Update frontmatter `github:` and `updated:` fields.
6. Create `EPIC_DIR/github-mapping.md`.
7. Create the worktree for the epic branch.

---

## Issue Sync — Post Progress to GitHub

**Trigger**: User wants to sync local development progress to a GitHub issue as a comment.

### Preflight
- Verify the issue exists.
- Resolve the task file with `resolve-issue-file.sh`.
- Use `<epic-dir>/updates/<N>/progress.md` as the progress source.

### Process

Gather updates from `<epic-dir>/updates/<N>/` and post a progress comment to GitHub. After posting:
- update `last_sync` in `progress.md`
- update `updated:` in the resolved task file

---

## Closing an Issue

**Trigger**: User marks a task complete.

### Process

1. Resolve the local task file with `resolve-issue-file.sh`.
2. Update `status: closed` and `updated:`.
3. Post a completion comment and close the GitHub issue.
4. Update the parent epic issue body.
5. Recalculate epic progress based on `EPIC_DIR/issues/*.md`.

---

## Merging an Epic

**Trigger**: User wants to merge a completed epic back to main.

### Process

- run tests from the epic worktree
- merge `epic/<name>` into `main`
- remove the worktree
- archive the epic to `<prd-dir>/epics/.archived/<name>/`
- close the GitHub epic issue

---

## Reporting a Bug Against a Completed Issue

**Trigger**: User finds a bug while testing a completed or in-progress issue.

### Process

1. Read the original GitHub issue and resolved local task file.
2. Create a local bug task in the same epic:
   - canonical: `<epic-dir>/issues/bug-<original_N>-<slug>.md`
   - after sync: rename to `<new_N>.md`
3. Create the linked GitHub issue.
4. Update the local bug file with the GitHub issue number.
