@echo off
setlocal enabledelayedexpansion
title SEQUORA Studio — Professional Windows Setup
cd /d "%~dp0.."

echo ===============================================================================
echo  SEQUORA Studio — Professional Windows Setup ^& Installer
echo ===============================================================================
echo.

:: 1. Check Python
python --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [!] Python 3.10+ is required to install SEQUORA Studio.
    echo     Please install Python from python.org and check "Add Python to PATH".
    echo.
    pause
    exit /b 1
)

:: 2. Run Installer Engine
python "installer\install_sequora.py"

if %ERRORLEVEL% equ 0 (
    echo.
    echo ===============================================================================
    echo  Setup completed successfully! 
    echo  You can now launch SEQUORA Studio from your Desktop or Start Menu.
    echo ===============================================================================
    echo.
) else (
    echo.
    echo [!] Setup encountered an error. Please see the messages above.
    echo.
)

pause
