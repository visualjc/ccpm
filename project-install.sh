#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_SOURCE_DIR="$SCRIPT_DIR/skill/ccpm"
TARGET_NAME="claude"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
    echo "Usage: $0 <target-directory> [--target claude|cursor|codex|openclaw|all]"
    echo ""
    echo "Examples:"
    echo "  $0 . --target claude"
    echo "  $0 . --target cursor"
    echo "  $0 . --target codex"
    echo "  $0 . --target all"
}

confirm_overwrite() {
    local path="$1"
    echo -e "${YELLOW}Warning: ${path} already exists.${NC}"
    read -r -p "Overwrite it? (y/N): " reply
    if [[ ! "$reply" =~ ^[Yy]([Ee][Ss])?$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
}

ensure_gitignore_entry() {
    local gitignore_file="$1"
    local entry="$2"
    touch "$gitignore_file"
    if ! grep -Fxq "$entry" "$gitignore_file"; then
        printf "%s\n" "$entry" >>"$gitignore_file"
    fi
}

install_skill() {
    local label="$1"
    local dest_dir="$2"
    local gitignore_entry="$3"

    if [ -d "$dest_dir" ]; then
        confirm_overwrite "$dest_dir"
        rm -rf "$dest_dir"
    fi

    mkdir -p "$(dirname "$dest_dir")"
    cp -R "$SKILL_SOURCE_DIR" "$dest_dir"
    ensure_gitignore_entry "$TARGET_DIR/.gitignore" "$gitignore_entry"

    local file_count
    file_count=$(find "$dest_dir" -type f | wc -l | tr -d ' ')
    echo "  ✅ $label -> $dest_dir ($file_count files)"
}

if [ $# -eq 0 ]; then
    echo -e "${RED}Error: Target directory is required${NC}"
    echo ""
    usage
    exit 1
fi

TARGET_INPUT="$1"
shift

while [ $# -gt 0 ]; do
    case "$1" in
        --target)
            if [ -z "${2:-}" ]; then
                echo -e "${RED}Error: --target requires a value${NC}"
                exit 1
            fi
            TARGET_NAME="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Error: Unknown argument: $1${NC}"
            echo ""
            usage
            exit 1
            ;;
    esac
done

case "$TARGET_NAME" in
    claude|cursor|codex|openclaw|all) ;;
    *)
        echo -e "${RED}Error: Invalid target '$TARGET_NAME'. Use claude, cursor, codex, openclaw, or all.${NC}"
        exit 1
        ;;
esac

if [ ! -d "$SKILL_SOURCE_DIR" ]; then
    echo -e "${RED}Error: Source skill not found at $SKILL_SOURCE_DIR${NC}"
    exit 1
fi

TARGET_DIR="$(cd "$TARGET_INPUT" 2>/dev/null && pwd)" || {
    echo -e "${RED}Error: Target directory does not exist: $TARGET_INPUT${NC}"
    exit 1
}

echo "Installing CCPM into $TARGET_DIR"

case "$TARGET_NAME" in
    claude)
        install_skill "Claude Code" "$TARGET_DIR/.claude/skills/ccpm" ".claude/skills/ccpm/"
        ;;
    cursor)
        install_skill "Cursor" "$TARGET_DIR/.cursor/skills/ccpm" ".cursor/skills/ccpm/"
        ;;
    codex)
        install_skill "Codex" "$TARGET_DIR/skills/ccpm" "skills/ccpm/"
        ;;
    openclaw)
        install_skill "OpenClaw" "$TARGET_DIR/skills/ccpm" "skills/ccpm/"
        ;;
    all)
        install_skill "Claude Code" "$TARGET_DIR/.claude/skills/ccpm" ".claude/skills/ccpm/"
        install_skill "Cursor" "$TARGET_DIR/.cursor/skills/ccpm" ".cursor/skills/ccpm/"
        install_skill "Codex/OpenClaw" "$TARGET_DIR/skills/ccpm" "skills/ccpm/"
        ;;
esac

echo ""
echo -e "${GREEN}✅ CCPM installed successfully${NC}"
echo ""
echo "Important:"
echo "- The skill install location is harness-specific."
echo "- CCPM project data still lives in .claude/ inside the target project."
echo "- See MIGRATION.md and UPSTREAM_SYNC.md in this repo for transition details."
echo ""
echo "Suggested next step:"
echo "- Ask your harness to use the installed 'ccpm' skill, then say: \"create project context\" or \"I want to build X\""
