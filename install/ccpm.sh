#!/bin/bash

REPO_URL="https://github.com/automazeio/ccpm.git"
TARGET_DIR="."

echo "Cloning repository from $REPO_URL..."
git clone "$REPO_URL" "$TARGET_DIR"

if [ $? -eq 0 ]; then
    echo "Clone successful."
    
    # Copy ccpm/ to .claude/ if ccpm directory exists
    if [ -d "ccpm" ]; then
        echo "Copying ccpm/ to .claude/..."
        cp -r ccpm .claude
        echo "✅ CCPM files installed to .claude/"
    fi
    
    # Cleanup: remove git tracking and install directory
    echo "Cleaning up..."
    rm -rf .git .gitignore install ccpm
    echo "✅ Installation complete. Repository is now untracked."
else
    echo "Error: Failed to clone repository."
    exit 1
fi
