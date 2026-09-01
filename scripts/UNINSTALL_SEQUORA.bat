@echo off
setlocal enabledelayedexpansion
title Uninstall SEQUORA Studio
cd /d "%~dp0.."

echo ===============================================================================
echo  Uninstalling SEQUORA Studio
echo ===============================================================================
echo.
python "installer\uninstall_sequora.py"
echo.
echo [OK] Uninstall Complete.
pause
