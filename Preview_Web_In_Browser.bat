@echo off
chcp 65001 >nul
title DTA: Web Client Browser Preview
cd /d "%~dp0"

echo ===============================================================================
echo        DTA: DHAKA THEFT AUTO — WEB BROWSER LIVE PREVIEW SERVER
echo ===============================================================================
echo.
echo Starting local web server with COOP/COEP Cross-Origin Isolation...
echo Opening in your default web browser...
echo.

node scripts/preview_server.js
pause
