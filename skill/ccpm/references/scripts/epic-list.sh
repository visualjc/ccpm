#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/layout-common.sh"

echo "Getting epics..."
echo ""
echo ""

if [ -z "$(ccpm_list_epic_dirs)" ]; then
  echo "📁 No epics found. Ask CCPM: parse the <feature-name> PRD"
  exit 0
fi

echo "📚 Project Epics"
echo "================"
echo ""

# Initialize arrays to store epics by status
planning_epics=""
in_progress_epics=""
completed_epics=""

# Process all epics
while IFS= read -r dir; do
  [ -n "$dir" ] || continue
  [ -f "$dir/epic.md" ] || continue

  # Extract metadata
  n=$(grep "^name:" "$dir/epic.md" | head -1 | sed 's/^name: *//')
  s=$(grep "^status:" "$dir/epic.md" | head -1 | sed 's/^status: *//' | tr '[:upper:]' '[:lower:]')
  p=$(grep "^progress:" "$dir/epic.md" | head -1 | sed 's/^progress: *//')
  g=$(grep "^github:" "$dir/epic.md" | head -1 | sed 's/^github: *//')

  # Defaults
  [ -z "$n" ] && n=$(basename "$dir")
  [ -z "$p" ] && p="0%"

  # Count tasks
  t=$(ccpm_list_task_files_for_epic "$dir" | wc -l | tr -d '[:space:]')

  # Format output with GitHub issue number if available
  if [ -n "$g" ]; then
    i=$(echo "$g" | grep -o '/[0-9]*$' | tr -d '/')
    entry="   📋 ${dir}/epic.md (#$i) - $p complete ($t tasks)"
  else
    entry="   📋 ${dir}/epic.md - $p complete ($t tasks)"
  fi

  # Categorize by status (handle various status values)
  case "$s" in
    planning|draft|"")
      planning_epics="${planning_epics}${entry}\n"
      ;;
    in-progress|in_progress|active|started)
      in_progress_epics="${in_progress_epics}${entry}\n"
      ;;
    completed|complete|done|closed|finished)
      completed_epics="${completed_epics}${entry}\n"
      ;;
    *)
      # Default to planning for unknown statuses
      planning_epics="${planning_epics}${entry}\n"
      ;;
  esac
done < <(ccpm_list_epic_dirs)

# Display categorized epics
echo "📝 Planning:"
if [ -n "$planning_epics" ]; then
  echo -e "$planning_epics" | sed '/^$/d'
else
  echo "   (none)"
fi

echo ""
echo "🚀 In Progress:"
if [ -n "$in_progress_epics" ]; then
  echo -e "$in_progress_epics" | sed '/^$/d'
else
  echo "   (none)"
fi

echo ""
echo "✅ Completed:"
if [ -n "$completed_epics" ]; then
  echo -e "$completed_epics" | sed '/^$/d'
else
  echo "   (none)"
fi

# Summary
echo ""
echo "📊 Summary"
total=$(ccpm_list_epic_dirs | wc -l | tr -d '[:space:]')
tasks=$(ccpm_list_task_files | wc -l | tr -d '[:space:]')
echo "   Total epics: $total"
echo "   Total tasks: $tasks"

exit 0
