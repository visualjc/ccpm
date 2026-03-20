@echo off
setlocal enabledelayedexpansion

set REPO_URL=https://github.com/visualjc/ccpm.git
set TARGET_DIR=%CD%
set INSTALL_TARGET=claude
set TMP_REPO=%TEMP%\ccpm-install-%RANDOM%

:parse_args
if "%~1"=="" goto after_parse
if /I "%~1"=="--target" (
    if "%~2"=="" (
        echo Error: --target requires a value
        exit /b 1
    )
    set INSTALL_TARGET=%~2
    shift
    shift
    goto parse_args
)

echo Error: Unknown argument: %~1
echo Usage: ccpm.bat [--target claude^|cursor^|codex^|openclaw^|all]
exit /b 1

:after_parse
if /I not "%INSTALL_TARGET%"=="claude" if /I not "%INSTALL_TARGET%"=="cursor" if /I not "%INSTALL_TARGET%"=="codex" if /I not "%INSTALL_TARGET%"=="openclaw" if /I not "%INSTALL_TARGET%"=="all" (
    echo Error: Invalid target "%INSTALL_TARGET%". Use "claude", "cursor", "codex", "openclaw", or "all".
    exit /b 1
)

echo Cloning repository from %REPO_URL%...
git clone --depth 1 %REPO_URL% "%TMP_REPO%"

if %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to clone repository.
    exit /b 1
)

if not exist "%TARGET_DIR%\.gitignore" type nul > "%TARGET_DIR%\.gitignore"

if /I "%INSTALL_TARGET%"=="claude" goto install_claude
if /I "%INSTALL_TARGET%"=="cursor" goto install_cursor
if /I "%INSTALL_TARGET%"=="codex" goto install_codex_openclaw
if /I "%INSTALL_TARGET%"=="openclaw" goto install_codex_openclaw
if /I "%INSTALL_TARGET%"=="all" goto install_all
goto done

:install_claude
call :install_target "Claude Code" "%TARGET_DIR%\.claude\skills\ccpm" ".claude/skills/ccpm/"
goto done

:install_cursor
call :install_target "Cursor" "%TARGET_DIR%\.cursor\skills\ccpm" ".cursor/skills/ccpm/"
goto done

:install_codex_openclaw
call :install_target "Codex/OpenClaw" "%TARGET_DIR%\skills\ccpm" "skills/ccpm/"
goto done

:install_all
call :install_target "Claude Code" "%TARGET_DIR%\.claude\skills\ccpm" ".claude/skills/ccpm/"
call :install_target "Cursor" "%TARGET_DIR%\.cursor\skills\ccpm" ".cursor/skills/ccpm/"
call :install_target "Codex/OpenClaw" "%TARGET_DIR%\skills\ccpm" "skills/ccpm/"
goto done

:done
echo ✅ Installation complete.
rmdir /s /q "%TMP_REPO%" 2>nul
endlocal
exit /b 0

:install_target
set NAME=%~1
set DEST=%~2
set GITIGNORE_ENTRY=%~3

if exist "%DEST%" (
    set /p OVERWRITE=%DEST% already exists. Overwrite? (y/N): 
    if /I not "!OVERWRITE!"=="y" if /I not "!OVERWRITE!"=="yes" (
        echo Installation cancelled.
        exit /b 0
    )
    rmdir /s /q "%DEST%"
)

for %%I in ("%DEST%") do if not exist "%%~dpI" mkdir "%%~dpI"
xcopy /E /I /Y "%TMP_REPO%\skill\ccpm" "%DEST%" >nul
findstr /X /C:"%GITIGNORE_ENTRY%" "%TARGET_DIR%\.gitignore" >nul || echo %GITIGNORE_ENTRY%>>"%TARGET_DIR%\.gitignore"
echo Installed %NAME% target to %DEST%
goto :eof
