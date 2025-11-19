---
name: create-version-number-command
status: backlog
created: 2025-10-21T01:38:53Z
progress: 0%
prd: ${PRD_DIR}/create-version-number-command.md
github: https://github.com/visualjc/ccpm/issues/1
---

# Epic: create-version-number-command

## Overview

Implement a simple version display system for CCPM using calendar versioning (YYYY.MM.DD.N). This is a minimal feature following the existing CCPM pattern: a slash command definition that calls a bash script, which reads from a single-line VERSION file. The implementation also integrates version display into the existing `/pm:help` command.

## Architecture Decisions

**Version Storage Format**
- **Decision**: Single-line text file at `claude-template/VERSION`
- **Rationale**: Simplest possible solution; no parsing needed; easy to maintain manually
- **Format**: `YYYY.MM.DD.N` (e.g., `2025.10.21.0`)

**Command Pattern**
- **Decision**: Follow existing CCPM command pattern (markdown → bash script)
- **Rationale**: Consistency with all other PM commands; no new patterns to learn
- **Files**: `commands/pm/version.md` + `scripts/pm/version.sh`

**Help Integration Strategy**
- **Decision**: Modify `scripts/pm/help.sh` to read VERSION file and display at top
- **Rationale**: Users discover version immediately when running `/pm:help`; no breaking changes

**Error Handling**
- **Decision**: Graceful degradation with clear error message
- **Rationale**: If VERSION file missing, show error; don't crash or silently fail

## Technical Approach

### File Structure
This implementation requires exactly 3 files:

1. **`claude-template/VERSION`** - Single-line version number
   - Format: `YYYY.MM.DD.N`
   - Example content: `2025.10.21.0`

2. **`claude-template/commands/pm/version.md`** - Slash command definition
   - Follows existing pattern (frontmatter + instructions)
   - Specifies `allowed-tools: Bash`
   - Calls `version.sh` script

3. **`claude-template/scripts/pm/version.sh`** - Bash script
   - Reads VERSION file
   - Outputs: `CCPM version X.Y.Z.N`
   - Error handling for missing file

### Modified Files

1. **`claude-template/scripts/pm/help.sh`** - Add version display
   - Read VERSION file at script start
   - Display version below title, before help sections
   - Fallback to "unknown" if VERSION file missing

### Implementation Pattern

Following the established CCPM pattern observed in `help.md`:

**Command Definition (`version.md`):**
```markdown
---
allowed-tools: Bash
---

Run `bash .claude/scripts/pm/version.sh` and show the output.
```

**Shell Script (`version.sh`):**
```bash
#!/bin/bash
VERSION_FILE="claude-template/VERSION"

if [[ -f "$VERSION_FILE" ]]; then
  VERSION=$(cat "$VERSION_FILE")
  echo "CCPM version $VERSION"
else
  echo "❌ VERSION file not found. Please reinstall CCPM templates."
  exit 1
fi
```

**Help Integration (`help.sh` modification):**
```bash
# Add after title, before main help output
VERSION=$(cat claude-template/VERSION 2>/dev/null || echo "unknown")
echo "Version: $VERSION"
```

## Implementation Strategy

### Phase 1: Core Files (Tasks 1-3)
1. Create VERSION file with initial version
2. Create version.md command definition
3. Create version.sh script

### Phase 2: Help Integration (Task 4)
4. Modify help.sh to display version

### Phase 3: Testing (Task 5)
5. Test all scenarios:
   - `/pm:version` with VERSION file present
   - `/pm:version` with VERSION file missing
   - `/pm:help` shows version
   - Cross-platform compatibility (if applicable)

### Risk Mitigation
- **Risk**: VERSION file path resolution issues
  - **Mitigation**: Use same path pattern as other scripts (relative to repo root)

- **Risk**: Breaking `/pm:help` command
  - **Mitigation**: Use defensive scripting with `2>/dev/null` and fallback to "unknown"

## Task Breakdown Preview

High-level tasks to be created:

- [x] **Task 1**: Create VERSION file with initial version number
- [x] **Task 2**: Create /pm:version command definition (version.md)
- [x] **Task 3**: Create version.sh bash script
- [x] **Task 4**: Integrate version display into /pm:help command
- [x] **Task 5**: Test version command and help integration

**Total: 5 tasks** (well under the 10-task limit)

## Dependencies

### Internal Dependencies
- Existing CCPM command structure (`claude-template/commands/pm/`)
- Existing script directory (`claude-template/scripts/pm/`)
- Existing `/pm:help` command and `help.sh` script

### No External Dependencies
- Pure bash implementation
- No npm, pip, or package manager dependencies
- No external APIs or services

## Success Criteria (Technical)

### Performance Benchmarks
- `/pm:version` executes in < 100ms ✓
- `/pm:help` execution time unchanged (< 1 second) ✓
- No noticeable performance impact

### Quality Gates
- [ ] `/pm:version` returns correct version format
- [ ] `/pm:version` shows clear error when VERSION file missing
- [ ] `/pm:help` displays version without breaking existing output
- [ ] VERSION file follows `YYYY.MM.DD.N` format exactly
- [ ] All scripts use `#!/bin/bash` shebang
- [ ] Error handling uses `2>/dev/null` for graceful degradation

### Acceptance Criteria
1. User can run `/pm:version` and see: `CCPM version YYYY.MM.DD.N`
2. User can run `/pm:help` and see version displayed at top
3. Missing VERSION file shows helpful error message
4. Implementation follows existing CCPM patterns exactly

## Estimated Effort

### Overall Timeline
- **Estimate**: 30-45 minutes total implementation time
- **Complexity**: Low (simple file creation + script modification)

### Resource Requirements
- Single developer
- No infrastructure changes
- No deployment steps (files committed to repo)

### Critical Path
All tasks are sequential but simple:
1. VERSION file → 2 minutes
2. version.md → 5 minutes
3. version.sh → 10 minutes
4. help.sh modification → 10 minutes
5. Testing → 10-15 minutes

### Simplification Opportunities

This implementation is already minimalist:
- ✓ Leverages existing command pattern (no new infrastructure)
- ✓ Uses simplest storage (single-line text file)
- ✓ Minimal code (< 20 lines total across all files)
- ✓ No external dependencies
- ✓ Integrates with existing `/pm:help` rather than requiring new docs

**No further simplification possible without removing core requirements.**

## Tasks Created
- [ ] #2 - Create VERSION file with initial version number (parallel: true)
- [ ] #3 - Create /pm:version command definition (version.md) (parallel: true)
- [ ] #4 - Create version.sh bash script (parallel: false)
- [ ] #5 - Integrate version display into /pm:help command (parallel: false)
- [ ] #6 - Test version command and help integration (parallel: false)

Total tasks: 5
Parallel tasks: 2
Sequential tasks: 3
