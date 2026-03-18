#!/bin/bash

# Determine repository root
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Locate VERSION file
VERSION_FILE="$ROOT/VERSION"
if [ ! -f "$VERSION_FILE" ]; then
  # Fallback to Cursor CCPM support tree
  VERSION_FILE="$ROOT/.cursor/ccpm/VERSION"
fi

# Legacy fallback for old structure
if [ ! -f "$VERSION_FILE" ]; then
  VERSION_FILE="$ROOT/claude-template/VERSION"
fi

if [ ! -f "$VERSION_FILE" ]; then
  echo "❌ VERSION file not found."
  exit 1
fi

# Read version
VERSION=$(cat "$VERSION_FILE")
echo "CCPM Version: $VERSION"

