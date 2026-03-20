# CCPM Migration Guide

This fork moved from the old multi-payload `/pm:*` layout to a single installed skill at `skill/ccpm/`.

## What Changed

- `ccpm/` and `cursor-ccpm/` are gone from `main`
- the canonical package is now `skill/ccpm/`
- install target directories are harness-specific:
  - Claude Code: `.claude/skills/ccpm`
  - Cursor: `.cursor/skills/ccpm`
  - Codex: `skills/ccpm`
  - OpenClaw: `skills/ccpm`
- CCPM project data still lives in `.claude/`

## Command Migration

Old slash commands are retired. Use the `ccpm` skill via natural language or `/ccpm` where the harness exposes skill commands.

| Old | New |
|---|---|
| `/pm:prd-new payments` | `"I want to build payments"` |
| `/pm:prd-parse payments` | `"parse the payments PRD"` |
| `/pm:epic-decompose payments` | `"break down the payments epic"` |
| `/pm:epic-sync payments` | `"sync the payments epic to GitHub"` |
| `/pm:issue-start 1234` | `"start working on issue 1234"` |
| `/pm:status` | `"what's our status"` |
| `/pm:next` | `"what should I work on next"` |
| `/context:create` | `"create project context"` |
| `/context:update` | `"update project context"` |
| `/context:prime` | `"prime context"` |
| `/testing:prime` | `"figure out the test setup"` |
| `/testing:run path/to/test` | `"run tests for path/to/test"` |

## Legacy Snapshot

Before this migration, the old layout was preserved locally as:
- tag: `legacy-pre-skills-layout`
- branch: `codex/legacy-pre-skills-layout`

Push those refs if you want them available on the remote.
