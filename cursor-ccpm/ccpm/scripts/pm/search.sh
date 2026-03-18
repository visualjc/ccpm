#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

query="$1"

if [ -z "$query" ]; then
  echo "❌ Please provide a search query"
  echo "Usage: /pm:search <query>"
  exit 1
fi

echo "Searching for '$query'..."
echo ""
echo ""

echo "🔍 Search results for: '$query'"
echo "================================"
echo ""

# Search in PRDs
PRD_DIR=$("$SCRIPT_DIR/resolve-prd-dir.sh" 2>/dev/null)
if [ -n "$PRD_DIR" ] && [ -d "$PRD_DIR" ]; then
  echo "📄 PRDs:"
  results=$(grep -l -i "$query" "$PRD_DIR"/*.md 2>/dev/null)
  if [ -n "$results" ]; then
    for file in $results; do
      name=$(basename "$file" .md)
      matches=$(grep -c -i "$query" "$file")
      echo "  • $name ($matches matches)"
    done
  else
    echo "  No matches"
  fi
  echo ""
fi

# Search in Epics
if [ -d ".cursor/ccpm/epics" ]; then
  echo "📚 Epics:"
  results=$(find .cursor/ccpm/epics -name "epic.md" -exec grep -l -i "$query" {} \; 2>/dev/null)
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
if [ -d ".cursor/ccpm/epics" ]; then
  echo "📝 Tasks:"
  results=$(find .cursor/ccpm/epics -name "*.md" -exec grep -l -i "$query" {} \; 2>/dev/null | grep -E '/[0-9]+\.md$' | head -10)
  if [ -n "$results" ]; then
    for file in $results; do
      epic_name=$(basename $(dirname "$file"))
      task_num=$(basename "$file" .md)
      echo "  • Task #$task_num in $epic_name"
    done
  else
    echo "  No matches"
  fi
fi

# Summary
total=$(find .cursor/ccpm -name "*.md" -exec grep -l -i "$query" {} \; 2>/dev/null | wc -l)
echo ""
echo "📊 Total files with matches: $total"

exit 0
