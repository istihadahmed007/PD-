@echo off
title DTA: Dedicated Multiplayer Server (ঢাকা থেফট অটো)
cd /d "%~dp0"

echo ===============================================================================
echo        DTA: DHAKA THEFT AUTO - DEDICATED MULTIPLAYER SERVER (HEADLESS)
echo                Phase 1: Working Online Multiplayer Foundation
echo ===============================================================================
echo.

set PORT=7777
set MAX_PLAYERS=16

if not "%~1"=="" set PORT=%~1
if not "%~2"=="" set MAX_PLAYERS=%~2

echo [CONFIG] UDP Port: %PORT%
echo [CONFIG] Max Connections: %MAX_PLAYERS%
echo [CONFIG] Headless Mode: ACTIVE (No GPU required)
echo.
echo Starting Authoritative Dedicated Server...
echo Press Ctrl+C in this console to gracefully stop the server.
echo.

set GODOT_EXE=""
if exist "%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe" (
    set GODOT_EXE="%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe"
) else (
    where godot >nul 2>nul
    if %ERRORLEVEL% equ 0 (
        set GODOT_EXE=godot
    )
)

if %GODOT_EXE%=="" (
    echo [ERROR] Godot 4 executable not automatically found.
    pause
    exit /b 1
)

%GODOT_EXE% --headless --path "%~dp0." -- --server --port %PORT% --max-players %MAX_PLAYERS%
pause
