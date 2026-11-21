@echo off
title DTA Desktop Shortcut Creator
cd /d "%~dp0"
echo Creating Desktop Shortcut for DTA: Dhaka Theft Auto...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut(\"%USERPROFILE%\Desktop\Dhaka Theft Auto.lnk\"); $s.TargetPath = \"%~dp0builds\windows\DhakaTheftAuto.exe\"; $s.WorkingDirectory = \"%~dp0builds\windows\"; $s.Save()"
echo.
echo [SUCCESS] Shortcut created on your Desktop: "Dhaka Theft Auto"
pause
