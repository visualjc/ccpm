#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/layout-common.sh"

echo "Validating PM System..."
echo ""
echo ""

echo "🔍 Validating PM System"
echo "======================="
echo ""

errors=0
warnings=0

# Check directory structure
echo "📁 Directory Structure:"
[ -d ".claude" ] && echo "  ✅ .claude directory exists" || { echo "  ❌ .claude directory missing"; ((errors++)); }
PRD_DIR="$(ccpm_resolve_prd_dir --allow-missing 2>/dev/null || true)"
[ -n "$PRD_DIR" ] && [ -d "$PRD_DIR" ] && echo "  ✅ PRD directory exists: $PRD_DIR" || echo "  ⚠️ PRD directory missing"
[ -n "$(ccpm_list_epic_dirs)" ] && echo "  ✅ Epic directories found" || echo "  ⚠️ No epics found"
if [ -d ".claude/rules" ] || [ -d ".cursor/ccpm/rules" ]; then
  echo "  ✅ Rules directory exists"
else
  echo "  ⚠️ Rules directory missing"
fi
echo ""

# Check for orphaned files
echo "🗂️ Data Integrity:"

# Check epics have epic.md files
while IFS= read -r epic_dir; do
  [ -n "$epic_dir" ] || continue
  if [ ! -f "$epic_dir/epic.md" ]; then
    echo "  ⚠️ Missing epic.md in $(basename "$epic_dir")"
    ((warnings++))
  fi
done < <(ccpm_list_epic_dirs)

duplicate_epics="$(ccpm_list_epic_dirs | while IFS= read -r epic_dir; do basename "$epic_dir"; done | sort | uniq -d)"
if [ -n "$duplicate_epics" ]; then
  while IFS= read -r epic_name; do
    [ -n "$epic_name" ] || continue
    echo "  ❌ Duplicate epic name: $epic_name"
    ((errors++))
  done <<< "$duplicate_epics"
fi

# Check for tasks without epics
orphaned=$(
  ccpm_list_task_files | while IFS= read -r task_file; do
    epic_dir="$(ccpm_epic_dir_from_task_file "$task_file")"
    [ -f "$epic_dir/epic.md" ] || printf '%s\n' "$task_file"
  done | wc -l | tr -d '[:space:]'
)
[ $orphaned -gt 0 ] && echo "  ⚠️ Found $orphaned orphaned task files" && ((warnings++))

# Check for broken references
echo ""
echo "🔗 Reference Check:"

while IFS= read -r task_file; do
  [ -n "$task_file" ] || continue

  deps_line=$(grep "^depends_on:" "$task_file" | head -1)
  if [ -n "$deps_line" ]; then
    deps=$(echo "$deps_line" | sed 's/^depends_on: *//' | sed 's/^\[//' | sed 's/\]$//' | sed 's/,/ /g' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
    [ -z "$deps" ] && deps=""
  else
    deps=""
  fi
  if [ -n "$deps" ] && [ "$deps" != "depends_on:" ]; then
    epic_dir="$(ccpm_epic_dir_from_task_file "$task_file")"
    for dep in $deps; do
      if ! ccpm_task_file_for_epic_issue "$epic_dir" "$dep" >/dev/null 2>&1; then
        echo "  ⚠️ Task $(basename "$task_file" .md) references missing task: $dep"
        ((warnings++))
      fi
    done
  fi
done < <(ccpm_list_task_files)

if [ $warnings -eq 0 ] && [ $errors -eq 0 ]; then
  echo "  ✅ All references valid"
fi

# Check frontmatter
echo ""
echo "📝 Frontmatter Validation:"
invalid=0

for file in $( { ccpm_list_prd_files; ccpm_list_epic_dirs | while IFS= read -r dir; do printf '%s\n' "$dir/epic.md"; done; ccpm_list_task_files; } ); do
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
  echo "💡 Ask CCPM to clean up archived or completed work if needed"
fi

exit 0
