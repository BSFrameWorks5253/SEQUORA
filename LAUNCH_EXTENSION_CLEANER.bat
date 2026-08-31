@echo off
setlocal enabledelayedexpansion
title SEQUORA — Clean JPG Extension Normalizer Tool
cd /d "%~dp0"

echo ===============================================================================
echo  SEQUORA — Clean JPG Extension Normalizer Tool
echo ===============================================================================
echo.

cd "tools\Extension_Normalizer_Tool"
call START_TOOL.bat %*
