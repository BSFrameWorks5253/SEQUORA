@echo off
setlocal enabledelayedexpansion
title SEQUORA - Video Thumbnail Suffix Tool (_V)
cd /d "%~dp0"

echo ===============================================================================
echo  SEQUORA — Video Thumbnail Suffix Renamer Tool (_V)
echo ===============================================================================
echo.

:: 1. Verify Python Installation
python --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [!] Python is not found in your system PATH.
    echo Please install Python 3.10+ from python.org or add it to PATH.
    pause
    exit /b 1
)

:: 2. Check and Install Requirements
echo [*] Checking required dependencies...
python -c "import PySide6" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [*] Installing PySide6 and required packages...
    pip install -r requirements.txt
    if %ERRORLEVEL% neq 0 (
        echo [!] Failed to install dependencies.
        pause
        exit /b 1
    )
)

:: 3. Launch Tool (handles both drag-and-drop arguments and direct double-click)
if "%~1"=="" (
    echo [*] Launching Native Drag ^& Drop GUI Window...
    python main.py
) else (
    echo [*] Processing dropped files...
    python main.py %*
)

if %ERRORLEVEL% neq 0 (
    pause
)
