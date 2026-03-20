#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

assert_file() {
    local path="$1"
    if [ ! -f "$path" ]; then
        echo "❌ Missing file: $path"
        exit 1
    fi
}

assert_skill_layout() {
    local root="$1"
    assert_file "$root/SKILL.md"
    assert_file "$root/references/conventions.md"
    assert_file "$root/references/context.md"
    assert_file "$root/references/testing.md"
    assert_file "$root/references/scripts/status.sh"
    assert_file "$root/references/scripts/test-and-log.sh"
    head -n 1 "$root/SKILL.md" | grep -q '^---$' || {
        echo "❌ SKILL.md missing frontmatter at $root"
        exit 1
    }
}

run_case() {
    local target="$1"
    local project="$TMP_DIR/$target"
    mkdir -p "$project"
    touch "$project/.gitignore"

    echo "==> Testing target: $target"
    bash "$ROOT_DIR/project-install.sh" "$project" --target "$target" >/dev/null

    case "$target" in
        claude)
            assert_skill_layout "$project/.claude/skills/ccpm"
            ;;
        cursor)
            assert_skill_layout "$project/.cursor/skills/ccpm"
            ;;
        codex|openclaw)
            assert_skill_layout "$project/skills/ccpm"
            ;;
        all)
            assert_skill_layout "$project/.claude/skills/ccpm"
            assert_skill_layout "$project/.cursor/skills/ccpm"
            assert_skill_layout "$project/skills/ccpm"
            ;;
    esac
}

run_case claude
run_case cursor
run_case codex
run_case openclaw
run_case all

echo "✅ Skill install validation passed."
