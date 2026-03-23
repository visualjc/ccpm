#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/layout-common.sh"

echo "📅 Daily Standup - $(date '+%Y-%m-%d')"
echo "================================"
echo ""

today=$(date '+%Y-%m-%d')

echo "Getting status..."
echo ""
echo ""

echo "📝 Today's Activity:"
echo "===================="
echo ""

# Find files modified today
recent_files=$(
  {
    ccpm_recent_activity_roots | while IFS= read -r root; do
      find "$root" -name "*.md" -mtime -1 2>/dev/null
    done
  } | sort -u
)

if [ -n "$recent_files" ]; then
  # Count by type
  prd_count=$(echo "$recent_files" | grep -c "/prds/" 2>/dev/null | tr -d '[:space:]')
  epic_count=$(echo "$recent_files" | grep -c "/epic.md" 2>/dev/null | tr -d '[:space:]')
  task_count=$(echo "$recent_files" | grep -c "/[0-9]*.md" 2>/dev/null | tr -d '[:space:]')
  update_count=$(echo "$recent_files" | grep -c "/updates/" 2>/dev/null | tr -d '[:space:]')
  prd_count=${prd_count:-0}; epic_count=${epic_count:-0}; task_count=${task_count:-0}; update_count=${update_count:-0}

  [ "$prd_count" -gt 0 ] && echo "  • Modified $prd_count PRD(s)"
  [ "$epic_count" -gt 0 ] && echo "  • Updated $epic_count epic(s)"
  [ "$task_count" -gt 0 ] && echo "  • Worked on $task_count task(s)"
  [ "$update_count" -gt 0 ] && echo "  • Posted $update_count progress update(s)"
else
  echo "  No activity recorded today"
fi

echo ""
echo "🔄 Currently In Progress:"
# Show active work items
while IFS= read -r epic_dir; do
  [ -n "$epic_dir" ] || continue
  while IFS= read -r updates_dir; do
    [ -d "$updates_dir" ] || continue
    if [ -f "$updates_dir/progress.md" ]; then
      issue_num=$(basename "$updates_dir")
      epic_name=$(basename "$epic_dir")
      completion=$(grep "^completion:" "$updates_dir/progress.md" | head -1 | sed 's/^completion: *//')
      echo "  • Issue #$issue_num ($epic_name) - ${completion:-0%} complete"
    fi
  done < <(find "$epic_dir/updates" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)
done < <(ccpm_list_epic_dirs)

echo ""
echo "⏭️ Next Available Tasks:"
# Show top 3 available tasks
count=0
while IFS= read -r epic_dir; do
  [ -n "$epic_dir" ] || continue
  while IFS= read -r task_file; do
    status=$(grep "^status:" "$task_file" | head -1 | sed 's/^status: *//')
    if [ "$status" != "open" ] && [ -n "$status" ]; then
      continue
    fi

    deps_line=$(grep "^depends_on:" "$task_file" | head -1)
    if [ -n "$deps_line" ]; then
      deps=$(echo "$deps_line" | sed 's/^depends_on: *//' | sed 's/^\[//' | sed 's/\]$//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
      [ -z "$deps" ] && deps=""
    else
      deps=""
    fi
    ready=true
    if [ -n "$deps" ] && [ "$deps" != "depends_on:" ]; then
      for dep in $(echo "$deps" | sed 's/,/ /g'); do
        dep_file="$(ccpm_task_file_for_epic_issue "$epic_dir" "$dep" 2>/dev/null || true)"
        if [ ! -f "$dep_file" ]; then
          ready=false
          break
        fi
        dep_status=$(grep "^status:" "$dep_file" | head -1 | sed 's/^status: *//')
        if [ "$dep_status" != "closed" ] && [ "$dep_status" != "completed" ]; then
          ready=false
          break
        fi
      done
    fi
    if $ready; then
      task_name=$(grep "^name:" "$task_file" | head -1 | sed 's/^name: *//')
      task_num=$(basename "$task_file" .md)
      echo "  • #$task_num - $task_name"
      ((count++))
      [ $count -ge 3 ] && break 2
    fi
  done < <(ccpm_list_task_files_for_epic "$epic_dir")
done < <(ccpm_list_epic_dirs)

echo ""
echo "📊 Quick Stats:"
total_tasks=$(ccpm_list_task_files | wc -l | tr -d '[:space:]')
open_tasks=$(ccpm_list_task_files | xargs grep -l "^status: *open" 2>/dev/null | wc -l | tr -d '[:space:]')
closed_tasks=$(ccpm_list_task_files | xargs grep -l "^status: *closed" 2>/dev/null | wc -l | tr -d '[:space:]')
echo "  Tasks: $open_tasks open, $closed_tasks closed, $total_tasks total"

exit 0
