@echo off
chcp 65001 >nul
title DTA Desktop Shortcut Creator
cd /d "%~dp0"
echo Creating Desktop Shortcut for DTA: Dhaka Theft Auto...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut(\"$env:USERPROFILE\Desktop\Dhaka Theft Auto.lnk\"); $s.TargetPath = \"%~dp0Launch_DTA_Game.bat\"; $s.WorkingDirectory = \"%~dp0\"; $s.Save()"
echo.
echo [SUCCESS] Shortcut created on your Desktop: "Dhaka Theft Auto"
pause
