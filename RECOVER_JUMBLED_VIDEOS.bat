@echo off
title SEQUORA — Jumbled Video Files Recovery Tool
cd /d "%~dp0"
python tools\recover_mismatched_videos.py
if errorlevel 1 (
    echo.
    echo An error occurred running the recovery tool.
    pause
)
