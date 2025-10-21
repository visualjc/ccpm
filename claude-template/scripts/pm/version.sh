#!/bin/bash

# Try .claude/VERSION first (installed location), then claude-template/VERSION (dev location)
if [[ -f ".claude/VERSION" ]]; then
  VERSION_FILE=".claude/VERSION"
elif [[ -f "claude-template/VERSION" ]]; then
  VERSION_FILE="claude-template/VERSION"
else
  echo "❌ VERSION file not found. Please reinstall CCPM templates."
  exit 1
fi

VERSION=$(cat "$VERSION_FILE")
echo "CCPM version $VERSION"
exit 0
