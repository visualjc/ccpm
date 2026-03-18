# Quick Install

Default target: `claude`

## Unix/Linux/macOS

```bash
curl -sSL https://automaze.io/ccpm/install | bash
```

Or with wget:

```bash
wget -qO- https://automaze.io/ccpm/install | bash
```

### Cursor target

```bash
curl -sSL https://automaze.io/ccpm/install | bash -s -- --target cursor
```

Or with wget:

```bash
wget -qO- https://automaze.io/ccpm/install | bash -s -- --target cursor
```

## Windows (PowerShell)

```powershell
iwr -useb https://automaze.io/ccpm/install | iex
```

Or download and execute:

```powershell
curl -o ccpm.bat https://automaze.io/ccpm/install && ccpm.bat
```

Cursor target:

```powershell
curl -o ccpm.bat https://automaze.io/ccpm/install && ccpm.bat --target cursor
```

## One-liner alternatives

> ⚠️ **Note**: These one-liners don't automatically copy a payload into `.claude/` or `.cursor/`. After cloning, copy either `ccpm/` into `.claude/` or `cursor-ccpm/{commands,ccpm}` into `.cursor/{commands,ccpm}`.

### Unix/Linux/macOS (direct commands)
```bash
git clone https://github.com/automazeio/ccpm.git . && rm -rf .git && cp -r ccpm .claude && rm -rf ccpm cursor-ccpm
```

### Unix/Linux/macOS (direct commands, Cursor target)
```bash
git clone https://github.com/automazeio/ccpm.git . && rm -rf .git && mkdir -p .cursor && cp -r cursor-ccpm/commands .cursor/commands && cp -r cursor-ccpm/ccpm .cursor/ccpm && rm -rf ccpm cursor-ccpm
```

### Windows (cmd)
```cmd
git clone https://github.com/automazeio/ccpm.git . && rmdir /s /q .git && xcopy /E /I /Y ccpm .claude && rmdir /s /q ccpm && rmdir /s /q cursor-ccpm
```

### Windows (cmd, Cursor target)
```cmd
git clone https://github.com/automazeio/ccpm.git . && rmdir /s /q .git && xcopy /E /I /Y cursor-ccpm\commands .cursor\commands && xcopy /E /I /Y cursor-ccpm\ccpm .cursor\ccpm && rmdir /s /q ccpm && rmdir /s /q cursor-ccpm
```

### Windows (PowerShell)
```powershell
git clone https://github.com/automazeio/ccpm.git .; Remove-Item -Recurse -Force .git; Copy-Item -Recurse ccpm .claude; Remove-Item -Recurse -Force ccpm, cursor-ccpm
```

### Windows (PowerShell, Cursor target)
```powershell
git clone https://github.com/automazeio/ccpm.git .; Remove-Item -Recurse -Force .git; New-Item -ItemType Directory -Force .cursor | Out-Null; Copy-Item -Recurse cursor-ccpm\commands .cursor\commands; Copy-Item -Recurse cursor-ccpm\ccpm .cursor\ccpm; Remove-Item -Recurse -Force ccpm, cursor-ccpm
```
