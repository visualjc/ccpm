#!/bin/bash

set -e

REPO_URL="https://github.com/automazeio/ccpm.git"
TARGET_DIR="."
INSTALL_TARGET="claude"

while [ $# -gt 0 ]; do
    case "$1" in
        --target)
            if [ -z "${2:-}" ]; then
                echo "Error: --target requires a value"
                exit 1
            fi
            INSTALL_TARGET="$2"
            shift 2
            ;;
        *)
            echo "Error: Unknown argument: $1"
            echo "Usage: bash -s -- [--target claude|cursor]"
            exit 1
            ;;
    esac
done

case "$INSTALL_TARGET" in
    claude|cursor)
        ;;
    *)
        echo "Error: Invalid target '$INSTALL_TARGET'. Use 'claude' or 'cursor'."
        exit 1
        ;;
esac

echo "Cloning repository from $REPO_URL..."
git clone "$REPO_URL" "$TARGET_DIR"

echo "Clone successful."
echo "Installing target '$INSTALL_TARGET'..."
bash ./project-install.sh "$TARGET_DIR" --target "$INSTALL_TARGET"

echo "Cleaning up..."
rm -rf .git install ccpm cursor-ccpm
echo "✅ Installation complete. Repository is now untracked."
