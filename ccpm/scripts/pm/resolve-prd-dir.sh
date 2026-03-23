#!/bin/bash

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CFG="$ROOT/.claude/.ccpmrc"

if [ -f "$CFG" ]; then
  # shellcheck disable=SC1090
  set -a
  . "$CFG" 2>/dev/null || true
  set +a
fi

PRD_DIR="${CCPM_PRD_DIR:-${PRD_DIR:-docs/prds}}"

case "$PRD_DIR" in
  ./*) PRD_DIR="${PRD_DIR#./}" ;;
esac
PRD_DIR="${PRD_DIR%/}"

if [[ "$PRD_DIR" == *".."* ]]; then
  echo "❌ Security Error: PRD directory path cannot contain '..'" >&2
  exit 1
fi

if [[ "$PRD_DIR" == /* ]]; then
  echo "❌ Security Error: PRD directory must be relative to project root" >&2
  exit 1
fi

if [ "${1:-}" = "--ensure" ]; then
  mkdir -p "$ROOT/$PRD_DIR"
elif [ "${1:-}" = "--allow-missing" ]; then
  :
elif [ ! -d "$ROOT/$PRD_DIR" ]; then
  echo "❌ PRD directory not found: $PRD_DIR (absolute: $ROOT/$PRD_DIR)" >&2
  exit 1
fi

printf '%s\n' "$PRD_DIR"
