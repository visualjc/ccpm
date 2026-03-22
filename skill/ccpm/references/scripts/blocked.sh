#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/layout-common.sh"

echo "Getting tasks..."
echo ""
echo ""

echo "🚫 Blocked Tasks"
echo "================"
echo ""

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

    # Check for dependencies
    deps_line=$(grep "^depends_on:" "$task_file" | head -1)
    if [ -n "$deps_line" ]; then
      deps=$(echo "$deps_line" | sed 's/^depends_on: *//' | sed 's/^\[//' | sed 's/\]$//' | sed 's/,/ /g' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
      [ -z "$deps" ] && deps=""
    else
      deps=""
    fi

    if [ -n "$deps" ] && [ "$deps" != "depends_on:" ]; then
      task_name=$(grep "^name:" "$task_file" | head -1 | sed 's/^name: *//')
      task_num=$(basename "$task_file" .md)

      echo "⏸️ Task #$task_num - $task_name"
      echo "   Epic: $epic_name"
      echo "   Blocked by: [$deps]"

      # Check status of dependencies
      open_deps=""
      for dep in $deps; do
        dep_file="$(ccpm_task_file_for_epic_issue "$epic_dir" "$dep" 2>/dev/null || true)"
        if [ -f "$dep_file" ]; then
          dep_status=$(grep "^status:" "$dep_file" | head -1 | sed 's/^status: *//')
          if [ "$dep_status" != "closed" ] && [ "$dep_status" != "completed" ]; then
            open_deps="$open_deps #$dep"
          fi
        fi
      done

      if [ -n "$open_deps" ]; then
        echo "   Waiting for:$open_deps"
        echo ""
        ((found++))
      fi
    fi
  done < <(ccpm_list_task_files_for_epic "$epic_dir")
done < <(ccpm_list_epic_dirs)

if [ $found -eq 0 ]; then
  echo "No blocked tasks found!"
  echo ""
  echo "💡 All tasks with dependencies are either completed or in progress."
else
  echo "📊 Total blocked: $found tasks"
fi

exit 0
