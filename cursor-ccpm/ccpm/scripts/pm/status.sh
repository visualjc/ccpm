#!/bin/bash

echo "Getting status..."
echo ""
echo ""


echo "📊 Project Status"
echo "================"
echo ""

echo "📄 PRDs:"
if [ -d ".cursor/ccpm/prds" ]; then
  total=$(ls .cursor/ccpm/prds/*.md 2>/dev/null | wc -l)
  echo "  Total: $total"
else
  echo "  No PRDs found"
fi

echo ""
echo "📚 Epics:"
if [ -d ".cursor/ccpm/epics" ]; then
  total=$(ls -d .cursor/ccpm/epics/*/ 2>/dev/null | wc -l)
  echo "  Total: $total"
else
  echo "  No epics found"
fi

echo ""
echo "📝 Tasks:"
if [ -d ".cursor/ccpm/epics" ]; then
  total=$(find .cursor/ccpm/epics -name "*.md" 2>/dev/null | grep -Ec '/[0-9]+\.md$' || true)
  open=$(find .cursor/ccpm/epics -name "*.md" -exec grep -l "^status: *open" {} \; 2>/dev/null | grep -Ec '/[0-9]+\.md$' || true)
  closed=$(find .cursor/ccpm/epics -name "*.md" -exec grep -l "^status: *closed" {} \; 2>/dev/null | grep -Ec '/[0-9]+\.md$' || true)
  echo "  Open: $open"
  echo "  Closed: $closed"
  echo "  Total: $total"
else
  echo "  No tasks found"
fi

exit 0
