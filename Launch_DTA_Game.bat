@echo off
chcp 65001 >nul
title DTA: Dhaka Theft Auto Launcher
cd /d "%~dp0"

echo ===============================================================================
echo                DTA: DHAKA THEFT AUTO (BANGLADESH OPEN-WORLD)
echo           Contemporary Bangladesh Open-World Crime Action Game
echo ===============================================================================
echo.
echo Launching DTA Open-World Game...
echo.

set "WINGET_GODOT=%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe"

if exist "%WINGET_GODOT%" (
    echo [INFO] Found Godot Engine 4. Launching game with Forward+ AAA Renderer...
    start "" "%WINGET_GODOT%" --path "%~dp0."
    exit /b 0
)

where godot >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo [INFO] Found Godot in PATH. Launching game with Forward+ AAA Renderer...
    start "" godot --path "%~dp0."
    exit /b 0
)

if exist "%~dp0builds\windows\DhakaTheftAuto_Standalone_x64\DhakaTheftAuto.exe" (
    echo [INFO] Launching standalone executable...
    start "" "%~dp0builds\windows\DhakaTheftAuto_Standalone_x64\DhakaTheftAuto.exe"
    exit /b 0
)

if exist "%~dp0builds\windows\DhakaTheftAuto.exe" (
    echo [INFO] Launching standalone executable...
    start "" "%~dp0builds\windows\DhakaTheftAuto.exe"
    exit /b 0
)

echo [ERROR] Could not find Godot Engine 4 or game binary.
pause
exit /b 1
