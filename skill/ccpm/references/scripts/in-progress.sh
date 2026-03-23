#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/layout-common.sh"

echo "Getting status..."
echo ""
echo ""

echo "🔄 In Progress Work"
echo "==================="
echo ""

# Check for active work in updates directories
found=0

while IFS= read -r epic_dir; do
  [ -n "$epic_dir" ] || continue
  while IFS= read -r updates_dir; do
    [ -d "$updates_dir" ] || continue
    issue_num=$(basename "$updates_dir")
    epic_name=$(basename "$epic_dir")

    if [ -f "$updates_dir/progress.md" ]; then
      completion=$(grep "^completion:" "$updates_dir/progress.md" | head -1 | sed 's/^completion: *//')
      [ -z "$completion" ] && completion="0%"

      # Get task name from the task file
      task_file="$(ccpm_task_file_for_epic_issue "$epic_dir" "$issue_num" 2>/dev/null || true)"
      if [ -f "$task_file" ]; then
        task_name=$(grep "^name:" "$task_file" | head -1 | sed 's/^name: *//')
      else
        task_name="Unknown task"
      fi

      echo "📝 Issue #$issue_num - $task_name"
      echo "   Epic: $epic_name"
      echo "   Progress: $completion complete"

      # Check for recent updates
      if [ -f "$updates_dir/progress.md" ]; then
        last_update=$(grep "^last_sync:" "$updates_dir/progress.md" | head -1 | sed 's/^last_sync: *//')
        [ -n "$last_update" ] && echo "   Last update: $last_update"
      fi

      echo ""
      ((found++))
    fi
  done < <(find "$epic_dir/updates" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)
done < <(ccpm_list_epic_dirs)

# Also check for in-progress epics
echo "📚 Active Epics:"
while IFS= read -r epic_dir; do
  [ -n "$epic_dir" ] || continue
  [ -f "$epic_dir/epic.md" ] || continue

  status=$(grep "^status:" "$epic_dir/epic.md" | head -1 | sed 's/^status: *//')
  if [ "$status" = "in-progress" ] || [ "$status" = "active" ]; then
    epic_name=$(grep "^name:" "$epic_dir/epic.md" | head -1 | sed 's/^name: *//')
    progress=$(grep "^progress:" "$epic_dir/epic.md" | head -1 | sed 's/^progress: *//')
    [ -z "$epic_name" ] && epic_name=$(basename "$epic_dir")
    [ -z "$progress" ] && progress="0%"

    echo "   • $epic_name - $progress complete"
  fi
done < <(ccpm_list_epic_dirs)

echo ""
if [ $found -eq 0 ]; then
  echo "No active work items found."
  echo ""
  echo "💡 Ask CCPM: what should I work on next?"
else
echo "📊 Total active items: $found"
fi

exit 0
