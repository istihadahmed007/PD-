@echo off
chcp 65001 >nul
title DTA: Multiplayer Client
cd /d "%~dp0"

echo ===============================================================================
echo           DTA: DHAKA THEFT AUTO - ONLINE MULTIPLAYER CLIENT
echo ===============================================================================
echo.

set SERVER_IP=127.0.0.1
set SERVER_PORT=7777
set NICKNAME=Player_%RANDOM%

set /p USER_NICK="Enter Player Nickname [%NICKNAME%]: "
if not "%USER_NICK%"=="" set NICKNAME=%USER_NICK%

set /p USER_IP="Enter Server IP [127.0.0.1]: "
if not "%USER_IP%"=="" set SERVER_IP=%USER_IP%

set /p USER_PORT="Enter Server UDP Port [7777]: "
if not "%USER_PORT%"=="" set SERVER_PORT=%USER_PORT%

echo.
echo Connecting as '%NICKNAME%' to %SERVER_IP%:%SERVER_PORT%...
echo.

set "GODOT_EXE="
if exist "%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe" (
    set "GODOT_EXE=%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe"
) else (
    where godot >nul 2>nul
    if %ERRORLEVEL% equ 0 (
        set "GODOT_EXE=godot"
    )
)

if "%GODOT_EXE%"=="" (
    echo [ERROR] Godot 4 executable not found.
    pause
    exit /b 1
)

"%GODOT_EXE%" --rendering-driver opengl3 --path "%~dp0." res://multiplayer/multiplayer_world.tscn -- --client --connect %SERVER_IP% --port %SERVER_PORT% --nickname "%NICKNAME%"
pause
