# ==============================================================================
# WINDOWS RELEASE PACKAGING & DISTRIBUTION SCRIPT
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Packages the complete Gold Master release into builds/windows/
#          with one-click desktop launchers, game files, and documentation.
# ==============================================================================
import os
import shutil
import zipfile
import glob

def package_release():
    print("=" * 60)
    print("  DTA: DHAKA THEFT AUTO — PACKAGING WINDOWS RELEASE (v1.0)")
    print("=" * 60)
    
    release_dir = os.path.join("builds", "windows", "DhakaTheftAuto_Release_v1.0")
    os.makedirs(release_dir, exist_ok=True)
    
    # Core directories to package
    dirs_to_copy = [
        "autoloads",
        "data",
        "player",
        "vehicles",
        "characters",
        "environment",
        "missions",
        "shaders",
        "ui",
        "world",
        "audio",
        "assets",
        "scenes",
        "tests",
        "docs"
    ]
    
    for d in dirs_to_copy:
        if os.path.exists(d):
            dest = os.path.join(release_dir, d)
            if os.path.exists(dest):
                shutil.rmtree(dest)
            shutil.copytree(d, dest, ignore=shutil.ignore_patterns("*.tmp", "__pycache__", "*.uid"))
            print(f"  [OK] Bundled directory: {d}")
            
    # Copy root configuration files
    files_to_copy = [
        "project.godot",
        "export_presets.cfg",
        "README.md",
        "icon.png",
        "Launch_DTA_Game.bat"
    ]
    
    for f in files_to_copy:
        if os.path.exists(f):
            shutil.copy2(f, os.path.join(release_dir, f))
            print(f"  [OK] Bundled file: {f}")

    # Create Desktop Shortcut installer script in the bundle
    shortcut_script = """@echo off
title DTA Desktop Shortcut Creator
set SCRIPT_DIR=%~dp0
set TARGET_BAT=%SCRIPT_DIR%Launch_DTA_Game.bat
set ICON_FILE=%SCRIPT_DIR%icon.png
set SHORTCUT_PATH=%USERPROFILE%\\Desktop\\DTA - Dhaka Theft Auto.lnk

echo Creating Desktop Shortcut...
powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%SHORTCUT_PATH%'); $s.TargetPath = '%TARGET_BAT%'; $s.WorkingDirectory = '%SCRIPT_DIR%'; $s.Save()"
echo.
echo [SUCCESS] Shortcut created on Desktop: "DTA - Dhaka Theft Auto"
pause
"""
    with open(os.path.join(release_dir, "Create_Desktop_Shortcut.bat"), "w", encoding="utf-8") as sf:
        sf.write(shortcut_script)
    print("  [OK] Generated Create_Desktop_Shortcut.bat")

    # Search for Godot executable to include in the bundle
    local_app_data = os.environ.get("LOCALAPPDATA", "")
    godot_candidates = glob.glob(os.path.join(local_app_data, "Microsoft", "WinGet", "Packages", "**", "Godot*.exe"), recursive=True)
    
    godot_exe = None
    if godot_candidates:
        godot_exe = godot_candidates[0]
        print(f"  [FOUND] Godot Engine binary: {godot_exe}")
        dest_godot = os.path.join(release_dir, "godot.exe")
        shutil.copy2(godot_exe, dest_godot)
        print("  [OK] Copied godot.exe into release directory!")
    else:
        print("  [NOTE] Godot engine binary will be linked dynamically via Launch_DTA_Game.bat")

    # Create a compressed zip archive for easy distribution
    zip_output_path = os.path.join("builds", "windows", "DTA_DhakaTheftAuto_Windows_v1.0.zip")
    print(f"\nCompressing release into {zip_output_path}...")
    
    with zipfile.ZipFile(zip_output_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(release_dir):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, os.path.join("builds", "windows"))
                zipf.write(file_path, arcname)
                
    zip_size_mb = os.path.getsize(zip_output_path) / (1024.0 * 1024.0)
    print(f"[SUCCESS] Release archive ready: {zip_output_path} ({zip_size_mb:.2f} MB)")
    print("=" * 60)

if __name__ == "__main__":
    package_release()
