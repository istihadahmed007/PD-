@echo off
chcp 65001 >nul
title DTA: Web Client Browser Preview
cd /d "%~dp0"

echo ===============================================================================
echo        DTA: DHAKA THEFT AUTO -- WEB BROWSER LIVE PREVIEW SERVER
echo ===============================================================================
echo.
echo Starting local web server with COOP/COEP Cross-Origin Isolation...
echo Opening in your default web browser...
echo.

set "NODE_CMD="

where node >nul 2>nul
if %ERRORLEVEL% equ 0 (
    set "NODE_CMD=node"
)

if "%NODE_CMD%"=="" (
    if exist "C:\Program Files\nodejs\node.exe" (
        set "NODE_CMD=C:\Program Files\nodejs\node.exe"
    )
)

if "%NODE_CMD%"=="" (
    if exist "C:\Program Files (x86)\nodejs\node.exe" (
        set "NODE_CMD=C:\Program Files (x86)\nodejs\node.exe"
    )
)

if "%NODE_CMD%"=="" (
    if exist "%LOCALAPPDATA%\Programs\nodejs\node.exe" (
        set "NODE_CMD=%LOCALAPPDATA%\Programs\nodejs\node.exe"
    )
)

if "%NODE_CMD%"=="" (
    echo [ERROR] Node.js is not found in PATH or standard installation directories.
    echo Please install Node.js from https://nodejs.org or check your PATH.
    echo.
    pause
    exit /b 1
)

echo [INFO] Using Node: %NODE_CMD%
"%NODE_CMD%" "%~dp0scripts\preview_server.js"

if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Server encountered an unexpected issue.
    pause
)
