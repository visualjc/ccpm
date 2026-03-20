#!/bin/bash

set -euo pipefail

REPO_URL="https://github.com/visualjc/ccpm.git"
INSTALL_TARGET="claude"
WORKDIR="$(pwd)"
TMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

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
            echo "Usage: bash -s -- [--target claude|cursor|codex|openclaw|all]"
            exit 1
            ;;
    esac
done

case "$INSTALL_TARGET" in
    claude|cursor|codex|openclaw|all) ;;
    *)
        echo "Error: Invalid target '$INSTALL_TARGET'. Use claude, cursor, codex, openclaw, or all."
        exit 1
        ;;
esac

echo "Cloning repository from $REPO_URL..."
git clone --depth 1 "$REPO_URL" "$TMP_DIR/repo"

echo "Installing target '$INSTALL_TARGET' into $WORKDIR..."
bash "$TMP_DIR/repo/project-install.sh" "$WORKDIR" --target "$INSTALL_TARGET"
echo "✅ Installation complete."
