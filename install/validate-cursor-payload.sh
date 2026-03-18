#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PAYLOAD_DIR="$ROOT_DIR/cursor-ccpm"

if [ ! -d "$PAYLOAD_DIR" ]; then
    echo "Error: cursor payload not found at $PAYLOAD_DIR"
    exit 1
fi

errors=0

check_exists() {
    local rel_path="$1"

    if [ ! -e "$PAYLOAD_DIR/$rel_path" ]; then
        echo "Missing required payload path: $rel_path"
        errors=1
    fi
}

check_absent() {
    local rel_path="$1"

    if [ -e "$PAYLOAD_DIR/$rel_path" ]; then
        echo "Unexpected runtime file shipped in payload: $rel_path"
        errors=1
    fi
}

check_exists "commands/context-create.md"
check_exists "commands/context-prime.md"
check_exists "commands/context-update.md"
check_exists "commands/testing-prime.md"
check_exists "commands/testing-run.md"
check_exists "ccpm/.ccpmrc"
check_exists "ccpm/ccpm.config"
check_exists "ccpm/VERSION"
check_exists "ccpm/agents/test-runner.md"
check_exists "ccpm/scripts"
check_exists "ccpm/rules"
check_exists "ccpm/context/.gitkeep"
check_exists "ccpm/prds/.gitkeep"
check_exists "ccpm/epics/.gitkeep"
check_exists "ccpm/epics/.archived/.gitkeep"
check_exists "ccpm/epics/archived/.gitkeep"

check_absent "ccpm/testing-config.md"
check_absent "ccpm/README.md"
check_absent "ccpm/settings.json.example"
check_absent "ccpm/hooks"

while IFS= read -r file; do
    while IFS= read -r raw_ref; do
        ref="${raw_ref#\`}"
        ref="${ref%\`}"

        case "$ref" in
            *"{"*|*"}"*|*"$"*|*"*"*)
                continue
                ;;
        esac

        case "$ref" in
            .cursor/ccpm/testing-config.md|.cursor/ccpm/context/.test|.cursor/ccpm/settings.json.example|.cursor/ccpm/epics/.archived/archive-log.md)
                continue
                ;;
        esac

        rel_ref="${ref#.cursor/}"
        if [ ! -e "$PAYLOAD_DIR/$rel_ref" ]; then
            echo "Broken payload reference in ${file#$ROOT_DIR/}: $ref"
            errors=1
        fi
    done < <(grep -oE '\.cursor/ccpm/[A-Za-z0-9._/-]+' "$file" | sort -u || true)
done < <(find "$PAYLOAD_DIR/commands" "$PAYLOAD_DIR/ccpm/rules" -type f -name "*.md" | sort)

if [ "$errors" -ne 0 ]; then
    echo "Cursor payload validation failed."
    exit 1
fi

echo "Cursor payload validation passed."
