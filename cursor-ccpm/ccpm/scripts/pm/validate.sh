#!/bin/bash

echo "Validating PM System..."
echo ""
echo ""

echo "🔍 Validating PM System"
echo "======================="
echo ""

errors=0
warnings=0

CCPM_ROOT=".cursor/ccpm"
PRD_DIR="$CCPM_ROOT/prds"
EPIC_DIR="$CCPM_ROOT/epics"
RULES_DIR="$CCPM_ROOT/rules"

# Check directory structure
echo "📁 Directory Structure:"
[ -d "$CCPM_ROOT" ] && echo "  ✅ .cursor/ccpm directory exists" || { echo "  ❌ .cursor/ccpm directory missing"; ((errors++)); }
[ -d "$PRD_DIR" ] && echo "  ✅ PRDs directory exists" || echo "  ⚠️ PRDs directory missing"
[ -d "$EPIC_DIR" ] && echo "  ✅ Epics directory exists" || echo "  ⚠️ Epics directory missing"
[ -d "$RULES_DIR" ] && echo "  ✅ Rules directory exists" || echo "  ⚠️ Rules directory missing"
echo ""

# Check for orphaned files
echo "🗂️ Data Integrity:"

# Check epics have epic.md files
for epic_dir in .cursor/ccpm/epics/*/; do
  [ -d "$epic_dir" ] || continue
  if [ ! -f "$epic_dir/epic.md" ]; then
    echo "  ⚠️ Missing epic.md in $(basename "$epic_dir")"
    ((warnings++))
  fi
done

# Check for tasks without epics
orphaned=$(find "$CCPM_ROOT" -name "[0-9]*.md" -not -path "$EPIC_DIR/*/*" 2>/dev/null | wc -l)
[ $orphaned -gt 0 ] && echo "  ⚠️ Found $orphaned orphaned task files" && ((warnings++))

# Check for broken references
echo ""
echo "🔗 Reference Check:"

for task_file in .cursor/ccpm/epics/*/[0-9]*.md; do
  [ -f "$task_file" ] || continue
  task_num=$(basename "$task_file" .md)
  [[ "$task_num" =~ ^[0-9]+$ ]] || continue

  # Extract dependencies from task file
  deps_line=$(grep "^depends_on:" "$task_file" | head -1)
  if [ -n "$deps_line" ]; then
    deps=$(echo "$deps_line" | sed 's/^depends_on: *//')
    deps=$(echo "$deps" | sed 's/^\[//' | sed 's/\]$//')
    deps=$(echo "$deps" | sed 's/,/ /g')
    # Trim whitespace and handle empty cases
    deps=$(echo "$deps" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
    [ -z "$deps" ] && deps=""
  else
    deps=""
  fi
  if [ -n "$deps" ] && [ "$deps" != "depends_on:" ]; then
    epic_dir=$(dirname "$task_file")
    for dep in $deps; do
      if [ ! -f "$epic_dir/$dep.md" ]; then
        echo "  ⚠️ Task $(basename "$task_file" .md) references missing task: $dep"
        ((warnings++))
      fi
    done
  fi
done

if [ $warnings -eq 0 ] && [ $errors -eq 0 ]; then
  echo "  ✅ All references valid"
fi

# Check frontmatter
echo ""
echo "📝 Frontmatter Validation:"
invalid=0

for file in $(find "$CCPM_ROOT" \( -path "$EPIC_DIR/*" -o -path "$PRD_DIR/*" \) -name "*.md" 2>/dev/null); do
  [ "$(basename "$file")" = "github-mapping.md" ] && continue
  if ! grep -q "^---" "$file"; then
    echo "  ⚠️ Missing frontmatter: $(basename "$file")"
    ((invalid++))
  fi
done

[ $invalid -eq 0 ] && echo "  ✅ All files have frontmatter"

# Summary
echo ""
echo "📊 Validation Summary:"
echo "  Errors: $errors"
echo "  Warnings: $warnings"
echo "  Invalid files: $invalid"

if [ $errors -eq 0 ] && [ $warnings -eq 0 ] && [ $invalid -eq 0 ]; then
  echo ""
  echo "✅ System is healthy!"
else
  echo ""
  echo "💡 Run /pm:clean to fix some issues automatically"
fi

exit 0
