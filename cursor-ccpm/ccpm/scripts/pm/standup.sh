#!/bin/bash

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
recent_files=$(find .cursor/ccpm -name "*.md" -mtime -1 2>/dev/null)

count_matches() {
  local pattern="$1"
  printf '%s\n' "$recent_files" | grep -Ec "$pattern" || true
}

if [ -n "$recent_files" ]; then
  # Count by type
  prd_count=$(count_matches "/prds/")
  epic_count=$(count_matches "/epic\\.md$")
  task_count=$(count_matches "/[0-9]+\\.md$")
  update_count=$(count_matches "/updates/")

  [ "${prd_count:-0}" -gt 0 ] && echo "  • Modified $prd_count PRD(s)"
  [ "${epic_count:-0}" -gt 0 ] && echo "  • Updated $epic_count epic(s)"
  [ "${task_count:-0}" -gt 0 ] && echo "  • Worked on $task_count task(s)"
  [ "${update_count:-0}" -gt 0 ] && echo "  • Posted $update_count progress update(s)"
else
  echo "  No activity recorded today"
fi

echo ""
echo "🔄 Currently In Progress:"
# Show active work items
for updates_dir in .cursor/ccpm/epics/*/updates/*/; do
  [ -d "$updates_dir" ] || continue
  if [ -f "$updates_dir/progress.md" ]; then
    issue_num=$(basename "$updates_dir")
    epic_name=$(basename $(dirname $(dirname "$updates_dir")))
    completion=$(grep "^completion:" "$updates_dir/progress.md" | head -1 | sed 's/^completion: *//')
    echo "  • Issue #$issue_num ($epic_name) - ${completion:-0%} complete"
  fi
done

echo ""
echo "⏭️ Next Available Tasks:"
# Show top 3 available tasks
count=0
for epic_dir in .cursor/ccpm/epics/*/; do
  [ -d "$epic_dir" ] || continue
  for task_file in "$epic_dir"/[0-9]*.md; do
    [ -f "$task_file" ] || continue
    task_num=$(basename "$task_file" .md)
    [[ "$task_num" =~ ^[0-9]+$ ]] || continue

    status=$(grep "^status:" "$task_file" | head -1 | sed 's/^status: *//')
    if [ "$status" != "open" ] && [ -n "$status" ]; then
      continue
    fi

    # Extract dependencies from task file
    deps_line=$(grep "^depends_on:" "$task_file" | head -1)
    if [ -n "$deps_line" ]; then
      deps=$(echo "$deps_line" | sed 's/^depends_on: *//')
      deps=$(echo "$deps" | sed 's/^\[//' | sed 's/\]$//')
      # Trim whitespace and handle empty cases
      deps=$(echo "$deps" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
      [ -z "$deps" ] && deps=""
    else
      deps=""
    fi
    if [ -z "$deps" ] || [ "$deps" = "depends_on:" ]; then
      task_name=$(grep "^name:" "$task_file" | head -1 | sed 's/^name: *//')
      [ -n "$task_name" ] || continue
      echo "  • #$task_num - $task_name"
      ((count++))
      [ $count -ge 3 ] && break 2
    fi
  done
done

echo ""
echo "📊 Quick Stats:"
total_tasks=$(find .cursor/ccpm/epics -name "*.md" 2>/dev/null | grep -Ec '/[0-9]+\.md$' || true)
open_tasks=$(find .cursor/ccpm/epics -name "*.md" -exec grep -l "^status: *open" {} \; 2>/dev/null | grep -Ec '/[0-9]+\.md$' || true)
closed_tasks=$(find .cursor/ccpm/epics -name "*.md" -exec grep -l "^status: *closed" {} \; 2>/dev/null | grep -Ec '/[0-9]+\.md$' || true)
echo "  Tasks: $open_tasks open, $closed_tasks closed, $total_tasks total"

exit 0
