#!/bin/bash
# project-install.sh - Install CCPM into a target project directory
#
# Usage:
#   ./project-install.sh /path/to/your/project
#   ./project-install.sh .                        # Install to current directory
#
# This script copies the ccpm/ directory to .claude/ in the target project.

set -e

# Get the directory where this script lives (the ccpm repo root)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/ccpm"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check for target directory argument
if [ -z "$1" ]; then
    echo -e "${RED}Error: Target directory is required${NC}"
    echo ""
    echo "Usage: $0 <target-directory>"
    echo ""
    echo "Examples:"
    echo "  $0 /path/to/your/project"
    echo "  $0 ."
    exit 1
fi

# Resolve the target directory (handle . and relative paths)
TARGET_DIR="$(cd "$1" 2>/dev/null && pwd)" || {
    echo -e "${RED}Error: Target directory does not exist: $1${NC}"
    exit 1
}

# Verify source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}Error: Source directory not found: $SOURCE_DIR${NC}"
    echo "Make sure you're running this script from the ccpm repository root."
    exit 1
fi

# Check if .claude already exists in target
if [ -d "$TARGET_DIR/.claude" ]; then
    echo -e "${YELLOW}Warning: .claude/ already exists in $TARGET_DIR${NC}"
    echo ""
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    echo "Removing existing .claude/ directory..."
    rm -rf "$TARGET_DIR/.claude"
fi

# Copy ccpm/ to target/.claude/
echo "Installing CCPM to $TARGET_DIR/.claude/..."
cp -r "$SOURCE_DIR" "$TARGET_DIR/.claude"

# Verify the copy succeeded
if [ ! -d "$TARGET_DIR/.claude" ]; then
    echo -e "${RED}Error: Installation failed - .claude/ was not created${NC}"
    exit 1
fi

# Count installed files
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
echo ""
echo "For more information, see: https://github.com/automazeio/ccpm"
