@echo off
chcp 65001 >nul
title DTA: Automated Two-Client Local Multiplayer Test
cd /d "%~dp0"

echo ===============================================================================
echo         DTA: DHAKA THEFT AUTO - TWO-CLIENT LOCAL MULTIPLAYER TEST
echo ===============================================================================
echo.
echo 1. Starting Headless Dedicated Server on UDP Port 7777...
echo 2. Launching Client 1 ("Joy") in window 1...
echo 3. Launching Client 2 ("Kabir") in window 2...
echo.

set "GODOT_CONSOLE="
set "GODOT_GUI="

if exist "%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe" (
    set "GODOT_CONSOLE=%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe"
)
if exist "%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe" (
    set "GODOT_GUI=%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe"
)

if "%GODOT_CONSOLE%"=="" (
    where godot >nul 2>nul
    if %ERRORLEVEL% equ 0 (
        set "GODOT_CONSOLE=godot"
        set "GODOT_GUI=godot"
    )
)

if "%GODOT_CONSOLE%"=="" (
    echo [ERROR] Godot 4 executable not found.
    pause
    exit /b 1
)

:: Start Headless Dedicated Server in a separate window
start "DTA Dedicated Server [Port 7777]" "%GODOT_CONSOLE%" --headless --path "%~dp0." -- --server --port 7777 --max-players 8

:: Give server 2 seconds to bind UDP socket
timeout /t 2 /nobreak >nul

:: Launch Client 1 (Joy)
start "DTA Client 1 - Joy" "%GODOT_GUI%" --rendering-driver opengl3 --path "%~dp0." --resolution 960x540 --position 40,80 res://multiplayer/multiplayer_world.tscn -- --client --connect 127.0.0.1 --port 7777 --nickname "Joy"

:: Wait 1 second
timeout /t 1 /nobreak >nul

:: Launch Client 2 (Kabir)
start "DTA Client 2 - Kabir" "%GODOT_GUI%" --rendering-driver opengl3 --path "%~dp0." --resolution 960x540 --position 1000,80 res://multiplayer/multiplayer_world.tscn -- --client --connect 127.0.0.1 --port 7777 --nickname "Kabir"

echo.
echo [INFO] Both clients launched side-by-side!
echo Look at both windows:
echo - Client 1 (Joy) sees Kabir walking in the neighbourhood.
echo - Client 2 (Kabir) sees Joy walking in the neighbourhood.
echo - Use WASD / Mouse to move each player independently!
echo.
pause
