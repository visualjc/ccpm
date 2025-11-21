# Quick Install

## Unix/Linux/macOS

```bash
curl -sSL https://automaze.io/ccpm/install | bash
```

Or with wget:

```bash
wget -qO- https://automaze.io/ccpm/install | bash
```

## Windows (PowerShell)

```powershell
iwr -useb https://automaze.io/ccpm/install | iex
```

Or download and execute:

```powershell
curl -o ccpm.bat https://automaze.io/ccpm/install && ccpm.bat
```

## One-liner alternatives

> ⚠️ **Note**: These one-liners don't automatically copy `ccpm/` to `.claude/`. After cloning, run: `cp -r ccpm .claude && rm -rf ccpm` (Unix) or `xcopy /E /I /Y ccpm .claude && rmdir /s /q ccpm` (Windows).

### Unix/Linux/macOS (direct commands)
```bash
git clone https://github.com/automazeio/ccpm.git . && rm -rf .git && cp -r ccpm .claude && rm -rf ccpm
```

### Windows (cmd)
```cmd
git clone https://github.com/automazeio/ccpm.git . && rmdir /s /q .git && xcopy /E /I /Y ccpm .claude && rmdir /s /q ccpm
```

### Windows (PowerShell)
```powershell
git clone https://github.com/automazeio/ccpm.git .; Remove-Item -Recurse -Force .git; Copy-Item -Recurse ccpm .claude; Remove-Item -Recurse -Force ccpm
```
