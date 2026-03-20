#!/bin/bash

set -uo pipefail

if [ $# -eq 0 ]; then
    echo "Usage: $0 <test_target> [log_filename]"
    echo "Examples:"
    echo "  $0 tests/api/test_users.py"
    echo "  $0 packages/app/src/auth.test.ts auth-tests.log"
    exit 1
fi

TEST_TARGET="$1"

LOG_DIR=".claude/testing/logs"
mkdir -p "$LOG_DIR"

if [ $# -ge 2 ]; then
    LOG_NAME="$2"
    case "$LOG_NAME" in
        *.log) ;;
        *) LOG_NAME="${LOG_NAME}.log" ;;
    esac
else
    LOG_NAME="$(basename "$TEST_TARGET")"
    LOG_NAME="${LOG_NAME%.*}.log"
fi

LOG_FILE="${LOG_DIR}/${LOG_NAME}"

echo "Running tests for: $TEST_TARGET"
echo "Logging to: $LOG_FILE"

exit_code=0

if [[ "$TEST_TARGET" =~ \.py$ ]]; then
    if command -v pytest >/dev/null 2>&1; then
        pytest "$TEST_TARGET" -v >"$LOG_FILE" 2>&1
    else
        python "$TEST_TARGET" >"$LOG_FILE" 2>&1
    fi
elif [[ "$TEST_TARGET" =~ \.(js|jsx|ts|tsx)$ ]]; then
    if [ -f package.json ] && grep -q '"test"' package.json; then
        npm test -- "$TEST_TARGET" >"$LOG_FILE" 2>&1 || npm test "$TEST_TARGET" >"$LOG_FILE" 2>&1
    elif command -v pnpm >/dev/null 2>&1 && [ -f package.json ]; then
        pnpm test -- "$TEST_TARGET" >"$LOG_FILE" 2>&1
    elif command -v jest >/dev/null 2>&1; then
        jest "$TEST_TARGET" >"$LOG_FILE" 2>&1
    elif command -v vitest >/dev/null 2>&1; then
        vitest run "$TEST_TARGET" >"$LOG_FILE" 2>&1
    else
        node "$TEST_TARGET" >"$LOG_FILE" 2>&1
    fi
elif [[ "$TEST_TARGET" =~ \.java$ ]]; then
    if [ -f pom.xml ]; then
        mvn test -Dtest="$(basename "$TEST_TARGET" .java)" >"$LOG_FILE" 2>&1
    elif [ -f build.gradle ] || [ -f build.gradle.kts ]; then
        ./gradlew test --tests "$(basename "$TEST_TARGET" .java)" >"$LOG_FILE" 2>&1
    else
        echo "❌ Java test runner not found (need Maven or Gradle)" >"$LOG_FILE" 2>&1
        exit 1
    fi
elif [[ "$TEST_TARGET" =~ \.cs$ ]]; then
    dotnet test "$TEST_TARGET" >"$LOG_FILE" 2>&1
elif [[ "$TEST_TARGET" =~ \.rb$ ]]; then
    if [ -f Gemfile ]; then
        bundle exec rspec "$TEST_TARGET" >"$LOG_FILE" 2>&1
    elif command -v rspec >/dev/null 2>&1; then
        rspec "$TEST_TARGET" >"$LOG_FILE" 2>&1
    else
        ruby "$TEST_TARGET" >"$LOG_FILE" 2>&1
    fi
elif [[ "$TEST_TARGET" =~ \.php$ ]]; then
    if [ -f vendor/bin/phpunit ]; then
        ./vendor/bin/phpunit "$TEST_TARGET" >"$LOG_FILE" 2>&1
    elif command -v phpunit >/dev/null 2>&1; then
        phpunit "$TEST_TARGET" >"$LOG_FILE" 2>&1
    else
        php "$TEST_TARGET" >"$LOG_FILE" 2>&1
    fi
elif [[ "$TEST_TARGET" =~ \.go$ ]]; then
    go test "$(dirname "$TEST_TARGET")" -v >"$LOG_FILE" 2>&1
elif [[ "$TEST_TARGET" =~ \.rs$ ]]; then
    cargo test "$(basename "$TEST_TARGET" .rs)" >"$LOG_FILE" 2>&1
elif [[ "$TEST_TARGET" =~ \.swift$ ]]; then
    swift test >"$LOG_FILE" 2>&1
elif [[ "$TEST_TARGET" =~ \.dart$ ]]; then
    if [ -f pubspec.yaml ]; then
        flutter test "$TEST_TARGET" >"$LOG_FILE" 2>&1
    else
        dart test "$TEST_TARGET" >"$LOG_FILE" 2>&1
    fi
else
    echo "❌ Unsupported test file type: $TEST_TARGET" >"$LOG_FILE" 2>&1
    exit 1
fi
exit_code=$?

if [ "$exit_code" -eq 0 ]; then
    echo "✅ Test command finished successfully. Log saved to $LOG_FILE"
else
    echo "❌ Test command failed with exit code $exit_code. See $LOG_FILE"
fi

exit "$exit_code"
