# Install

CCPM now ships as a single `skill/ccpm/` package. Install the same skill into the harness-specific skills directory for your project.

## Local install from a clone

```bash
git clone https://github.com/visualjc/ccpm.git
cd ccpm
./project-install.sh . --target claude
```

Supported targets:
- `claude` -> `.claude/skills/ccpm`
- `cursor` -> `.cursor/skills/ccpm`
- `codex` -> `skills/ccpm`
- `openclaw` -> `skills/ccpm`
- `all` -> all of the above

Examples:

```bash
./project-install.sh /path/to/project --target cursor
./project-install.sh /path/to/project --target codex
./project-install.sh /path/to/project --target all
```

## Bootstrap install scripts

Unix/macOS:

```bash
curl -sSL https://raw.githubusercontent.com/visualjc/ccpm/main/install/ccpm.sh | bash -s -- --target claude
```

Windows:

```powershell
curl -o ccpm.bat https://raw.githubusercontent.com/visualjc/ccpm/main/install/ccpm.bat
ccpm.bat --target cursor
```

## Notes

- The skill install directory is harness-specific.
- CCPM project data still lives in `.claude/` for every harness.
- The installer adds the installed skill path to the target repo's `.gitignore`.
- Run `install/validate-skills-install.sh` from this repo to smoke test all install targets.
