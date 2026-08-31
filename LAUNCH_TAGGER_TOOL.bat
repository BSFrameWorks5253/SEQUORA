@echo off
setlocal enabledelayedexpansion
title SEQUORA — Video Thumbnail Suffix Tool (_V)
cd /d "%~dp0"

echo ===============================================================================
echo  SEQUORA — Video Thumbnail Suffix Tool (_V)
echo ===============================================================================
echo.

cd "tools\Video_Thumbnail_Tagger_V"
call START_TOOL.bat
