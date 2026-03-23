#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/layout-common.sh"

PRD_DIR="$(ccpm_resolve_prd_dir --allow-missing 2>/dev/null || true)"

if [ -z "$(ccpm_list_prd_files)" ]; then
  echo "📁 No PRDs found. Ask CCPM: I want to build <feature-name>"
  exit 0
fi

# Initialize counters
backlog_count=0
in_progress_count=0
implemented_count=0
total_count=0

echo "Getting PRDs..."
echo ""
echo ""


echo "📋 PRD List"
echo "==========="
echo ""

# Display by status groups
echo "🔍 Backlog PRDs:"
while IFS= read -r file; do
  [ -n "$file" ] || continue
  status=$(grep "^status:" "$file" | head -1 | sed 's/^status: *//')
  if [ "$status" = "backlog" ] || [ "$status" = "draft" ] || [ -z "$status" ]; then
    name=$(grep "^name:" "$file" | head -1 | sed 's/^name: *//')
    desc=$(grep "^description:" "$file" | head -1 | sed 's/^description: *//')
    [ -z "$name" ] && name=$(ccpm_prd_name_from_path "$file")
    [ -z "$desc" ] && desc="No description"
    echo "   📋 $file - $desc"
    ((backlog_count++))
  fi
  ((total_count++))
done < <(ccpm_list_prd_files)
[ $backlog_count -eq 0 ] && echo "   (none)"

echo ""
echo "🔄 In-Progress PRDs:"
while IFS= read -r file; do
  [ -n "$file" ] || continue
  status=$(grep "^status:" "$file" | head -1 | sed 's/^status: *//')
  if [ "$status" = "in-progress" ] || [ "$status" = "active" ]; then
    name=$(grep "^name:" "$file" | head -1 | sed 's/^name: *//')
    desc=$(grep "^description:" "$file" | head -1 | sed 's/^description: *//')
    [ -z "$name" ] && name=$(ccpm_prd_name_from_path "$file")
    [ -z "$desc" ] && desc="No description"
    echo "   📋 $file - $desc"
    ((in_progress_count++))
  fi
done < <(ccpm_list_prd_files)
[ $in_progress_count -eq 0 ] && echo "   (none)"

echo ""
echo "✅ Implemented PRDs:"
while IFS= read -r file; do
  [ -n "$file" ] || continue
  status=$(grep "^status:" "$file" | head -1 | sed 's/^status: *//')
  if [ "$status" = "implemented" ] || [ "$status" = "completed" ] || [ "$status" = "done" ]; then
    name=$(grep "^name:" "$file" | head -1 | sed 's/^name: *//')
    desc=$(grep "^description:" "$file" | head -1 | sed 's/^description: *//')
    [ -z "$name" ] && name=$(ccpm_prd_name_from_path "$file")
    [ -z "$desc" ] && desc="No description"
    echo "   📋 $file - $desc"
    ((implemented_count++))
  fi
done < <(ccpm_list_prd_files)
[ $implemented_count -eq 0 ] && echo "   (none)"

# Display summary
echo ""
echo "📊 PRD Summary"
echo "   Total PRDs: $total_count"
echo "   Backlog: $backlog_count"
echo "   In-Progress: $in_progress_count"
echo "   Implemented: $implemented_count"

exit 0
