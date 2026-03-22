#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/layout-common.sh"

echo "Getting status..."
echo ""
echo ""

epic_name="$1"

if [ -z "$epic_name" ]; then
  echo "❌ Please specify an epic name"
  echo "Usage: bash <installed_skill_dir>/references/scripts/epic-status.sh <epic-name>"
  echo ""
  echo "Available epics:"
  ccpm_list_epic_dirs | while IFS= read -r dir; do
    [ -n "$dir" ] && echo "  • $(basename "$dir")"
  done
  exit 1
else
  # Show status for specific epic
  epic_dir="$(ccpm_resolve_epic_dir "$epic_name" 2>/dev/null || true)"
  epic_file="$epic_dir/epic.md"

  if [ ! -f "$epic_file" ]; then
    echo "❌ Epic not found: $epic_name"
    echo ""
    echo "Available epics:"
    ccpm_list_epic_dirs | while IFS= read -r dir; do
      [ -n "$dir" ] && echo "  • $(basename "$dir")"
    done
    exit 1
  fi

  echo "📚 Epic Status: $epic_name"
  echo "================================"
  echo ""

  # Extract metadata
  status=$(grep "^status:" "$epic_file" | head -1 | sed 's/^status: *//')
  progress=$(grep "^progress:" "$epic_file" | head -1 | sed 's/^progress: *//')
  github=$(grep "^github:" "$epic_file" | head -1 | sed 's/^github: *//')

  # Count tasks
  total=0
  open=0
  closed=0
  blocked=0

  # Use find to safely iterate over task files
  while IFS= read -r task_file; do
    ((total++))

    task_status=$(grep "^status:" "$task_file" | head -1 | sed 's/^status: *//')
    deps=$(grep "^depends_on:" "$task_file" | head -1 | sed 's/^depends_on: *\[//' | sed 's/\]//')

    if [ "$task_status" = "closed" ] || [ "$task_status" = "completed" ]; then
      ((closed++))
    elif [ -n "$deps" ] && [ "$deps" != "depends_on:" ]; then
      blocked_task=false
      for dep in $(echo "$deps" | sed 's/,/ /g'); do
        dep_file="$(ccpm_task_file_for_epic_issue "$epic_dir" "$dep" 2>/dev/null || true)"
        if [ -f "$dep_file" ]; then
          dep_status=$(grep "^status:" "$dep_file" | head -1 | sed 's/^status: *//')
          if [ "$dep_status" != "closed" ] && [ "$dep_status" != "completed" ]; then
            blocked_task=true
          fi
        fi
      done
      if $blocked_task; then
        ((blocked++))
      else
        ((open++))
      fi
    else
      ((open++))
    fi
  done < <(ccpm_list_task_files_for_epic "$epic_dir")

  # Display progress bar
  if [ $total -gt 0 ]; then
    percent=$((closed * 100 / total))
    filled=$((percent * 20 / 100))
    empty=$((20 - filled))

    echo -n "Progress: ["
    [ $filled -gt 0 ] && printf '%0.s█' $(seq 1 $filled)
    [ $empty -gt 0 ] && printf '%0.s░' $(seq 1 $empty)
    echo "] $percent%"
  else
    echo "Progress: No tasks created"
  fi

  echo ""
  echo "📊 Breakdown:"
  echo "  Total tasks: $total"
  echo "  ✅ Completed: $closed"
  echo "  🔄 Available: $open"
  echo "  ⏸️ Blocked: $blocked"

  [ -n "$github" ] && echo ""
  [ -n "$github" ] && echo "🔗 GitHub: $github"
fi

exit 0
