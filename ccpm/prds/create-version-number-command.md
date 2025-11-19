---
name: create-version-number-command
description: Add /pm:version command to display CCPM template system version
status: backlog
created: 2025-10-21T01:32:01Z
---

# PRD: create-version-number-command

## Executive Summary

Add a `/pm:version` command to the CCPM (Claude Code PM) system that displays the current version of the installed PRD template system. This provides users with a simple way to check which version of CCPM they have installed in their project, similar to how `node --version` or `python --version` work in other ecosystems.

## Problem Statement

### What problem are we solving?

Currently, users have no simple way to determine which version of the CCPM template system is installed in their project. As CCPM evolves with new features, bug fixes, and workflow improvements, users need to:

- Know which version they're running to determine compatibility with documentation
- Identify if they need to update their templates
- Report version information when submitting issues or asking for support
- Track which features are available in their installed version

### Why is this important now?

CCPM is an active system with ongoing development. As users adopt it and the system matures, version tracking becomes critical for:

- **Support**: Users reporting issues need to specify their version
- **Documentation**: Features vary by version; users need to know what's available
- **Updates**: Users need to know when updates are available and what version they have
- **Debugging**: Maintainers need version info to reproduce issues

Without this basic versioning capability, the system lacks a fundamental tool that every mature CLI system provides.

## User Stories

### Primary User Persona: CCPM User (Developer/PM)

**User Story 1: Check Installed Version**
- **As a** developer using CCPM
- **I want to** quickly check which version of CCPM templates I have installed
- **So that** I know which features are available and can reference correct documentation

**Acceptance Criteria:**
- Running `/pm:version` displays the current version number
- Version number is clearly formatted and easy to read
- Command completes in under 1 second
- Works from any directory within the project

**User Story 2: Report Version for Support**
- **As a** user encountering an issue
- **I want to** easily get my CCPM version to include in bug reports
- **So that** maintainers can reproduce issues and provide accurate support

**Acceptance Criteria:**
- Version output can be easily copy-pasted into issues
- Format is consistent across all installations
- Includes enough information to identify the exact release

**User Story 3: Discover Version from Help**
- **As a** new CCPM user
- **I want to** see the version number when I run `/pm:help`
- **So that** I immediately know which version I'm working with

**Acceptance Criteria:**
- `/pm:help` output includes version number at top or bottom
- Version is clearly labeled
- Doesn't clutter the help output

### Pain Points Being Addressed

1. **No version visibility**: Users can't tell which CCPM version they have
2. **Support friction**: Bug reports lack version context
3. **Documentation confusion**: Users don't know if features in docs match their version
4. **Update uncertainty**: Users don't know if they have the latest version

## Requirements

### Functional Requirements

**FR1: Version Command**
- Implement `/pm:version` slash command
- Command reads version from dedicated version file
- Outputs version in clear, formatted text
- Returns immediately (< 1 second)

**FR2: Version Storage**
- Create dedicated version file: `.claude/VERSION` or `claude-template/VERSION`
- File contains version number in calendar versioning format: `YYYY.MM.DD.N`
  - `YYYY.MM.DD` = Calendar date of release
  - `N` = Semantic counter for multiple releases on same day (0, 1, 2, etc.)
- Example: `2025.10.21.0` (first release on Oct 21, 2025)
- Example: `2025.10.21.1` (second release on same day)

**FR3: Version Display Format**
- Output format: `CCPM version YYYY.MM.DD.N`
- Example: `CCPM version 2025.10.21.0`
- Clean, single-line output for easy parsing

**FR4: Help Integration**
- Modify `/pm:help` command to display version
- Add version at top or bottom of help output
- Format: `CCPM version YYYY.MM.DD.N`

**FR5: Command Implementation**
- Create `claude-template/commands/pm/version.md` slash command definition
- Create `claude-template/scripts/pm/version.sh` shell script
- Follow existing CCPM command patterns and conventions

### Non-Functional Requirements

**NFR1: Performance**
- Version lookup completes in < 100ms
- No external dependencies required
- Simple file read operation

**NFR2: Reliability**
- Gracefully handles missing VERSION file (show error message)
- Works across all platforms (macOS, Linux, Windows with bash)
- No breaking changes to existing commands

**NFR3: Maintainability**
- Version file is single source of truth
- Easy to update version number (manual edit of one file)
- Follows existing CCPM file structure patterns
- Consistent with other simple commands like `/pm:help`

**NFR4: Usability**
- Output is human-readable
- Version format is self-explanatory
- Error messages are clear if version file is missing

## Success Criteria

### Measurable Outcomes

1. **Implementation Complete**
   - `/pm:version` command exists and functions
   - VERSION file exists in template
   - `/pm:help` displays version

2. **User Adoption**
   - Bug reports include version numbers
   - Users reference versions in discussions
   - Version appears in support requests

3. **Zero Errors**
   - Command works on all platforms
   - No errors when VERSION file exists
   - Clear error if VERSION file missing

### Key Metrics

- **Command execution time**: < 100ms
- **Success rate**: 100% when VERSION file exists
- **User satisfaction**: Users can identify their version without confusion

## Constraints & Assumptions

### Technical Constraints

- Must work within existing bash/markdown command structure
- Cannot require external dependencies (npm, package managers, etc.)
- Must be compatible with existing CCPM installation process
- File-based solution only (no databases, APIs, etc.)

### Assumptions

- Users have bash available (required by CCPM already)
- Users can read text files from `.claude/` directory
- Version file will be manually maintained by CCPM maintainers
- Calendar versioning with semantic counter is sufficient granularity
- Users update CCPM by pulling template updates (git or manual copy)

### Timeline Constraints

- Low priority feature (nice-to-have, not blocking)
- Should be simple enough to implement in single session
- Can be added without disrupting existing functionality

## Out of Scope

The following are explicitly **NOT** part of this feature:

1. **Automatic Version Bumping**: Version file must be manually updated; no auto-increment
2. **Version Comparison**: No checking if newer version available
3. **Update Mechanism**: No `pm:update` command to fetch newer versions
4. **Change Logs**: No automatic changelog generation or display
5. **Versioning User PRDs**: This is NOT for versioning user-generated PRDs or epics
6. **Git Integration**: No git tagging or version control integration
7. **Backwards Compatibility Checking**: No validation of template compatibility
8. **Migration Scripts**: No automatic migration between versions
9. **Multi-version Support**: Only one version can be installed at a time

## Dependencies

### External Dependencies

**None** - This feature is completely self-contained.

### Internal Dependencies

1. **Existing CCPM Structure**
   - Requires `claude-template/commands/pm/` directory
   - Requires `claude-template/scripts/pm/` directory
   - Follows existing slash command pattern

2. **Modified Commands**
   - `/pm:help` command must be updated to display version
   - `claude-template/scripts/pm/help.sh` must be modified

3. **File System Access**
   - Ability to read files from `claude-template/` or `.claude/` directory
   - Bash environment with basic file reading capabilities

### Dependency Risks

- **Risk**: VERSION file could be accidentally deleted
  - **Mitigation**: Clear error message, document importance in README

- **Risk**: Users might forget to update VERSION when modifying templates
  - **Mitigation**: Document version update process, consider adding to release checklist

## Implementation Notes

### Proposed File Locations

```
claude-template/
├── VERSION                           # Version number file
├── commands/pm/version.md           # Slash command definition
└── scripts/pm/version.sh            # Shell script to read VERSION
```

### VERSION File Format

```
2025.10.21.0
```

Single line, no extra content. Format: `YYYY.MM.DD.N`

### Command Behavior

**Success Case:**
```bash
$ /pm:version
CCPM version 2025.10.21.0
```

**Missing VERSION File:**
```bash
$ /pm:version
❌ VERSION file not found. Please reinstall CCPM templates.
```

### Help Integration

Modify `help.sh` to add at the top:
```bash
echo "📚 Claude Code PM - Project Management System"
echo "CCPM version $(cat claude-template/VERSION 2>/dev/null || echo 'unknown')"
echo "============================================="
```
