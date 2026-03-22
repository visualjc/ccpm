#!/bin/bash

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <issue_number>" >&2
  exit 1
fi

ISSUE_NUM="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRD_DIR="$("$SCRIPT_DIR/resolve-prd-dir.sh" --allow-missing 2>/dev/null || true)"

if [ -n "$PRD_DIR" ] && [ -d "$PRD_DIR" ]; then
  while IFS= read -r -d '' issue_file; do
    printf '%s\n' "$issue_file"
    exit 0
  done < <(find "$PRD_DIR" -path "*/issues/$ISSUE_NUM.md" -type f -print0 2>/dev/null | sort -z)

  while IFS= read -r -d '' issue_file; do
    printf '%s\n' "$issue_file"
    exit 0
  done < <(find "$PRD_DIR" -path "*/epics/*/$ISSUE_NUM.md" -type f -print0 2>/dev/null | sort -z)
fi

for legacy_root in ".claude/epics" ".cursor/ccpm/epics"; do
  while IFS= read -r -d '' legacy_file; do
    printf '%s\n' "$legacy_file"
    exit 0
  done < <(find "$legacy_root" -mindepth 2 -maxdepth 2 -name "$ISSUE_NUM.md" -type f -print0 2>/dev/null | sort -z)
done

echo "❌ Issue file not found: $ISSUE_NUM" >&2
exit 1
