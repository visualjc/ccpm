#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/layout-common.sh"

query="$1"

if [ -z "$query" ]; then
  echo "❌ Please provide a search query"
  echo "Usage: bash <installed_skill_dir>/references/scripts/search.sh <query>"
  exit 1
fi

echo "Searching for '$query'..."
echo ""
echo ""

echo "🔍 Search results for: '$query'"
echo "================================"
echo ""

# Search in PRDs
if [ -n "$(ccpm_list_prd_files)" ]; then
  echo "📄 PRDs:"
  results="$(ccpm_list_prd_files | xargs grep -l -i "$query" 2>/dev/null || true)"
  if [ -n "$results" ]; then
    for file in $results; do
      name=$(ccpm_prd_name_from_path "$file")
      matches=$(grep -c -i "$query" "$file")
      echo "  • $name ($matches matches)"
    done
  else
    echo "  No matches"
  fi
  echo ""
fi

# Search in Epics
if [ -n "$(ccpm_list_epic_dirs)" ]; then
  echo "📚 Epics:"
  results=$(ccpm_list_epic_dirs | while IFS= read -r dir; do grep -l -i "$query" "$dir/epic.md" 2>/dev/null || true; done)
  if [ -n "$results" ]; then
    for file in $results; do
      epic_name=$(basename $(dirname "$file"))
      matches=$(grep -c -i "$query" "$file")
      echo "  • $epic_name ($matches matches)"
    done
  else
    echo "  No matches"
  fi
  echo ""
fi

# Search in Tasks
if [ -n "$(ccpm_list_task_files)" ]; then
  echo "📝 Tasks:"
  results=$(ccpm_list_task_files | xargs grep -l -i "$query" 2>/dev/null | head -10 || true)
  if [ -n "$results" ]; then
    for file in $results; do
      epic_name=$(basename "$(ccpm_epic_dir_from_task_file "$file")")
      task_num=$(basename "$file" .md)
      echo "  • Task #$task_num in $epic_name"
    done
  else
    echo "  No matches"
  fi
fi

# Summary
total=$(
  {
    ccpm_list_prd_files
    ccpm_list_epic_dirs | while IFS= read -r dir; do printf '%s\n' "$dir/epic.md"; done
    ccpm_list_task_files
  } | xargs grep -l -i "$query" 2>/dev/null | wc -l | tr -d '[:space:]'
)
echo ""
echo "📊 Total files with matches: $total"

exit 0
