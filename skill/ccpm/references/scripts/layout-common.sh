#!/bin/bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ccpm_resolve_prd_dir() {
  "$SCRIPT_DIR/resolve-prd-dir.sh" "$@"
}

ccpm_resolve_prd_path() {
  "$SCRIPT_DIR/resolve-prd-path.sh" "$@"
}

ccpm_resolve_epic_dir() {
  "$SCRIPT_DIR/resolve-epic-dir.sh" "$@"
}

ccpm_resolve_issue_file() {
  "$SCRIPT_DIR/resolve-issue-file.sh" "$@"
}

ccpm_prd_name_from_path() {
  local prd_path
  prd_path="$1"
  if [ "$(basename "$prd_path")" = "prd.md" ]; then
    basename "$(dirname "$prd_path")"
  else
    basename "$prd_path" .md
  fi
}

ccpm_epic_name_from_dir() {
  basename "$1"
}

ccpm_epic_prd_name_from_dir() {
  local epic_dir
  epic_dir="$1"
  if [ "$(basename "$(dirname "$epic_dir")")" = "epics" ]; then
    basename "$(dirname "$(dirname "$epic_dir")")"
  else
    echo ""
  fi
}

ccpm_is_numeric_task_filename() {
  case "$1" in
    ''|*-analysis.md)
      return 1
      ;;
    *)
      [[ "$1" =~ ^[0-9]+\.md$ ]]
      ;;
  esac
}

ccpm_epic_is_archived() {
  case "$1" in
    */epics/.archived/*|.claude/epics/archived/*|.cursor/ccpm/epics/archived/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

ccpm_legacy_prd_roots() {
  [ -d ".claude/prds" ] && printf '%s\n' ".claude/prds"
  [ -d ".cursor/ccpm/prds" ] && printf '%s\n' ".cursor/ccpm/prds"
}

ccpm_legacy_epic_roots() {
  [ -d ".claude/epics" ] && printf '%s\n' ".claude/epics"
  [ -d ".cursor/ccpm/epics" ] && printf '%s\n' ".cursor/ccpm/epics"
}

ccpm_list_prd_files() {
  local prd_dir nested_dir nested_file flat_file prd_name legacy_root
  local seen=""

  prd_dir="$(ccpm_resolve_prd_dir --allow-missing 2>/dev/null)" || prd_dir=""
  if [ -n "$prd_dir" ] && [ -d "$prd_dir" ]; then
    while IFS= read -r -d '' nested_dir; do
      nested_file="$nested_dir/prd.md"
      [ -f "$nested_file" ] || continue
      prd_name="$(basename "$nested_dir")"
      seen="${seen}|${prd_name}|"
      printf '%s\n' "$nested_file"
    done < <(find "$prd_dir" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null | sort -z)

    while IFS= read -r -d '' flat_file; do
      prd_name="$(basename "$flat_file" .md)"
      case "$seen" in
        *"|$prd_name|"*) continue ;;
      esac
      seen="${seen}|${prd_name}|"
      printf '%s\n' "$flat_file"
    done < <(find "$prd_dir" -mindepth 1 -maxdepth 1 -type f -name '*.md' -print0 2>/dev/null | sort -z)
  fi

  while IFS= read -r legacy_root; do
    [ -n "$legacy_root" ] || continue
    while IFS= read -r -d '' flat_file; do
      prd_name="$(basename "$flat_file" .md)"
      case "$seen" in
        *"|$prd_name|"*) continue ;;
      esac
      seen="${seen}|${prd_name}|"
      printf '%s\n' "$flat_file"
    done < <(find "$legacy_root" -mindepth 1 -maxdepth 1 -type f -name '*.md' -print0 2>/dev/null | sort -z)
  done < <(ccpm_legacy_prd_roots)
}

ccpm_list_epic_dirs() {
  local prd_dir epic_dir legacy_dir legacy_root

  prd_dir="$(ccpm_resolve_prd_dir --allow-missing 2>/dev/null)" || prd_dir=""
  if [ -n "$prd_dir" ] && [ -d "$prd_dir" ]; then
    while IFS= read -r -d '' epic_dir; do
      [ -f "$epic_dir/epic.md" ] || continue
      ccpm_epic_is_archived "$epic_dir" && continue
      printf '%s\n' "$epic_dir"
    done < <(find "$prd_dir" -path '*/epics/*' -type d -print0 2>/dev/null | sort -z)
  fi

  while IFS= read -r legacy_root; do
    [ -n "$legacy_root" ] || continue
    while IFS= read -r -d '' legacy_dir; do
      [ -f "$legacy_dir/epic.md" ] || continue
      ccpm_epic_is_archived "$legacy_dir" && continue
      printf '%s\n' "$legacy_dir"
    done < <(find "$legacy_root" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null | sort -z)
  done < <(ccpm_legacy_epic_roots)
}

ccpm_list_task_files_for_epic() {
  local epic_dir task_root task_file
  epic_dir="$1"
  if [ -d "$epic_dir/issues" ]; then
    task_root="$epic_dir/issues"
  else
    task_root="$epic_dir"
  fi

  while IFS= read -r -d '' task_file; do
    ccpm_is_numeric_task_filename "$(basename "$task_file")" || continue
    printf '%s\n' "$task_file"
  done < <(find "$task_root" -mindepth 1 -maxdepth 1 -type f -name '*.md' -print0 2>/dev/null | sort -z)
}

ccpm_list_task_files() {
  local epic_dir
  while IFS= read -r epic_dir; do
    [ -n "$epic_dir" ] || continue
    ccpm_list_task_files_for_epic "$epic_dir"
  done < <(ccpm_list_epic_dirs)
}

ccpm_epic_dir_from_task_file() {
  local task_file
  task_file="$1"
  if [ "$(basename "$(dirname "$task_file")")" = "issues" ]; then
    dirname "$(dirname "$task_file")"
  else
    dirname "$task_file"
  fi
}

ccpm_task_file_for_epic_issue() {
  local epic_dir issue_num
  epic_dir="$1"
  issue_num="$2"
  if [ -f "$epic_dir/issues/$issue_num.md" ]; then
    printf '%s\n' "$epic_dir/issues/$issue_num.md"
    return 0
  fi
  if [ -f "$epic_dir/$issue_num.md" ]; then
    printf '%s\n' "$epic_dir/$issue_num.md"
    return 0
  fi
  return 1
}

ccpm_updates_dir_for_issue() {
  local issue_file epic_dir issue_num
  issue_num="$1"
  issue_file="$(ccpm_resolve_issue_file "$issue_num" 2>/dev/null)" || return 1
  epic_dir="$(ccpm_epic_dir_from_task_file "$issue_file")"
  printf '%s\n' "$epic_dir/updates/$issue_num"
}

ccpm_recent_activity_roots() {
  local prd_dir legacy_root
  prd_dir="$(ccpm_resolve_prd_dir --allow-missing 2>/dev/null)" || prd_dir=""
  [ -n "$prd_dir" ] && [ -d "$prd_dir" ] && printf '%s\n' "$prd_dir"
  while IFS= read -r legacy_root; do
    [ -n "$legacy_root" ] || continue
    printf '%s\n' "$legacy_root"
  done < <(ccpm_legacy_prd_roots)
  while IFS= read -r legacy_root; do
    [ -n "$legacy_root" ] || continue
    printf '%s\n' "$legacy_root"
  done < <(ccpm_legacy_epic_roots)
}
