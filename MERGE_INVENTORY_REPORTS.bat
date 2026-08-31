@echo off
setlocal enabledelayedexpansion
title SEQUORA — Excel Inventory Report Merger (2 Files)
cd /d "%~dp0"

echo ===============================================================================
echo  SEQUORA Studio — Excel Report Merger (2 Files)
echo ===============================================================================
echo.

if "%~1"=="" (
    echo [*] Merging 2 inventory reports from:
    echo     "C:\Users\Burhanuddin\Downloads\New folder"
    echo.
    python "SEQUORA_Studio\run_app.py" --merge-files "C:\Users\Burhanuddin\Downloads\New folder\1448-03-12 _01M_Inventory_Report.xlsx" "C:\Users\Burhanuddin\Downloads\New folder\1448-03-12 _02E_Inventory_Report.xlsx"
) else (
    echo [*] Merging passed 2 files: %*
    python "SEQUORA_Studio\run_app.py" --merge-files %*
)

echo.
echo Press any key to exit...
pause >nul
