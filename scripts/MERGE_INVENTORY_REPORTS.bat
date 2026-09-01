@echo off
setlocal enabledelayedexpansion
title SEQUORA — Excel Inventory Report Merger
cd /d "%~dp0.."

echo ===============================================================================
echo  SEQUORA Studio — Excel Report Merger
echo ===============================================================================
echo.

if "%~1"=="" (
    echo [*] Launching SEQUORA Studio GUI...
    cd "SEQUORA_Studio"
    python main.py
) else (
    echo [*] Merging passed files: %*
    python "SEQUORA_Studio\run_app.py" --merge-files %*
)

echo.
echo Press any key to exit...
pause >nul
