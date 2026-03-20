# Testing — Prime and Run Validation

Use this workflow when the user wants CCPM to understand the repo's test setup, run tests, or analyze failures as part of delivery work.

Testing state lives in `.claude/testing-config.md` regardless of where the skill itself is installed.
Captured targeted test logs live under `.claude/testing/logs/`.

---

## Prime The Testing Environment

**Trigger**: "set up testing", "figure out the test command", "prime testing for this repo"

### Preflight
- Inspect common test manifests and directories for the current language/framework.
- If no framework is obvious, ask the user which command should be used and save that choice.

### Detection

Check for the common test setups used in this repo, including:
- Node.js: `package.json`, Jest, Mocha, Vitest
- Python: `pytest.ini`, `conftest.py`, `pyproject.toml`, `requirements.txt`
- Go: `go test`, `*_test.go`
- Rust: `cargo test`
- Java / Kotlin: Maven or Gradle test config
- C#/.NET: `dotnet test`
- PHP: PHPUnit or Pest
- Ruby: RSpec or Minitest
- Swift / Dart / C/C++ equivalents

Also verify test dependencies are installed when possible.

### Process

Write `.claude/testing-config.md` with frontmatter:

```yaml
---
framework: <name>
test_command: <command>
test_directory: <path>
config_file: <path or none>
last_updated: <ISO 8601>
---
```

Then include:
- detected options/flags
- environment variables required for testing
- any prerequisites or warnings

### Output
- Summarize detected framework and saved command
- Call out missing dependencies or ambiguous setup

---

## Run Tests

**Trigger**: "run tests", "run the auth tests", "run pytest for api/tests/test_users.py"

### Preflight
- If `.claude/testing-config.md` does not exist, prime testing first.
- If the user provided a file path or specific target, verify it exists when possible.

### Process

Use the configured command for full-suite runs.

For targeted file runs or when detailed logs are needed, prefer:

```bash
bash <installed_skill_dir>/references/scripts/test-and-log.sh <test_target> [log_name]
```

That helper writes logs to `.claude/testing/logs/` so the side effect stays within CCPM-managed project data.

If the harness supports sub-agents, delegate long-running test execution when that keeps the main thread cleaner. Otherwise run the tests directly and summarize the result yourself.

Default expectations:
- verbose output when available
- capture stderr and stack traces
- avoid mocks unless the existing test suite requires them
- identify whether failures look like test issues, code issues, or environment issues

### Output
- Passed/failed/skipped counts when available
- failing test names and concise reasons
- likely root cause and next debugging step
- path to captured logs for targeted runs

---

## Failure Handling

If test execution fails before tests actually run:
- report missing framework/dependency/tooling
- suggest the install/restore command
- keep the recommendation specific to the detected ecosystem
