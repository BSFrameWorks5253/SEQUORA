@echo off
setlocal enabledelayedexpansion
title SEQUORA Studio — Creative Production Suite
cd /d "%~dp0"

echo ===============================================================================
echo  SEQUORA Studio — Creative Production Suite
echo ===============================================================================
echo.

:: 1. Verify Python
python --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [!] Python 3.10+ is required. Please install from python.org or add to PATH.
    pause
    exit /b 1
)

:: 2. Check PySide6
python -c "import PySide6" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [*] Installing required PySide6 runtime...
    pip install PySide6 openpyxl
)

:: 3. Launch SEQUORA GUI
echo [*] Launching SEQUORA Studio GUI...
cd "SEQUORA_Studio"
python main.py
if %ERRORLEVEL% neq 0 (
    echo.
    echo [!] Application exited.
    pause
)
