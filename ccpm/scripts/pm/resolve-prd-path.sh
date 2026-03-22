#!/bin/bash

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <prd_name>" >&2
  exit 1
fi

PRD_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRD_DIR="$("$SCRIPT_DIR/resolve-prd-dir.sh" 2>/dev/null || true)"

if [ -n "$PRD_DIR" ] && [ -f "$PRD_DIR/$PRD_NAME/prd.md" ]; then
  printf '%s\n' "$PRD_DIR/$PRD_NAME/prd.md"
  exit 0
fi

if [ -n "$PRD_DIR" ] && [ -f "$PRD_DIR/$PRD_NAME.md" ]; then
  printf '%s\n' "$PRD_DIR/$PRD_NAME.md"
  exit 0
fi

for legacy_root in ".claude/prds" ".cursor/ccpm/prds"; do
  if [ -f "$legacy_root/$PRD_NAME.md" ]; then
    printf '%s\n' "$legacy_root/$PRD_NAME.md"
    exit 0
  fi
done

echo "❌ PRD not found: $PRD_NAME" >&2
exit 1
