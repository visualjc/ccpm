#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/layout-common.sh"

PRD_DIR="$("$SCRIPT_DIR/resolve-prd-dir.sh" --ensure)"
APPLY=false

if [ "${1:-}" = "--apply" ]; then
  APPLY=true
fi

ensure_dir() {
  local path
  path="$1"
  if [ -d "$path" ]; then
    return 0
  fi
  if $APPLY; then
    mkdir -p "$path"
    printf 'CREATED %s\n' "$path"
  else
    printf 'WOULD CREATE %s\n' "$path"
  fi
}

cleanup_if_empty() {
  local path
  path="$1"
  if $APPLY && [ -d "$path" ] && [ -z "$(find "$path" -mindepth 1 -print -quit 2>/dev/null)" ]; then
    rmdir "$path"
    printf 'REMOVED EMPTY %s\n' "$path"
  fi
}

move_file_safe() {
  local src dest
  src="$1"
  dest="$2"
  [ -f "$src" ] || return 0

  if [ ! -e "$dest" ]; then
    if $APPLY; then
      mkdir -p "$(dirname "$dest")"
      mv "$src" "$dest"
      printf 'MOVED %s -> %s\n' "$src" "$dest"
    else
      printf 'WOULD MOVE %s -> %s\n' "$src" "$dest"
    fi
    return 0
  fi

  if [ -f "$dest" ] && cmp -s "$src" "$dest"; then
    if $APPLY; then
      rm "$src"
      printf 'REMOVED DUPLICATE %s\n' "$src"
    else
      printf 'WOULD REMOVE DUPLICATE %s\n' "$src"
    fi
    return 0
  fi

  printf 'SKIP conflict: %s -> %s\n' "$src" "$dest"
}

move_dir_children_safe() {
  local src_dir dest_dir child dest_child
  src_dir="$1"
  dest_dir="$2"
  [ -d "$src_dir" ] || return 0

  ensure_dir "$dest_dir"

  while IFS= read -r -d '' child; do
    dest_child="$dest_dir/$(basename "$child")"
    if [ -d "$child" ]; then
      move_dir_children_safe "$child" "$dest_child"
    else
      move_file_safe "$child" "$dest_child"
    fi
  done < <(find "$src_dir" -mindepth 1 -maxdepth 1 -print0 2>/dev/null | sort -z)

  cleanup_if_empty "$src_dir"
}

quarantine_legacy_epic_conflict() {
  local src_dir legacy_root epic_name conflict_path archive_dir
  src_dir="$1"
  legacy_root="$2"
  epic_name="$3"
  conflict_path="$4"
  archive_dir="$legacy_root/.archived/duplicate-name-conflicts/$epic_name"

  if [ "$src_dir" = "$archive_dir" ]; then
    printf 'SKIP duplicate epic quarantine already active: %s (active epic at %s)\n' "$epic_name" "$conflict_path"
    return 0
  fi

  if [ -e "$archive_dir" ]; then
    printf 'SKIP duplicate epic quarantine conflict: %s -> %s (active epic at %s)\n' "$src_dir" "$archive_dir" "$conflict_path"
    return 0
  fi

  if $APPLY; then
    mkdir -p "$(dirname "$archive_dir")"
    mv "$src_dir" "$archive_dir"
    printf 'QUARANTINED duplicate epic: %s -> %s (active epic at %s)\n' "$src_dir" "$archive_dir" "$conflict_path"
  else
    printf 'WOULD QUARANTINE duplicate epic: %s -> %s (active epic at %s)\n' "$src_dir" "$archive_dir" "$conflict_path"
  fi
}

epic_name_conflict_exists() {
  local epic_name current_path epic_dir
  epic_name="$1"
  current_path="$2"

  while IFS= read -r epic_dir; do
    [ -n "$epic_dir" ] || continue
    [ "$epic_dir" = "$current_path" ] && continue
    if [ "$(basename "$epic_dir")" = "$epic_name" ]; then
      printf '%s\n' "$epic_dir"
      return 0
    fi
  done < <(ccpm_list_epic_dirs)

  return 1
}

normalize_nested_epic_dirs() {
  local epic_dir child name

  [ -d "$PRD_DIR" ] || return 0

  while IFS= read -r -d '' epic_dir; do
    [ -f "$epic_dir/epic.md" ] || continue
    ensure_dir "$epic_dir/issues"

    while IFS= read -r -d '' child; do
      name="$(basename "$child")"
      case "$name" in
        [0-9]*-analysis.md)
          # Old nested layouts already keep analysis files at epic root.
          continue
          ;;
        *.md)
          ccpm_is_numeric_task_filename "$name" || continue
          move_file_safe "$child" "$epic_dir/issues/$name"
          ;;
      esac
    done < <(find "$epic_dir" -mindepth 1 -maxdepth 1 -type f -name '*.md' -print0 2>/dev/null | sort -z)
  done < <(find "$PRD_DIR" -path '*/epics/*' -type d -print0 2>/dev/null | sort -z)
}

normalize_prd_reference() {
  local ref configured_prd_dir
  ref="$1"
  configured_prd_dir="$2"

  ref="${ref%\"}"
  ref="${ref#\"}"
  ref="${ref%\'}"
  ref="${ref#\'}"
  ref="${ref#./}"
  ref="${ref#\$\{PRD_DIR\}/}"
  ref="${ref#\$PRD_DIR/}"
  [ -n "$configured_prd_dir" ] && ref="${ref#$configured_prd_dir/}"
  ref="${ref#.claude/prds/}"
  ref="${ref#.cursor/ccpm/prds/}"

  if [ "$(basename "$ref")" = "prd.md" ]; then
    basename "$(dirname "$ref")"
  elif [[ "$ref" == *.md ]]; then
    basename "$ref" .md
  else
    basename "$ref"
  fi
}

resolve_prd_name_for_legacy_epic() {
  local epic_dir prd_ref prd_name prd_path
  epic_dir="$1"

  prd_ref="$(grep '^prd:' "$epic_dir/epic.md" 2>/dev/null | head -1 | sed 's/^prd:[[:space:]]*//')"
  if [ -n "$prd_ref" ]; then
    prd_name="$(normalize_prd_reference "$prd_ref" "$PRD_DIR")"
    if [ -n "$prd_name" ]; then
      printf '%s\n' "$prd_name"
      return 0
    fi
  fi

  prd_path="$("$SCRIPT_DIR/resolve-prd-path.sh" "$(basename "$epic_dir")" 2>/dev/null || true)"
  if [ -n "$prd_path" ]; then
    ccpm_prd_name_from_path "$prd_path"
    return 0
  fi

  return 1
}

echo "CCPM nested layout migration"
echo "Mode: $([ "$APPLY" = true ] && echo apply || echo dry-run)"
echo "Target PRD root: $PRD_DIR"
echo ""

normalize_nested_epic_dirs

while IFS= read -r -d '' prd_file; do
  prd_name="$(basename "$prd_file" .md)"
  move_file_safe "$prd_file" "$PRD_DIR/$prd_name/prd.md"
done < <(find "$PRD_DIR" -mindepth 1 -maxdepth 1 -type f -name '*.md' -print0 2>/dev/null | sort -z)

for legacy_prd_root in ".claude/prds" ".cursor/ccpm/prds"; do
  [ -d "$legacy_prd_root" ] || continue
  while IFS= read -r -d '' prd_file; do
    prd_name="$(basename "$prd_file" .md)"
    move_file_safe "$prd_file" "$PRD_DIR/$prd_name/prd.md"
  done < <(find "$legacy_prd_root" -mindepth 1 -maxdepth 1 -type f -name '*.md' -print0 2>/dev/null | sort -z)
  cleanup_if_empty "$legacy_prd_root"
done

for legacy_epic_root in ".claude/epics" ".cursor/ccpm/epics"; do
  [ -d "$legacy_epic_root" ] || continue
  while IFS= read -r -d '' epic_dir; do
    epic_name="$(basename "$epic_dir")"
    prd_name="$(resolve_prd_name_for_legacy_epic "$epic_dir" 2>/dev/null || true)"
    if [ -z "$prd_name" ]; then
      printf 'SKIP unmatched legacy epic: %s (no prd: link and no matching PRD name; add prd: metadata or create/move the target PRD first)\n' "$epic_name"
      continue
    fi

    target_epic_dir="$PRD_DIR/$prd_name/epics/$epic_name"
    conflict_path="$(epic_name_conflict_exists "$epic_name" "$epic_dir" || true)"
    if [ -n "$conflict_path" ] && [ "$conflict_path" != "$target_epic_dir" ]; then
      quarantine_legacy_epic_conflict "$epic_dir" "$legacy_epic_root" "$epic_name" "$conflict_path"
      continue
    fi

    ensure_dir "$target_epic_dir"
    ensure_dir "$target_epic_dir/issues"

    while IFS= read -r -d '' child; do
      name="$(basename "$child")"
      case "$name" in
        epic.md|github-mapping.md|execution-status.md)
          move_file_safe "$child" "$target_epic_dir/$name"
          ;;
        updates)
          move_dir_children_safe "$child" "$target_epic_dir/updates"
          ;;
        [0-9]*-analysis.md)
          move_file_safe "$child" "$target_epic_dir/$name"
          ;;
        *.md)
          ccpm_is_numeric_task_filename "$name" || continue
          move_file_safe "$child" "$target_epic_dir/issues/$name"
          ;;
      esac
    done < <(find "$epic_dir" -mindepth 1 -maxdepth 1 -print0 2>/dev/null | sort -z)

    cleanup_if_empty "$epic_dir"
  done < <(find "$legacy_epic_root" -mindepth 1 -maxdepth 1 -type d ! -name archived -print0 2>/dev/null | sort -z)
done

if ! $APPLY; then
  echo ""
  echo "Run with --apply to perform the migration."
fi
