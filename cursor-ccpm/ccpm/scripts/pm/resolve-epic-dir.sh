#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRD_DIR="$("$SCRIPT_DIR/resolve-prd-dir.sh" --allow-missing 2>/dev/null || true)"

find_matching_epics() {
  local epic_name prd_dir epic_dir legacy_root
  epic_name="$1"

  prd_dir="$("$SCRIPT_DIR/resolve-prd-dir.sh" --allow-missing 2>/dev/null || true)"
  if [ -n "$prd_dir" ] && [ -d "$prd_dir" ]; then
    while IFS= read -r -d '' epic_dir; do
      [ -f "$epic_dir/epic.md" ] || continue
      printf '%s\n' "$epic_dir"
    done < <(find "$prd_dir" -path "*/epics/$epic_name" -type d -print0 2>/dev/null | sort -z)
  fi

  for legacy_root in ".claude/epics" ".cursor/ccpm/epics"; do
    if [ -f "$legacy_root/$epic_name/epic.md" ]; then
      printf '%s\n' "$legacy_root/$epic_name"
    fi
  done
}

if [ "${1:-}" = "--ensure" ]; then
  if [ $# -ne 3 ]; then
    echo "Usage: $0 --ensure <prd_name> <epic_name>" >&2
    exit 1
  fi
  PRD_NAME="$2"
  EPIC_NAME="$3"
  [ -n "$PRD_DIR" ] || PRD_DIR="$("$SCRIPT_DIR/resolve-prd-dir.sh" --ensure)"
  target_dir="$PRD_DIR/$PRD_NAME/epics/$EPIC_NAME"
  existing_matches="$(find_matching_epics "$EPIC_NAME")"
  if [ -n "$existing_matches" ]; then
    while IFS= read -r existing_dir; do
      [ -n "$existing_dir" ] || continue
      if [ "$existing_dir" != "$target_dir" ]; then
        echo "❌ Duplicate epic name: $EPIC_NAME already exists at $existing_dir" >&2
        exit 1
      fi
    done <<< "$existing_matches"
  fi
  mkdir -p "$PRD_DIR/$PRD_NAME/epics/$EPIC_NAME/issues"
  printf '%s\n' "$PRD_DIR/$PRD_NAME/epics/$EPIC_NAME"
  exit 0
fi

if [ $# -ne 1 ]; then
  echo "Usage: $0 <epic_name>" >&2
  exit 1
fi

EPIC_NAME="$1"
matches="$(find_matching_epics "$EPIC_NAME")"
match_count="$(printf '%s\n' "$matches" | sed '/^$/d' | wc -l | tr -d '[:space:]')"

if [ "$match_count" -eq 1 ]; then
  printf '%s\n' "$matches" | sed '/^$/d' | head -1
  exit 0
fi

if [ "$match_count" -gt 1 ]; then
  echo "❌ Ambiguous epic name: $EPIC_NAME" >&2
  printf '%s\n' "$matches" | sed '/^$/d' >&2
  exit 1
fi

echo "❌ Epic not found: $EPIC_NAME" >&2
exit 1
