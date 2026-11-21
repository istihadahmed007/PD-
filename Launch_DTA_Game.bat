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

if exist "%~dp0builds\windows\DhakaTheftAuto.exe" (
    echo [INFO] Found standalone game binary in builds\windows. Starting game...
    start "" "%~dp0builds\windows\DhakaTheftAuto.exe"
    goto end
)

where godot >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo [INFO] Found Godot in PATH. Starting game...
    godot --path "%~dp0"
    goto end
)

if exist "%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe" (
    echo [INFO] Found WinGet Godot 4.7. Starting game...
    "%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe" --path "%~dp0"
    goto end
)

if exist "C:\Program Files\Godot\godot.exe" (
    echo [INFO] Found Godot in Program Files. Starting game...
    "C:\Program Files\Godot\godot.exe" --path "%~dp0"
    goto end
)

for /r "%LOCALAPPDATA%\Microsoft\WinGet\Packages" %%i in (Godot*.exe) do (
    if exist "%%i" (
        echo [INFO] Found Godot at %%i. Starting game...
        "%%i" --path "%~dp0"
        goto end
    )
)

echo [ERROR] Godot 4 executable not automatically found in PATH or WinGet packages.
echo Please run Godot 4 and open this folder: "%~dp0"
pause

:end
