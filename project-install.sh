#!/bin/bash
# project-install.sh - Install CCPM into a target project directory
#
# Usage:
#   ./project-install.sh /path/to/your/project
#   ./project-install.sh . --target cursor
#
# This script installs either the Claude or Cursor CCPM payload into
# the target project.

set -e

# Get the directory where this script lives (the ccpm repo root)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_SOURCE_DIR="$SCRIPT_DIR/ccpm"
CURSOR_SOURCE_DIR="$SCRIPT_DIR/cursor-ccpm"
TARGET_NAME="claude"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 <target-directory> [--target claude|cursor]"
    echo ""
    echo "Examples:"
    echo "  $0 /path/to/your/project"
    echo "  $0 . --target cursor"
}

confirm_overwrite() {
    local prompt="$1"

    echo -e "${YELLOW}Warning: ${prompt}${NC}"
    echo ""
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
}

copy_dir_contents() {
    local source_dir="$1"
    local dest_dir="$2"

    mkdir -p "$dest_dir"
    cp -R "$source_dir"/. "$dest_dir"/
}

# Check for target directory argument
if [ -z "$1" ]; then
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
            if [ -z "$2" ]; then
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
    claude|cursor)
        ;;
    *)
        echo -e "${RED}Error: Invalid target '$TARGET_NAME'. Use 'claude' or 'cursor'.${NC}"
        exit 1
        ;;
esac

# Resolve the target directory (handle . and relative paths)
TARGET_DIR="$(cd "$TARGET_INPUT" 2>/dev/null && pwd)" || {
    echo -e "${RED}Error: Target directory does not exist: $TARGET_INPUT${NC}"
    exit 1
}

if [ "$TARGET_NAME" = "claude" ]; then
    if [ ! -d "$CLAUDE_SOURCE_DIR" ]; then
        echo -e "${RED}Error: Source directory not found: $CLAUDE_SOURCE_DIR${NC}"
        echo "Make sure you're running this script from the ccpm repository root."
        exit 1
    fi

    if [ -d "$TARGET_DIR/.claude" ]; then
        confirm_overwrite ".claude/ already exists in $TARGET_DIR"
        echo "Removing existing .claude/ directory..."
        rm -rf "$TARGET_DIR/.claude"
    fi

    echo "Installing CCPM target 'claude' to $TARGET_DIR/.claude/..."
    cp -R "$CLAUDE_SOURCE_DIR" "$TARGET_DIR/.claude"

    if [ ! -d "$TARGET_DIR/.claude" ]; then
        echo -e "${RED}Error: Installation failed - .claude/ was not created${NC}"
        exit 1
    fi

    FILE_COUNT=$(find "$TARGET_DIR/.claude" -type f | wc -l | tr -d ' ')

    echo ""
    echo -e "${GREEN}✅ CCPM installed successfully!${NC}"
    echo ""
    echo "Installed $FILE_COUNT files to: $TARGET_DIR/.claude/"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Copy and customize configuration files:"
    echo "   cd $TARGET_DIR/.claude"
    echo "   cp .ccpmrc.example .ccpmrc"
    echo "   cp settings.json.example settings.json"
    echo ""
    echo "2. Add .claude/ to .gitignore (recommended for team projects):"
    echo "   echo '.claude/' >> $TARGET_DIR/.gitignore"
    echo ""
    echo "3. Initialize the PM system:"
    echo "   /pm:init"
    echo ""
    echo "4. Create your CLAUDE.md file:"
    echo "   /init include rules from .claude/CLAUDE.md"
else
    if [ ! -d "$CURSOR_SOURCE_DIR" ]; then
        echo -e "${RED}Error: Source directory not found: $CURSOR_SOURCE_DIR${NC}"
        echo "Make sure you're running this script from the ccpm repository root."
        exit 1
    fi

    CURSOR_COMMANDS_DIR="$TARGET_DIR/.cursor/commands"
    CURSOR_CCPM_DIR="$TARGET_DIR/.cursor/ccpm"

    if [ -d "$CURSOR_COMMANDS_DIR" ] || [ -d "$CURSOR_CCPM_DIR" ]; then
        confirm_overwrite ".cursor/commands and/or .cursor/ccpm already exist in $TARGET_DIR"
        echo "Removing existing CCPM-managed Cursor paths..."
        rm -rf "$CURSOR_COMMANDS_DIR" "$CURSOR_CCPM_DIR"
    fi

    echo "Installing CCPM target 'cursor' to $TARGET_DIR/.cursor/..."
    copy_dir_contents "$CURSOR_SOURCE_DIR/commands" "$CURSOR_COMMANDS_DIR"
    copy_dir_contents "$CURSOR_SOURCE_DIR/ccpm" "$CURSOR_CCPM_DIR"

    if [ ! -d "$CURSOR_COMMANDS_DIR" ] || [ ! -d "$CURSOR_CCPM_DIR" ]; then
        echo -e "${RED}Error: Installation failed - Cursor CCPM paths were not created${NC}"
        exit 1
    fi

    FILE_COUNT=$(find "$TARGET_DIR/.cursor" -type f | wc -l | tr -d ' ')

    echo ""
    echo -e "${GREEN}✅ CCPM installed successfully!${NC}"
    echo ""
    echo "Installed $FILE_COUNT files to: $TARGET_DIR/.cursor/"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Initialize the PM system:"
    echo "   /pm:init"
    echo ""
    echo "2. Prime the project context:"
    echo "   /context:create"
fi

echo ""
echo "For more information, see: https://github.com/automazeio/ccpm"
