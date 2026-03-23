#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/layout-common.sh"

echo "📄 PRD Status Report"
echo "===================="
echo ""

PRD_DIR="$(ccpm_resolve_prd_dir --allow-missing 2>/dev/null || true)"

total=$(ccpm_list_prd_files | wc -l | tr -d '[:space:]')
[ $total -eq 0 ] && echo "No PRDs found." && exit 0

# Count by status
backlog=0
in_progress=0
implemented=0

while IFS= read -r file; do
  [ -n "$file" ] || continue
  status=$(grep "^status:" "$file" | head -1 | sed 's/^status: *//')

  case "$status" in
    backlog|draft|"") ((backlog++)) ;;
    in-progress|active) ((in_progress++)) ;;
    implemented|completed|done) ((implemented++)) ;;
    *) ((backlog++)) ;;
  esac
done < <(ccpm_list_prd_files)

echo "Getting status..."
echo ""
echo ""

# Display chart
echo "📊 Distribution:"
echo "================"

echo ""
echo "  Backlog:     $(printf '%-3d' $backlog) [$(printf '%0.s█' $(seq 1 $((backlog*20/total))))]"
echo "  In Progress: $(printf '%-3d' $in_progress) [$(printf '%0.s█' $(seq 1 $((in_progress*20/total))))]"
echo "  Implemented: $(printf '%-3d' $implemented) [$(printf '%0.s█' $(seq 1 $((implemented*20/total))))]"
echo ""
echo "  Total PRDs: $total"

# Recent activity
echo ""
echo "📅 Recent PRDs (last 5 modified):"
ccpm_list_prd_files | xargs ls -t 2>/dev/null | head -5 | while read -r file; do
  name=$(grep "^name:" "$file" | head -1 | sed 's/^name: *//')
  [ -z "$name" ] && name=$(ccpm_prd_name_from_path "$file")
  echo "  • $name"
done

# Suggestions
echo ""
echo "💡 Next Actions:"
[ $backlog -gt 0 ] && echo "  • Ask CCPM to parse a backlog PRD into an epic"
[ $in_progress -gt 0 ] && echo "  • Ask CCPM for the status of an active epic"
[ $total -eq 0 ] && echo "  • Ask CCPM: I want to build <feature-name>"

exit 0
