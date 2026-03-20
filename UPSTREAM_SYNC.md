# Upstream Sync Strategy

This fork tracks the upstream skills-first repo at `https://github.com/automazeio/ccpm.git`.

## Remote

Add the upstream remote if needed:

```bash
git remote add upstream https://github.com/automazeio/ccpm.git
```

## Ownership

Keep these paths as upstream-aligned as possible:
- `skill/ccpm/SKILL.md`
- upstream reference files in `skill/ccpm/references/`
- upstream scripts in `skill/ccpm/references/scripts/`
- top-level README/media when practical

Treat these as fork-owned:
- `project-install.sh`
- `install/`
- `MIGRATION.md`
- `UPSTREAM_SYNC.md`
- fork-only references such as `references/context.md` and `references/testing.md`
- additive conventions changes in `references/conventions.md` for `.claude/context/` and `.claude/testing-config.md`

## Cadence

- review upstream at least monthly or on every upstream release
- merge upstream into a dedicated sync branch first
- resolve conflicts by preserving upstream structure, then reapply fork-owned additions with the smallest possible diff

## Practical Sync Flow

Reviewable sync branch workflow:

```bash
git fetch upstream
git checkout -b codex/upstream-sync upstream/main
git checkout main
git merge --no-ff codex/upstream-sync
```

Direct merge workflow when a review branch is unnecessary:

```bash
git fetch upstream
git checkout main
git merge --no-ff upstream/main
```

If conflicts happen in upstream-owned files, prefer upstream shape first and reintroduce fork behavior additively.
