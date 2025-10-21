# CCPM Configuration: PRD Directory

## Overview
Configure where PRDs are stored using the following precedence:
1. Environment variable: `CCPM_PRD_DIR`
2. Config file: `.claude/.ccpmrc` with `PRD_DIR=...`
3. Default (silent): `.claude/prds`

Paths are repo-relative and must not end with a trailing slash.

## First-Run Prompt
Interactive flows (e.g., `/pm:prd-new`) will prompt if neither env nor config is set:
- 1) `.claude/prds` (backward compatible)
- 2) `docs/prds` (recommended non-hidden)
- 3) Custom (normalized by removing leading `./` and trailing `/`)

The chosen path is persisted to `.claude/.ccpmrc` and created if missing.

## Resolver Script
All scripts resolve the PRD directory via:
```
.claude/scripts/pm/resolve-prd-dir.sh
```
- Outputs a repo-relative path (e.g., `docs/prds`)
- `--ensure` will create the directory if missing
- Callers that need an absolute path can prefix with `$ROOT/`

Example (from repo root):
```sh
PRD_DIR=$(.claude/scripts/pm/resolve-prd-dir.sh --ensure)
PRD_FILE="$PRD_DIR/my-feature.md"
```

Robust usage from any directory:
```sh
RESOLVER="$(git rev-parse --show-toplevel)/.claude/scripts/pm/resolve-prd-dir.sh"
PRD_DIR="$("$RESOLVER" --ensure)"
ROOT="$(git rev-parse --show-toplevel)"; ABS="$ROOT/$PRD_DIR"
```

## `.ccpmrc` Example
```ini
# Example CCPM config
# Store repo-relative path, no trailing slash
PRD_DIR=docs/prds
```

## Epic Frontmatter
When creating epics, the `prd:` frontmatter stores a repo-relative path, e.g.:
```
prd: docs/prds/my-feature.md
```

## Error Handling
- Misconfigured path: scripts fail fast with a clear message
- Interactive flows can offer to create directories or re-prompt
- `.ccpmrc` with comments/blank lines is supported; empty `PRD_DIR` is treated as absent

## Migration (Manual)
To move existing PRDs from `.claude/prds` to `docs/prds`:
```sh
mkdir -p docs/prds
mv .claude/prds/*.md docs/prds/
```
Update `.claude/.ccpmrc` with `PRD_DIR=docs/prds`.




