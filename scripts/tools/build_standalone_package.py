import os
import shutil
import zipfile

src_dir = os.path.join("builds", "windows")
target_dir = os.path.join(src_dir, "DhakaTheftAuto_Standalone_x64")
os.makedirs(target_dir, exist_ok=True)

# Copy executable and pck
shutil.copy2(os.path.join(src_dir, "DhakaTheftAuto.exe"), os.path.join(target_dir, "DhakaTheftAuto.exe"))
shutil.copy2(os.path.join(src_dir, "DhakaTheftAuto.pck"), os.path.join(target_dir, "DhakaTheftAuto.pck"))
shutil.copy2("icon.png", os.path.join(target_dir, "icon.png"))

# Create Play_Game.bat
play_bat = """@echo off
title DTA: Dhaka Theft Auto (ঢাকা থেফট অটো)
cd /d "%~dp0"
start "" "%~dp0DhakaTheftAuto.exe"
"""
with open(os.path.join(target_dir, "Play_Game.bat"), "w", encoding="utf-8") as f:
    f.write(play_bat)

# Create Create_Desktop_Shortcut.bat
shortcut_bat = """@echo off
title DTA Desktop Shortcut Creator
cd /d "%~dp0"
echo Creating Desktop Shortcut for DTA: Dhaka Theft Auto...
powershell -NoProfile -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut([IO.Path]::Combine($env:USERPROFILE, 'Desktop', 'Dhaka Theft Auto.lnk')); $s.TargetPath = [IO.Path]::Combine((Get-Location).Path, 'DhakaTheftAuto.exe'); $s.WorkingDirectory = (Get-Location).Path; $s.Save()"
echo.
echo [SUCCESS] Shortcut created on Desktop: "Dhaka Theft Auto"
pause
"""
with open(os.path.join(target_dir, "Create_Desktop_Shortcut.bat"), "w", encoding="utf-8") as f:
    f.write(shortcut_bat)

# Create User_Guide.txt
guide_txt = """===============================================================================
       DTA: DHAKA THEFT AUTO (ঢাকা থেফট অটো) - GOLD MASTER RELEASE v1.0
===============================================================================

HOW TO PLAY:
1. Double-click "DhakaTheftAuto.exe" or "Play_Game.bat" to start the game immediately.
2. (Optional) Run "Create_Desktop_Shortcut.bat" to create a 1-click icon on your Windows Desktop.

KEYBOARD & MOUSE CONTROLS:
- W / A / S / D : Move Character / Drive Vehicle (Throttle, Steer, Brake, Reverse)
- Shift (Hold) : Sprint / Vehicle Speed Boost
- Space        : Jump (Coyote-time buffered) / Vehicle Handbrake & Drift
- Left Click   : Melee Attack / Fire Weapon
- Right Click  : Aim Reticle / Over-the-Shoulder Camera
- E            : Interact / Enter Vehicle / Exit Vehicle / ATM & Shop Interaction
- H            : Vehicle Horn
- L            : Vehicle Headlights
- R            : Cycle In-Car Radio Station
- I / Tab      : Open 16-Slot Inventory
- M            : Open Fullscreen Navigation Map (GPS & Fast Travel)
- J            : Open Mission Log & Narrative Dossier
- ESC          : Pause Menu / Settings / Save Game (Slots 1-3)
- F3           : Hardware Performance Profiler Overlay

GAME HIGHLIGHTS:
- 7 Interconnected Bangladesh Regions (Dhaka, Padma Delta, Sylhet, Chattogram, Cox's Bazar, Sundarbans, Rural Fields)
- 6 Authentic Vehicles (Cycle-Rickshaw, CNG Auto-Rickshaw, Local Murir Tin Bus, Sedan, SUV, Motorcycle)
- 5-Star Police Heat & Roadblock Checkpoint System
- Dynamic Day/Night Cycle & Monsoon Weather (Kalbaishakhi thunderstorms & rain ripples)
- Authentic Economy in Bangladesh Taka (BDT), ATMs, Food Stalls, Clothing, Garages, Safehouses
===============================================================================
"""
with open(os.path.join(target_dir, "User_Guide.txt"), "w", encoding="utf-8") as f:
    f.write(guide_txt)

# Compress to standalone zip
zip_out = os.path.join(src_dir, "DTA_DhakaTheftAuto_Windows_Standalone_v1.0.zip")
print(f"Creating {zip_out}...")
with zipfile.ZipFile(zip_out, "w", zipfile.ZIP_DEFLATED) as zf:
    for root, dirs, files in os.walk(target_dir):
        for file in files:
            p = os.path.join(root, file)
            arcname = os.path.relpath(p, target_dir)
            zf.write(p, arcname)

size_mb = os.path.getsize(zip_out) / (1024*1024)
print(f"[SUCCESS] Standalone Package Created: {zip_out} ({size_mb:.2f} MB)")
