@echo off

set REPO_URL=https://github.com/automazeio/ccpm.git
set TARGET_DIR=.

echo Cloning repository from %REPO_URL%...
git clone %REPO_URL% %TARGET_DIR%

if %ERRORLEVEL% EQU 0 (
    echo Clone successful.
    
    REM Copy ccpm/ to .claude/ if ccpm directory exists
    if exist ccpm (
        echo Copying ccpm/ to .claude/...
        xcopy /E /I /Y ccpm .claude
        echo ✅ CCPM files installed to .claude/
    )
    
    REM Cleanup: remove git tracking and install directory
    echo Cleaning up...
    rmdir /s /q .git 2>nul
    rmdir /s /q install 2>nul
    rmdir /s /q ccpm 2>nul
    del /q .gitignore 2>nul
    echo ✅ Installation complete. Repository is now untracked.
) else (
    echo Error: Failed to clone repository.
    exit /b 1
)
