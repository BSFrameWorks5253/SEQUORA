@echo off
setlocal enabledelayedexpansion
title SEQUORA Studio — Standalone EXE Builder ^& Release Engine
cd /d "%~dp0.."

echo ===============================================================================
echo  SEQUORA Studio — Standalone EXE Builder ^& GitHub Release Engine
echo ===============================================================================
echo.

:: 1. Verify Python
python --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [!] Python 3.10+ is required. Please install Python and ensure it is in PATH.
    pause
    exit /b 1
)

:: 2. Verify PyInstaller and PySide6
python -c "import PyInstaller, PySide6, openpyxl, PIL" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [*] Installing required build dependencies...
    pip install PySide6 pyinstaller openpyxl Pillow
)

:: 3. Launch Builder GUI
if "%1"=="--cli" (
    echo [*] Running CLI headless build...
    python "builder\builder_engine.py"
) else (
    echo [*] Launching Builder GUI Studio...
    python "builder\builder_gui.py"
)

if %ERRORLEVEL% neq 0 (
    echo.
    echo [!] Application exited with status %ERRORLEVEL%.
    pause
)
