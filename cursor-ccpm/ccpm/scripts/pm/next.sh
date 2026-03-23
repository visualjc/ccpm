#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/layout-common.sh"

echo "Getting status..."
echo ""
echo ""

echo "📋 Next Available Tasks"
echo "======================="
echo ""

# Find tasks that are open and have no dependencies or whose dependencies are closed
found=0

while IFS= read -r epic_dir; do
  [ -n "$epic_dir" ] || continue
  epic_name=$(basename "$epic_dir")

  while IFS= read -r task_file; do
    # Check if task is open
    status=$(grep "^status:" "$task_file" | head -1 | sed 's/^status: *//')
    if [ "$status" != "open" ] && [ -n "$status" ]; then
      continue
    fi

    # Check dependencies
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
      parallel=$(grep "^parallel:" "$task_file" | head -1 | sed 's/^parallel: *//')

      echo "✅ Ready: #$task_num - $task_name"
      echo "   Epic: $epic_name"
      [ "$parallel" = "true" ] && echo "   🔄 Can run in parallel"
      echo ""
      ((found++))
    fi
  done < <(ccpm_list_task_files_for_epic "$epic_dir")
done < <(ccpm_list_epic_dirs)

if [ $found -eq 0 ]; then
  echo "No available tasks found."
  echo ""
  echo "💡 Suggestions:"
  echo "  • Ask CCPM what is blocked"
  echo "  • Ask CCPM to list epics"
fi

echo ""
echo "📊 Summary: $found tasks ready to start"

exit 0
