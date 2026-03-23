#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/layout-common.sh"

echo "Getting status..."
echo ""
echo ""


echo "📊 Project Status"
echo "================"
echo ""

echo "📄 PRDs:"
if [ -n "$(ccpm_list_prd_files)" ]; then
  total=$(ccpm_list_prd_files | wc -l | tr -d '[:space:]')
  echo "  Total: $total"
else
  echo "  No PRDs found"
fi

echo ""
echo "📚 Epics:"
if [ -n "$(ccpm_list_epic_dirs)" ]; then
  total=$(ccpm_list_epic_dirs | wc -l | tr -d '[:space:]')
  echo "  Total: $total"
else
  echo "  No epics found"
fi

echo ""
echo "📝 Tasks:"
if [ -n "$(ccpm_list_task_files)" ]; then
  total=$(ccpm_list_task_files | wc -l | tr -d '[:space:]')
  open=$(ccpm_list_task_files | xargs grep -l "^status: *open" 2>/dev/null | wc -l | tr -d '[:space:]')
  closed=$(ccpm_list_task_files | xargs grep -l "^status: *closed" 2>/dev/null | wc -l | tr -d '[:space:]')
  echo "  Open: $open"
  echo "  Closed: $closed"
  echo "  Total: $total"
else
  echo "  No tasks found"
fi

exit 0
