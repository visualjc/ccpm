@echo off
setlocal enabledelayedexpansion

set REPO_URL=https://github.com/automazeio/ccpm.git
set TARGET_DIR=.
set INSTALL_TARGET=claude

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
echo Usage: ccpm.bat [--target claude^|cursor]
exit /b 1

:after_parse
if /I not "%INSTALL_TARGET%"=="claude" if /I not "%INSTALL_TARGET%"=="cursor" (
    echo Error: Invalid target "%INSTALL_TARGET%". Use "claude" or "cursor".
    exit /b 1
)

echo Cloning repository from %REPO_URL%...
git clone %REPO_URL% %TARGET_DIR%

if %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to clone repository.
    exit /b 1
)

echo Clone successful.

if /I "%INSTALL_TARGET%"=="claude" (
    if exist .claude (
        set /p OVERWRITE=.claude already exists. Overwrite? (y/N): 
        if /I not "!OVERWRITE!"=="y" if /I not "!OVERWRITE!"=="yes" (
            echo Installation cancelled.
            exit /b 0
        )
        rmdir /s /q .claude
    )

    if exist ccpm (
        echo Copying ccpm to .claude...
        xcopy /E /I /Y ccpm .claude >nul
        echo ✅ CCPM files installed to .claude/
    )
) else (
    if exist .cursor\commands (
        set CURSOR_OVERWRITE=1
    )
    if exist .cursor\ccpm (
        set CURSOR_OVERWRITE=1
    )

    if defined CURSOR_OVERWRITE (
        set /p OVERWRITE=.cursor\commands and/or .cursor\ccpm already exist. Overwrite? (y/N): 
        if /I not "!OVERWRITE!"=="y" if /I not "!OVERWRITE!"=="yes" (
            echo Installation cancelled.
            exit /b 0
        )
        if exist .cursor\commands rmdir /s /q .cursor\commands
        if exist .cursor\ccpm rmdir /s /q .cursor\ccpm
    )

    if not exist .cursor mkdir .cursor

    if exist cursor-ccpm\commands (
        echo Copying cursor commands to .cursor\commands...
        xcopy /E /I /Y cursor-ccpm\commands .cursor\commands >nul
    )
    if exist cursor-ccpm\ccpm (
        echo Copying cursor ccpm payload to .cursor\ccpm...
        xcopy /E /I /Y cursor-ccpm\ccpm .cursor\ccpm >nul
        echo ✅ CCPM files installed to .cursor/
    )
)

echo Cleaning up...
rmdir /s /q .git 2>nul
rmdir /s /q install 2>nul
rmdir /s /q ccpm 2>nul
rmdir /s /q cursor-ccpm 2>nul
del /q .gitignore 2>nul
echo ✅ Installation complete. Repository is now untracked.
endlocal
