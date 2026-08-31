@echo off
setlocal enabledelayedexpansion
title SEQUORA — Clean JPG Extension Normalizer Tool
cd /d "%~dp0"

echo ===============================================================================
echo  SEQUORA — Clean JPG Extension Normalizer Tool
echo ===============================================================================
echo.

python main.py %*

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo An error occurred while launching the tool.
    pause
)
