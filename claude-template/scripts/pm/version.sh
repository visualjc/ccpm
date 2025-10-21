#!/bin/bash
VERSION_FILE="claude-template/VERSION"

if [[ -f "$VERSION_FILE" ]]; then
  VERSION=$(cat "$VERSION_FILE")
  echo "CCPM version $VERSION"
  exit 0
else
  echo "❌ VERSION file not found. Please reinstall CCPM templates."
  exit 1
fi
