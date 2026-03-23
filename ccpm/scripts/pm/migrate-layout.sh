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
  local src_dir dest_dir child dest_child first_child
  src_dir="$1"
  dest_dir="$2"
  [ -d "$src_dir" ] || return 0

  first_child="$(find "$src_dir" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null || true)"
  if [ -z "$first_child" ]; then
    cleanup_if_empty "$src_dir"
    return 0
  fi

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

next_legacy_epic_archive_dir() {
  local legacy_root archive_kind epic_name archive_base archive_dir suffix
  legacy_root="$1"
  archive_kind="$2"
  epic_name="$3"
  archive_base="$legacy_root/.archived/$archive_kind/$epic_name"
  archive_dir="$archive_base"
  suffix=2

  while [ -e "$archive_dir" ]; do
    archive_dir="${archive_base}-${suffix}"
    suffix=$((suffix + 1))
  done

  printf '%s\n' "$archive_dir"
}

quarantine_legacy_epic_conflict() {
  local src_dir legacy_root archive_kind message active_path detail archive_dir
  src_dir="$1"
  legacy_root="$2"
  archive_kind="$3"
  message="$4"
  active_path="$5"
  detail="${6:-}"
  archive_dir="$(next_legacy_epic_archive_dir "$legacy_root" "$archive_kind" "$(basename "$src_dir")")"

  if $APPLY; then
    mkdir -p "$(dirname "$archive_dir")"
    mv "$src_dir" "$archive_dir"
    printf 'QUARANTINED %s: %s -> %s (active epic at %s' "$message" "$src_dir" "$archive_dir" "$active_path"
  else
    printf 'WOULD QUARANTINE %s: %s -> %s (active epic at %s' "$message" "$src_dir" "$archive_dir" "$active_path"
  fi

  if [ -n "$detail" ]; then
    printf '; conflicting path %s' "$detail"
  fi
  printf ')\n'
}

required_dir_conflict() {
  local dir
  dir="$1"
  if [ -e "$dir" ] && [ ! -d "$dir" ]; then
    printf '%s\n' "$dir"
    return 0
  fi
  return 1
}

destination_file_conflict() {
  local src dest root current relative remainder ancestor_conflict
  src="$1"
  dest="$2"
  root="$3"

  current="$(dirname "$dest")"
  relative="${current#"$root"}"
  relative="${relative#/}"

  if [ -n "$relative" ]; then
    remainder="$root"
    IFS='/' read -r -a _ccpm_segments <<< "$relative"
    for _ccpm_segment in "${_ccpm_segments[@]}"; do
      remainder="$remainder/$_ccpm_segment"
      ancestor_conflict="$(required_dir_conflict "$remainder" || true)"
      if [ -n "$ancestor_conflict" ]; then
        printf '%s\n' "$ancestor_conflict"
        unset _ccpm_segments _ccpm_segment
        return 0
      fi
    done
    unset _ccpm_segments _ccpm_segment
  fi

  if [ -e "$dest" ]; then
    if [ ! -f "$dest" ] || ! cmp -s "$src" "$dest"; then
      printf '%s\n' "$dest"
      return 0
    fi
  fi

  return 1
}

mapped_destination_for_legacy_child() {
  local child target_epic_dir name relative_path
  child="$1"
  target_epic_dir="$2"
  name="$(basename "$child")"

  case "$name" in
    epic.md|github-mapping.md|execution-status.md)
      printf '%s\n' "$target_epic_dir/$name"
      ;;
    [0-9]*-analysis.md)
      printf '%s\n' "$target_epic_dir/$name"
      ;;
    *.md)
      ccpm_is_numeric_task_filename "$name" || return 1
      printf '%s\n' "$target_epic_dir/issues/$name"
      ;;
    updates)
      return 1
      ;;
    *)
      return 1
      ;;
  esac
}

unsupported_legacy_epic_entry() {
  local epic_dir entry name
  epic_dir="$1"

  while IFS= read -r -d '' entry; do
    name="$(basename "$entry")"
    if [ -d "$entry" ]; then
      [ "$name" = "updates" ] && continue
      printf '%s\n' "$entry"
      return 0
    fi

    case "$name" in
      epic.md|github-mapping.md|execution-status.md|[0-9]*-analysis.md)
        continue
        ;;
      *.md)
        ccpm_is_numeric_task_filename "$name" && continue
        printf '%s\n' "$entry"
        return 0
        ;;
      *)
        printf '%s\n' "$entry"
        return 0
        ;;
    esac
  done < <(find "$epic_dir" -mindepth 1 -maxdepth 1 -print0 2>/dev/null | sort -z)

  return 1
}

top_level_numeric_task_files() {
  local epic_dir
  epic_dir="$1"

  while IFS= read -r -d '' entry; do
    ccpm_is_numeric_task_filename "$(basename "$entry")" || continue
    printf '%s\n' "$entry"
  done < <(find "$epic_dir" -mindepth 1 -maxdepth 1 -type f -name '*.md' -print0 2>/dev/null | sort -z)
}

same_target_merge_conflict_path() {
  local epic_dir target_epic_dir child update_dir update_file relative_path target_path conflict_path first_child
  epic_dir="$1"
  target_epic_dir="$2"

  while IFS= read -r -d '' child; do
    target_path="$(mapped_destination_for_legacy_child "$child" "$target_epic_dir" || true)"
    [ -n "$target_path" ] || continue

    conflict_path="$(destination_file_conflict "$child" "$target_path" "$target_epic_dir" || true)"
    if [ -n "$conflict_path" ]; then
      printf '%s\n' "$conflict_path"
      return 0
    fi
  done < <(find "$epic_dir" -mindepth 1 -maxdepth 1 -type f -name '*.md' -print0 2>/dev/null | sort -z)

  if [ -d "$epic_dir/updates" ]; then
    while IFS= read -r -d '' update_dir; do
      first_child="$(find "$update_dir" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null || true)"
      [ -n "$first_child" ] || continue
      relative_path="${update_dir#$epic_dir/}"
      target_path="$target_epic_dir/$relative_path"
      conflict_path="$(required_dir_conflict "$target_path" || true)"
      if [ -n "$conflict_path" ]; then
        printf '%s\n' "$conflict_path"
        return 0
      fi
    done < <(find "$epic_dir/updates" -type d -print0 2>/dev/null | sort -z)

    while IFS= read -r -d '' update_file; do
      relative_path="${update_file#$epic_dir/}"
      target_path="$target_epic_dir/$relative_path"
      conflict_path="$(destination_file_conflict "$update_file" "$target_path" "$target_epic_dir" || true)"
      if [ -n "$conflict_path" ]; then
        printf '%s\n' "$conflict_path"
        return 0
      fi
    done < <(find "$epic_dir/updates" -type f -print0 2>/dev/null | sort -z)
  fi
}

MIGRATION_CLASSIFICATION=""
MIGRATION_DETAIL=""

classify_legacy_epic_migration() {
  local epic_dir target_epic_dir epic_name conflict_path unsupported_path
  epic_dir="$1"
  target_epic_dir="$2"
  epic_name="$(basename "$epic_dir")"

  MIGRATION_CLASSIFICATION="safe-merge"
  MIGRATION_DETAIL=""

  unsupported_path="$(unsupported_legacy_epic_entry "$epic_dir" || true)"
  if [ -n "$unsupported_path" ]; then
    MIGRATION_CLASSIFICATION="quarantine-unsupported-content"
    MIGRATION_DETAIL="$unsupported_path"
    return 0
  fi

  conflict_path="$(epic_name_conflict_exists "$epic_name" "$epic_dir" || true)"
  if [ -n "$conflict_path" ] && [ "$conflict_path" != "$target_epic_dir" ]; then
    MIGRATION_CLASSIFICATION="quarantine-duplicate-name"
    MIGRATION_DETAIL="$conflict_path"
    return 0
  fi

  if [ -d "$target_epic_dir" ]; then
    conflict_path="$(same_target_merge_conflict_path "$epic_dir" "$target_epic_dir" || true)"
    if [ -n "$conflict_path" ]; then
      MIGRATION_CLASSIFICATION="quarantine-same-target-conflict"
      MIGRATION_DETAIL="$conflict_path"
    fi
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
  local epic_dir child name issue_conflict

  [ -d "$PRD_DIR" ] || return 0

  while IFS= read -r -d '' epic_dir; do
    [ -f "$epic_dir/epic.md" ] || continue

    issue_conflict=""
    while IFS= read -r child; do
      name="$(basename "$child")"
      issue_conflict="$(destination_file_conflict "$child" "$epic_dir/issues/$name" "$epic_dir" || true)"
      if [ -n "$issue_conflict" ]; then
        printf 'ERROR nested normalization conflict: %s requires directory-compatible path for %s\n' "$epic_dir" "$issue_conflict" >&2
        return 1
      fi
    done < <(top_level_numeric_task_files "$epic_dir")

    while IFS= read -r child; do
      name="$(basename "$child")"
      ensure_dir "$epic_dir/issues"
      move_file_safe "$child" "$epic_dir/issues/$name"
    done < <(top_level_numeric_task_files "$epic_dir")
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
    classify_legacy_epic_migration "$epic_dir" "$target_epic_dir"
    case "$MIGRATION_CLASSIFICATION" in
      quarantine-duplicate-name)
        quarantine_legacy_epic_conflict "$epic_dir" "$legacy_epic_root" "duplicate-name-conflicts" "duplicate epic name" "$MIGRATION_DETAIL"
        continue
        ;;
      quarantine-same-target-conflict)
        quarantine_legacy_epic_conflict "$epic_dir" "$legacy_epic_root" "merge-conflicts" "same-target merge conflict" "$target_epic_dir" "$MIGRATION_DETAIL"
        continue
        ;;
      quarantine-unsupported-content)
        quarantine_legacy_epic_conflict "$epic_dir" "$legacy_epic_root" "merge-conflicts" "unsupported legacy content" "$target_epic_dir (planned target)" "$MIGRATION_DETAIL"
        continue
        ;;
    esac

    ensure_dir "$target_epic_dir"

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
          ensure_dir "$target_epic_dir/issues"
          move_file_safe "$child" "$target_epic_dir/issues/$name"
          ;;
      esac
    done < <(find "$epic_dir" -mindepth 1 -maxdepth 1 -print0 2>/dev/null | sort -z)

    cleanup_if_empty "$epic_dir"
  done < <(find "$legacy_epic_root" -mindepth 1 -maxdepth 1 -type d ! -name archived ! -name .archived -print0 2>/dev/null | sort -z)
done

if ! $APPLY; then
  echo ""
  echo "Run with --apply to perform the migration."
fi
