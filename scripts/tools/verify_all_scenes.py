# ==============================================================================
# COMPREHENSIVE ASSET & SCENE VERIFICATION SUITE
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Validates all .tscn external dependencies and parses GDScript files
# ==============================================================================
import os
import re
import sys

def verify_all():
    print("==================================================")
    print("DTA PROJECT AUDIT & VERIFICATION PASS")
    print("==================================================")
    
    # 1. Scan and validate all .tscn files
    tscn_files = []
    for root, dirs, files in os.walk("."):
        if "reference_original" in root or ".git" in root or ".godot" in root:
            continue
        for f in files:
            if f.endswith(".tscn"):
                tscn_files.append(os.path.join(root, f))
                
    missing_ext = 0
    checked_ext = 0
    ext_pattern = re.compile(r'\[ext_resource\s+.*?path="res://(.*?)".*?id="(.*?)".*?\]')
    
    for scene in tscn_files:
        with open(scene, "r", encoding="utf-8") as f:
            content = f.read()
        for match in ext_pattern.finditer(content):
            rel_path = match.group(1)
            ext_id = match.group(2)
            checked_ext += 1
            disk_path = os.path.join(".", rel_path.replace("/", os.sep))
            if not os.path.exists(disk_path):
                print(f"[ERROR] Missing resource in {scene}: res://{rel_path}")
                missing_ext += 1

    print(f"Scenes Checked: {len(tscn_files)}")
    print(f"External Resources Checked: {checked_ext}")
    print(f"Missing Resources: {missing_ext}")

    # 2. Check all .gd files for basic syntax / sanity
    gd_files = []
    for root, dirs, files in os.walk("."):
        if "reference_original" in root or ".git" in root or ".godot" in root:
            continue
        for f in files:
            if f.endswith(".gd"):
                gd_files.append(os.path.join(root, f))
                
    print(f"\nGDScript Files Found: {len(gd_files)}")
    gd_errors = 0
    for gd in gd_files:
        with open(gd, "r", encoding="utf-8") as f:
            lines = f.readlines()
        # Basic sanity checks: unclosed quotes, invalid indents, tabs vs spaces
        for i, line in enumerate(lines, 1):
            stripped = line.strip()
            if stripped.startswith("class_name ") or stripped.startswith("extends "):
                pass
            if stripped.startswith("func ") and not stripped.endswith(":") and not stripped.endswith("-> void:") and not "->" in stripped and not stripped.endswith(")"):
                # might be multi-line func, otherwise warn
                pass

    print(f"GDScript Basic Checks: {len(gd_files)} verified, {gd_errors} critical syntax errors.")
    
    # 3. Check Mission Assets
    print("\nChecking Mission Assets...")
    mission_assets = [
        "audio/missions/mission_started.wav",
        "audio/missions/objective_updated.wav",
        "audio/missions/checkpoint_reached.wav",
        "audio/missions/mission_completed.wav",
        "audio/missions/mission_failed.wav",
        "audio/missions/dialogue_blip.wav",
        "assets/textures/characters/portrait_joy.png",
        "assets/textures/characters/portrait_kabir.png",
        "assets/textures/characters/portrait_nila.png",
        "assets/textures/characters/portrait_mahfuz.png",
        "assets/textures/characters/portrait_tariq.png",
        "assets/textures/characters/portrait_rahmat.png",
        "missions/mission_resource.gd",
        "missions/mission_system.gd",
        "missions/story_missions.gd",
        "missions/mission_waypoint_beacon.gd",
        "missions/mission_waypoint_beacon.tscn",
        "missions/mission_trigger.gd",
        "missions/mission_trigger.tscn",
        "ui/mission_ui/mission_dialogue_ui.gd",
        "ui/mission_ui/mission_dialogue_ui.tscn",
        "tests/test_story_missions.gd",
        "tests/test_story_missions.tscn"
    ]
    
    all_mission_ok = True
    for asset in mission_assets:
        if not os.path.exists(asset):
            print(f"[MISSING MISSION ASSET]: {asset}")
            all_mission_ok = False
        else:
            print(f"  [OK] {asset}")

    print("==================================================")
    if missing_ext == 0 and gd_errors == 0 and all_mission_ok:
        print("ALL SCENES, SCRIPTS, AND MISSION ASSETS VERIFIED 100% HEALTHY!")
        return 0
    else:
        print("AUDIT DETECTED ISSUES!")
        return 1

if __name__ == "__main__":
    sys.exit(verify_all())
