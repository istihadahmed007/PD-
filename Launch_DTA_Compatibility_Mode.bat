@echo off
chcp 65001 >nul
title DTA: Dhaka Theft Auto (Compatibility Mode)
cd /d "%~dp0"

echo ===============================================================================
echo         DTA: DHAKA THEFT AUTO (OPENGL 3 / COMPATIBILITY MODE)
echo         Use this launcher for legacy GPUs or low-end integrated graphics
echo ===============================================================================
echo.
echo Launching DTA in OpenGL 3 Compatibility Mode...
echo.

set "WINGET_GODOT=%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe"

if exist "%WINGET_GODOT%" (
    echo [INFO] Found Godot Engine 4. Launching in OpenGL 3 mode...
    start "" "%WINGET_GODOT%" --rendering-driver opengl3 --path "%~dp0."
    exit /b 0
)

where godot >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo [INFO] Found Godot in PATH. Launching in OpenGL 3 mode...
    start "" godot --rendering-driver opengl3 --path "%~dp0."
    exit /b 0
)

if exist "%~dp0builds\windows\DhakaTheftAuto_Standalone_x64\DhakaTheftAuto.exe" (
    echo [INFO] Launching standalone executable...
    start "" "%~dp0builds\windows\DhakaTheftAuto_Standalone_x64\DhakaTheftAuto.exe" --rendering-driver opengl3
    exit /b 0
)

echo [ERROR] Could not find Godot Engine 4 or game binary.
pause
exit /b 1
