# ==============================================================================
# DISTRICT SCENE VALIDATION SCRIPT
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Validates that all ext_resources and sub_resources in scene files exist
# ==============================================================================
import os
import re
import sys

def validate_scene(scene_file_path):
    print(f"--- Validating Scene: {scene_file_path} ---")
    if not os.path.exists(scene_file_path):
        print(f"ERROR: Scene file does not exist: {scene_file_path}")
        return False

    with open(scene_file_path, "r", encoding="utf-8") as f:
        content = f.read()

    errors = 0

    # 1. Check all ext_resources
    ext_pattern = re.compile(r'\[ext_resource\s+.*?path="res://(.*?)".*?id="(.*?)".*?\]')
    ext_map = {}
    for match in ext_pattern.finditer(content):
        rel_path = match.group(1)
        ext_id = match.group(2)
        ext_map[ext_id] = rel_path
        
        # Verify file exists on disk
        # Normalize separators
        disk_path = os.path.join(".", rel_path.replace("/", os.sep))
        if not os.path.exists(disk_path):
            print(f"ERROR: Missing external resource: res://{rel_path} (id={ext_id})")
            errors += 1
        else:
            print(f"  [OK] ExtResource '{ext_id}' -> res://{rel_path}")

    # 2. Check all sub_resources
    sub_pattern = re.compile(r'\[sub_resource\s+.*?id="(.*?)".*?\]')
    sub_map = set()
    for match in sub_pattern.finditer(content):
        sub_id = match.group(1)
        sub_map.add(sub_id)

    # 3. Check all ExtResource usages
    usage_ext_pattern = re.compile(r'ExtResource\("([^"]+)"\)')
    for match in usage_ext_pattern.finditer(content):
        ext_id = match.group(1)
        if ext_id not in ext_map:
            print(f"ERROR: Referenced undefined ExtResource('{ext_id}')")
            errors += 1

    # 4. Check all SubResource usages
    usage_sub_pattern = re.compile(r'SubResource\("([^"]+)"\)')
    for match in usage_sub_pattern.finditer(content):
        sub_id = match.group(1)
        if sub_id not in sub_map:
            print(f"ERROR: Referenced undefined SubResource('{sub_id}')")
            errors += 1

    if errors == 0:
        print(f"SUCCESS: Scene {scene_file_path} is 100% structurally valid!")
        return True
    else:
        print(f"FAILED: {errors} errors found in {scene_file_path}")
        return False

if __name__ == "__main__":
    scenes_to_validate = [
        "tests/test_city_simulation.tscn",
        "characters/pedestrians/bangladeshi_pedestrian.tscn",
        "world/traffic/traffic_light.tscn",
        "vehicles/sedan/sedan.tscn",
        "vehicles/suv/suv.tscn",
        "vehicles/motorcycle/motorcycle.tscn",
        "vehicles/cng/cng_autorickshaw.tscn",
        "vehicles/rickshaw/rickshaw.tscn",
        "vehicles/bus/local_bus.tscn",
        "vehicles/pickup/pickup_truck.tscn",
        "vehicles/van/delivery_van.tscn",
        "tests/test_vehicle_physics.tscn",
        "scenes/districts/district_01_padma_buriganga.tscn",
        "environment/architecture/commercial_market.tscn",
        "environment/architecture/police_station.tscn",
        "environment/architecture/auto_workshop.tscn",
        "environment/architecture/tea_stall_tong.tscn",
        "environment/architecture/cng_bus_stand.tscn",
        "environment/architecture/residential_flats.tscn",
        "environment/architecture/tin_roof_house.tscn",
        "environment/infrastructure/canal_bridge.tscn",
        "environment/infrastructure/water_surface.tscn",
        "environment/infrastructure/electric_pole.tscn",
        "environment/infrastructure/streetlight.tscn",
        "environment/foliage/coconut_palm.tscn",
        "environment/foliage/banyan_tree.tscn",
    ]

    all_passed = True
    for s in scenes_to_validate:
        if not validate_scene(s):
            all_passed = False

    sys.exit(0 if all_passed else 1)
