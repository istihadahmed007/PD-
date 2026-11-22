@echo off
title DTA: Dhaka Theft Auto (ঢাকা থেফট অটো) - Launcher
cd /d "%~dp0"

echo ===============================================================================
echo                DTA: DHAKA THEFT AUTO (ঢাকা থেফট অটো)
echo           Contemporary Bangladesh Open-World Crime Action Game
echo ===============================================================================
echo.
echo Launching DTA Open-World Game...
echo.

set GODOT_EXE=""
if exist "%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe" (
    set GODOT_EXE="%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe"
) else (
    where godot >nul 2>nul
    if %ERRORLEVEL% equ 0 set GODOT_EXE=godot
)

if not %GODOT_EXE%=="" (
    echo [INFO] Starting latest game project with Godot Engine 4...
    start "" %GODOT_EXE% --path "%~dp0."
    goto end
)

if exist "%~dp0builds\windows\DhakaTheftAuto.exe" (
    echo [INFO] Starting standalone executable...
    start "" "%~dp0builds\windows\DhakaTheftAuto.exe"
    goto end
)

echo [ERROR] Godot 4 executable not found.
pause

:end
