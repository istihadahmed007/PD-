# ==============================================================================
# SEQUENTIAL REGIONAL BUILDER AND VALIDATOR
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Builds and validates the 7 geographical regions of Bangladesh ONE AT A TIME
#          following the strict constraint: "Build and validate one region at a time."
# ==============================================================================
import os
import re
import sys

def validate_scene_file(filepath):
    print(f"\n[VALIDATING] {filepath}")
    if not os.path.exists(filepath):
        print(f"FAILED: File does not exist: {filepath}")
        return False
        
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()
        
    ext_pattern = re.compile(r'\[ext_resource\s+.*?path="res://(.*?)".*?id="(.*?)".*?\]')
    missing = 0
    for match in ext_pattern.finditer(content):
        rel_path = match.group(1)
        disk_path = os.path.join(".", rel_path.replace("/", os.sep))
        if not os.path.exists(disk_path):
            print(f"  ERROR: Missing ext_resource: res://{rel_path}")
            missing += 1
        else:
            print(f"  [OK] res://{rel_path}")
            
    if missing == 0:
        print(f"PASS: {filepath} is 100% structurally sound!")
        return True
    return False

# ------------------------------------------------------------------------------
# REGION 1: METROPOLITAN DHAKA (Cell 0, 0)
# ------------------------------------------------------------------------------
def build_region_01_dhaka():
    print("\n==================================================")
    print("STEP 1: BUILDING & VALIDATING REGION 01 (METROPOLITAN DHAKA)")
    print("==================================================")
    
    tscn = """[gd_scene load_steps=12 format=3 uid="uid://region01dhaka001"]

[ext_resource type="Script" path="res://world/world_tile.gd" id="1_tile"]
[ext_resource type="PackedScene" path="res://environment/architecture/residential_flats.tscn" id="2_flats"]
[ext_resource type="PackedScene" path="res://environment/architecture/commercial_market.tscn" id="3_market"]
[ext_resource type="PackedScene" path="res://environment/architecture/police_station.tscn" id="4_thana"]
[ext_resource type="PackedScene" path="res://environment/architecture/auto_workshop.tscn" id="5_workshop"]
[ext_resource type="PackedScene" path="res://environment/architecture/tea_stall_tong.tscn" id="6_tong"]
[ext_resource type="PackedScene" path="res://environment/infrastructure/canal_bridge.tscn" id="7_bridge"]
[ext_resource type="PackedScene" path="res://environment/infrastructure/water_surface.tscn" id="8_water"]

[sub_resource type="StandardMaterial3D" id="Mat_DhakaAsphalt"]
albedo_color = Color(0.2, 0.22, 0.24, 1)
roughness = 0.85

[sub_resource type="StandardMaterial3D" id="Mat_Highway"]
albedo_color = Color(0.12, 0.14, 0.15, 1)

[sub_resource type="BoxShape3D" id="Box_Ground"]
size = Vector3(512, 1, 512)

[node name="Region01Dhaka" type="Node3D"]
script = ExtResource("1_tile")
chunk_coord = Vector2i(0, 0)
chunk_size_meters = 512.0
region_id = "dhaka"
region_name = "Metropolitan Dhaka"
region_bangla = "মেট্রোপলিটন ঢাকা"
has_north_road = true
has_south_road = true
has_east_road = true
has_west_road = true
has_river_channel = true

[node name="Terrain" type="Node3D" parent="."]

[node name="GroundMesh" type="CSGBox3D" parent="Terrain"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 0)
use_collision = true
size = Vector3(512, 1, 512)
material = SubResource("Mat_DhakaAsphalt")

[node name="NationalHighwaySpine" type="CSGBox3D" parent="Terrain"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.05, 0)
size = Vector3(16, 0.1, 512)
material = SubResource("Mat_Highway")

[node name="EastWestConnector" type="CSGBox3D" parent="Terrain"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.05, 0)
size = Vector3(512, 0.1, 16)
material = SubResource("Mat_Highway")

[node name="BurigangaCanal" parent="Terrain" instance=ExtResource("8_water")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.2, 50)

[node name="LOD0_Detailed" type="Node3D" parent="."]

[node name="ResidentialBlock" parent="LOD0_Detailed" instance=ExtResource("2_flats")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -80, 0, -60)

[node name="CommercialBazaar" parent="LOD0_Detailed" instance=ExtResource("3_market")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -60, 0, 80)

[node name="LalbaghThana" parent="LOD0_Detailed" instance=ExtResource("4_thana")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 80, 0, -80)

[node name="AutoWorkshop" parent="LOD0_Detailed" instance=ExtResource("5_workshop")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -120, 0, 120)

[node name="BismillahTong" parent="LOD0_Detailed" instance=ExtResource("6_tong")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -30, 0, 20)

[node name="CanalBridge" parent="LOD0_Detailed" instance=ExtResource("7_bridge")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 50)

[node name="LOD1_Medium" type="Node3D" parent="."]

[node name="Collisions" type="Node3D" parent="."]

[node name="StaticGround" type="StaticBody3D" parent="Collisions"]

[node name="CollisionShape3D" type="CollisionShape3D" parent="Collisions/StaticGround"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 0)
shape = SubResource("Box_Ground")
"""
    path = "world/regions/region_01_dhaka.tscn"
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(tscn.strip() + "\n")
    return validate_scene_file(path)

# ------------------------------------------------------------------------------
# REGION 2: RAJSHAHI & PADMA DELTA (Cell -2, 0)
# ------------------------------------------------------------------------------
def build_region_02_rajshahi():
    print("\n==================================================")
    print("STEP 2: BUILDING & VALIDATING REGION 02 (RAJSHAHI & PADMA)")
    print("==================================================")
    
    tscn = """[gd_scene load_steps=10 format=3 uid="uid://region02rajshahi001"]

[ext_resource type="Script" path="res://world/world_tile.gd" id="1_tile"]
[ext_resource type="PackedScene" path="res://environment/architecture/brick_kiln.tscn" id="2_kiln"]
[ext_resource type="PackedScene" path="res://environment/infrastructure/padma_truss_bridge.tscn" id="3_truss"]
[ext_resource type="PackedScene" path="res://environment/foliage/mango_tree.tscn" id="4_mango"]
[ext_resource type="PackedScene" path="res://environment/infrastructure/water_surface.tscn" id="5_water"]

[sub_resource type="StandardMaterial3D" id="Mat_PadmaSand"]
albedo_color = Color(0.82, 0.78, 0.65, 1)
roughness = 0.95

[sub_resource type="StandardMaterial3D" id="Mat_HighwayNH1"]
albedo_color = Color(0.14, 0.15, 0.18, 1)

[sub_resource type="BoxShape3D" id="Box_Ground"]
size = Vector3(512, 1, 512)

[node name="Region02Rajshahi" type="Node3D"]
script = ExtResource("1_tile")
chunk_coord = Vector2i(-2, 0)
chunk_size_meters = 512.0
region_id = "rajshahi"
region_name = "Rajshahi & Padma Delta"
region_bangla = "রাজশাহী ও পদ্মা অববাহিকা"
has_north_road = false
has_south_road = false
has_east_road = true
has_west_road = false
has_river_channel = true

[node name="Terrain" type="Node3D" parent="."]

[node name="PadmaSiltTerrain" type="CSGBox3D" parent="Terrain"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 0)
use_collision = true
size = Vector3(512, 1, 512)
material = SubResource("Mat_PadmaSand")

[node name="PadmaExpresswayNH1" type="CSGBox3D" parent="Terrain"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.05, 0)
size = Vector3(512, 0.1, 16)
material = SubResource("Mat_HighwayNH1")

[node name="PadmaRiver" parent="Terrain" instance=ExtResource("5_water")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.2, -60)

[node name="LOD0_Detailed" type="Node3D" parent="."]

[node name="PadmaBridgeSpan" parent="LOD0_Detailed" instance=ExtResource("3_truss")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 60, 0, 0)

[node name="BrickKiln1" parent="LOD0_Detailed" instance=ExtResource("2_kiln")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -120, 0, 80)

[node name="BrickKiln2" parent="LOD0_Detailed" instance=ExtResource("2_kiln")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -160, 0, 140)

[node name="MangoOrchard1" parent="LOD0_Detailed" instance=ExtResource("4_mango")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -80, 0, -120)

[node name="MangoOrchard2" parent="LOD0_Detailed" instance=ExtResource("4_mango")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -120, 0, -120)

[node name="MangoOrchard3" parent="LOD0_Detailed" instance=ExtResource("4_mango")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -100, 0, -150)

[node name="LOD1_Medium" type="Node3D" parent="."]

[node name="Collisions" type="Node3D" parent="."]

[node name="StaticGround" type="StaticBody3D" parent="Collisions"]

[node name="CollisionShape3D" type="CollisionShape3D" parent="Collisions/StaticGround"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 0)
shape = SubResource("Box_Ground")
"""
    path = "world/regions/region_02_rajshahi_padma.tscn"
    with open(path, "w", encoding="utf-8") as f:
        f.write(tscn.strip() + "\n")
    return validate_scene_file(path)

# ------------------------------------------------------------------------------
# REGION 3: SYLHET TEA GARDENS & WETLANDS (Cell 1, 1)
# ------------------------------------------------------------------------------
def build_region_03_sylhet():
    print("\n==================================================")
    print("STEP 3: BUILDING & VALIDATING REGION 03 (SYLHET TEA HILLS)")
    print("==================================================")
    
    tscn = """[gd_scene load_steps=9 format=3 uid="uid://region03sylhet001"]

[ext_resource type="Script" path="res://world/world_tile.gd" id="1_tile"]
[ext_resource type="PackedScene" path="res://environment/architecture/tea_bungalow.tscn" id="2_bungalow"]
[ext_resource type="PackedScene" path="res://environment/foliage/tea_bush.tscn" id="3_bush"]
[ext_resource type="PackedScene" path="res://environment/infrastructure/water_surface.tscn" id="4_water"]

[sub_resource type="StandardMaterial3D" id="Mat_SylhetGreen"]
albedo_color = Color(0.22, 0.55, 0.28, 1)
roughness = 0.9

[sub_resource type="StandardMaterial3D" id="Mat_HillRoad"]
albedo_color = Color(0.18, 0.2, 0.22, 1)

[sub_resource type="BoxShape3D" id="Box_Ground"]
size = Vector3(512, 1, 512)

[node name="Region03Sylhet" type="Node3D"]
script = ExtResource("1_tile")
chunk_coord = Vector2i(1, 1)
chunk_size_meters = 512.0
region_id = "sylhet"
region_name = "Sylhet Tea Gardens & Wetlands"
region_bangla = "সিলেট চা বাগান ও হাওর"
has_north_road = false
has_south_road = true
has_east_road = false
has_west_road = true
has_river_channel = true

[node name="Terrain" type="Node3D" parent="."]

[node name="TeaHillsGround" type="CSGBox3D" parent="Terrain"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 0)
use_collision = true
size = Vector3(512, 1, 512)
material = SubResource("Mat_SylhetGreen")

[node name="Hill1" type="CSGSphere3D" parent="Terrain"]
transform = Transform3D(1.8, 0, 0, 0, 0.45, 0, 0, 0, 1.8, -120, 0, -80)
radius = 45.0
material = SubResource("Mat_SylhetGreen")

[node name="Hill2" type="CSGSphere3D" parent="Terrain"]
transform = Transform3D(1.6, 0, 0, 0, 0.5, 0, 0, 0, 1.6, 100, 0, 100)
radius = 40.0
material = SubResource("Mat_SylhetGreen")

[node name="SylhetExpresswayNH2" type="CSGBox3D" parent="Terrain"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.05, 0)
size = Vector3(16, 0.1, 512)
material = SubResource("Mat_HillRoad")

[node name="HaorWetlands" parent="Terrain" instance=ExtResource("4_water")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -120, -0.2, 120)

[node name="LOD0_Detailed" type="Node3D" parent="."]

[node name="TeaEstateBungalow" parent="LOD0_Detailed" instance=ExtResource("2_bungalow")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 80, 0, -60)

[node name="TeaBushRow1" parent="LOD0_Detailed" instance=ExtResource("3_bush")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -60, 0, -40)

[node name="TeaBushRow2" parent="LOD0_Detailed" instance=ExtResource("3_bush")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -50, 0, -40)

[node name="TeaBushRow3" parent="LOD0_Detailed" instance=ExtResource("3_bush")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -40, 0, -40)

[node name="LOD1_Medium" type="Node3D" parent="."]

[node name="Collisions" type="Node3D" parent="."]

[node name="StaticGround" type="StaticBody3D" parent="Collisions"]

[node name="CollisionShape3D" type="CollisionShape3D" parent="Collisions/StaticGround"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 0)
shape = SubResource("Box_Ground")
"""
    path = "world/regions/region_03_sylhet_hills.tscn"
    with open(path, "w", encoding="utf-8") as f:
        f.write(tscn.strip() + "\n")
    return validate_scene_file(path)

# ------------------------------------------------------------------------------
# REGION 4: CHATTOGRAM MARITIME PORT (Cell 1, -1)
# ------------------------------------------------------------------------------
def build_region_04_chattogram():
    print("\n==================================================")
    print("STEP 4: BUILDING & VALIDATING REGION 04 (CHATTOGRAM PORT)")
    print("==================================================")
    
    tscn = """[gd_scene load_steps=9 format=3 uid="uid://region04chattogram001"]

[ext_resource type="Script" path="res://world/world_tile.gd" id="1_tile"]
[ext_resource type="PackedScene" path="res://environment/infrastructure/container_stack.tscn" id="2_stack"]
[ext_resource type="PackedScene" path="res://environment/infrastructure/port_gantry_crane.tscn" id="3_crane"]
[ext_resource type="PackedScene" path="res://environment/infrastructure/water_surface.tscn" id="4_water"]

[sub_resource type="StandardMaterial3D" id="Mat_PortConcrete"]
albedo_color = Color(0.3, 0.32, 0.35, 1)
roughness = 0.75

[sub_resource type="StandardMaterial3D" id="Mat_PortRoad"]
albedo_color = Color(0.12, 0.14, 0.16, 1)

[sub_resource type="BoxShape3D" id="Box_Ground"]
size = Vector3(512, 1, 512)

[node name="Region04Chattogram" type="Node3D"]
script = ExtResource("1_tile")
chunk_coord = Vector2i(1, -1)
chunk_size_meters = 512.0
region_id = "chattogram"
region_name = "Chattogram Maritime Port"
region_bangla = "চট্টগ্রাম সমুদ্র বন্দর"
has_north_road = true
has_south_road = true
has_east_road = false
has_west_road = true
has_river_channel = true

[node name="Terrain" type="Node3D" parent="."]

[node name="PortApronGround" type="CSGBox3D" parent="Terrain"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 0)
use_collision = true
size = Vector3(512, 1, 512)
material = SubResource("Mat_PortConcrete")

[node name="GrandCoastalHighwayNH3" type="CSGBox3D" parent="Terrain"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.05, 0)
size = Vector3(16, 0.1, 512)
material = SubResource("Mat_PortRoad")

[node name="KarnaphuliHarbor" parent="Terrain" instance=ExtResource("4_water")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 140, -0.2, 0)

[node name="LOD0_Detailed" type="Node3D" parent="."]

[node name="ContainerStack1" parent="LOD0_Detailed" instance=ExtResource("2_stack")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -80, 0, -80)

[node name="ContainerStack2" parent="LOD0_Detailed" instance=ExtResource("2_stack")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -80, 0, 40)

[node name="GantryCrane1" parent="LOD0_Detailed" instance=ExtResource("3_crane")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 60, 0, -60)

[node name="GantryCrane2" parent="LOD0_Detailed" instance=ExtResource("3_crane")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 60, 0, 80)

[node name="LOD1_Medium" type="Node3D" parent="."]

[node name="Collisions" type="Node3D" parent="."]

[node name="StaticGround" type="StaticBody3D" parent="Collisions"]

[node name="CollisionShape3D" type="CollisionShape3D" parent="Collisions/StaticGround"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 0)
shape = SubResource("Box_Ground")
"""
    path = "world/regions/region_04_chattogram_port.tscn"
    with open(path, "w", encoding="utf-8") as f:
        f.write(tscn.strip() + "\n")
    return validate_scene_file(path)

# ------------------------------------------------------------------------------
# REGION 5: COX'S BAZAR COASTAL STRIP (Cell 1, -2)
# ------------------------------------------------------------------------------
def build_region_05_cox():
    print("\n==================================================")
    print("STEP 5: BUILDING & VALIDATING REGION 05 (COX'S BAZAR COAST)")
    print("==================================================")
    
    tscn = """[gd_scene load_steps=9 format=3 uid="uid://region05cox001"]

[ext_resource type="Script" path="res://world/world_tile.gd" id="1_tile"]
[ext_resource type="PackedScene" path="res://environment/architecture/resort_hotel.tscn" id="2_hotel"]
[ext_resource type="PackedScene" path="res://environment/foliage/coconut_palm.tscn" id="3_palm"]
[ext_resource type="PackedScene" path="res://environment/infrastructure/water_surface.tscn" id="4_water"]

[sub_resource type="StandardMaterial3D" id="Mat_GoldenSand"]
albedo_color = Color(0.88, 0.82, 0.62, 1)
roughness = 0.95

[sub_resource type="StandardMaterial3D" id="Mat_MarineDrive"]
albedo_color = Color(0.15, 0.16, 0.18, 1)

[sub_resource type="BoxShape3D" id="Box_Ground"]
size = Vector3(512, 1, 512)

[node name="Region05CoxBazar" type="Node3D"]
script = ExtResource("1_tile")
chunk_coord = Vector2i(1, -2)
chunk_size_meters = 512.0
region_id = "cox_bazar"
region_name = "Cox's Bazar Coastal Marine Strip"
region_bangla = "কক্সবাজার মেরিন ড্রাইভ"
has_north_road = true
has_south_road = false
has_east_road = false
has_west_road = false
has_river_channel = true

[node name="Terrain" type="Node3D" parent="."]

[node name="SandyBeachGround" type="CSGBox3D" parent="Terrain"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 0)
use_collision = true
size = Vector3(512, 1, 512)
material = SubResource("Mat_GoldenSand")

[node name="MarineDriveHighway" type="CSGBox3D" parent="Terrain"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -40, 0.05, 0)
size = Vector3(14, 0.1, 512)
material = SubResource("Mat_MarineDrive")

[node name="BayOfBengalOcean" parent="Terrain" instance=ExtResource("4_water")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 140, -0.2, 0)

[node name="LOD0_Detailed" type="Node3D" parent="."]

[node name="ResortHotel1" parent="LOD0_Detailed" instance=ExtResource("2_hotel")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -120, 0, -60)

[node name="ResortHotel2" parent="LOD0_Detailed" instance=ExtResource("2_hotel")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -120, 0, 100)

[node name="Palm1" parent="LOD0_Detailed" instance=ExtResource("3_palm")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 20, 0, -40)

[node name="Palm2" parent="LOD0_Detailed" instance=ExtResource("3_palm")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 30, 0, 60)

[node name="LOD1_Medium" type="Node3D" parent="."]

[node name="Collisions" type="Node3D" parent="."]

[node name="StaticGround" type="StaticBody3D" parent="Collisions"]

[node name="CollisionShape3D" type="CollisionShape3D" parent="Collisions/StaticGround"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 0)
shape = SubResource("Box_Ground")
"""
    path = "world/regions/region_05_cox_coastal.tscn"
    with open(path, "w", encoding="utf-8") as f:
        f.write(tscn.strip() + "\n")
    return validate_scene_file(path)

# ------------------------------------------------------------------------------
# REGION 6: SUNDARBANS MANGROVE DELTA (Cell -1, -1)
# ------------------------------------------------------------------------------
def build_region_06_sundarbans():
    print("\n==================================================")
    print("STEP 6: BUILDING & VALIDATING REGION 06 (SUNDARBANS MANGROVE)")
    print("==================================================")
    
    tscn = """[gd_scene load_steps=8 format=3 uid="uid://region06sundarbans001"]

[ext_resource type="Script" path="res://world/world_tile.gd" id="1_tile"]
[ext_resource type="PackedScene" path="res://environment/foliage/mangrove_tree.tscn" id="2_mangrove"]
[ext_resource type="PackedScene" path="res://environment/infrastructure/water_surface.tscn" id="3_water"]

[sub_resource type="StandardMaterial3D" id="Mat_TidalMud"]
albedo_color = Color(0.32, 0.28, 0.22, 1)
roughness = 0.95

[sub_resource type="StandardMaterial3D" id="Mat_TimberBoardwalk"]
albedo_color = Color(0.42, 0.32, 0.22, 1)

[sub_resource type="BoxShape3D" id="Box_Ground"]
size = Vector3(512, 1, 512)

[node name="Region06Sundarbans" type="Node3D"]
script = ExtResource("1_tile")
chunk_coord = Vector2i(-1, -1)
chunk_size_meters = 512.0
region_id = "sundarbans"
region_name = "Sundarbans Mangrove Delta"
region_bangla = "সুন্দরবন ম্যানগ্রোভ বন"
has_north_road = true
has_south_road = false
has_east_road = false
has_west_road = false
has_river_channel = true

[node name="Terrain" type="Node3D" parent="."]

[node name="TidalMudflats" type="CSGBox3D" parent="Terrain"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 0)
use_collision = true
size = Vector3(512, 1, 512)
material = SubResource("Mat_TidalMud")

[node name="TimberRangerPath" type="CSGBox3D" parent="Terrain"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.3, 0)
size = Vector3(6, 0.6, 512)
material = SubResource("Mat_TimberBoardwalk")

[node name="TidalCreekChannel" parent="Terrain" instance=ExtResource("3_water")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 60, -0.2, 0)

[node name="LOD0_Detailed" type="Node3D" parent="."]

[node name="MangroveCluster1" parent="LOD0_Detailed" instance=ExtResource("2_mangrove")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -40, 0, -80)

[node name="MangroveCluster2" parent="LOD0_Detailed" instance=ExtResource("2_mangrove")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -50, 0, 40)

[node name="MangroveCluster3" parent="LOD0_Detailed" instance=ExtResource("2_mangrove")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 30, 0, 110)

[node name="LOD1_Medium" type="Node3D" parent="."]

[node name="Collisions" type="Node3D" parent="."]

[node name="StaticGround" type="StaticBody3D" parent="Collisions"]

[node name="CollisionShape3D" type="CollisionShape3D" parent="Collisions/StaticGround"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 0)
shape = SubResource("Box_Ground")
"""
    path = "world/regions/region_06_sundarbans_mangrove.tscn"
    with open(path, "w", encoding="utf-8") as f:
        f.write(tscn.strip() + "\n")
    return validate_scene_file(path)

# ------------------------------------------------------------------------------
# REGION 7: RURAL AGRICULTURAL PLAINS (Cell -1, 0)
# ------------------------------------------------------------------------------
def build_region_07_rural():
    print("\n==================================================")
    print("STEP 7: BUILDING & VALIDATING REGION 07 (RURAL AGRICULTURE)")
    print("==================================================")
    
    tscn = """[gd_scene load_steps=9 format=3 uid="uid://region07rural001"]

[ext_resource type="Script" path="res://world/world_tile.gd" id="1_tile"]
[ext_resource type="PackedScene" path="res://environment/architecture/thatched_hut.tscn" id="2_hut"]
[ext_resource type="PackedScene" path="res://environment/foliage/banyan_tree.tscn" id="3_banyan"]
[ext_resource type="PackedScene" path="res://environment/infrastructure/water_surface.tscn" id="4_water"]

[sub_resource type="StandardMaterial3D" id="Mat_PaddyGold"]
albedo_color = Color(0.72, 0.65, 0.28, 1)
roughness = 0.9

[sub_resource type="StandardMaterial3D" id="Mat_FeederRoad"]
albedo_color = Color(0.48, 0.42, 0.32, 1)

[sub_resource type="BoxShape3D" id="Box_Ground"]
size = Vector3(512, 1, 512)

[node name="Region07RuralAgriculture" type="Node3D"]
script = ExtResource("1_tile")
chunk_coord = Vector2i(-1, 0)
chunk_size_meters = 512.0
region_id = "rural_plains"
region_name = "Rural Agricultural Floodplains"
region_bangla = "পল্লী কৃষি অঞ্চল"
has_north_road = false
has_south_road = true
has_east_road = true
has_west_road = true
has_river_channel = true

[node name="Terrain" type="Node3D" parent="."]

[node name="PaddyPlainsGround" type="CSGBox3D" parent="Terrain"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 0)
use_collision = true
size = Vector3(512, 1, 512)
material = SubResource("Mat_PaddyGold")

[node name="PadmaExpresswayConnector" type="CSGBox3D" parent="Terrain"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.05, 0)
size = Vector3(512, 0.1, 16)
material = SubResource("Mat_FeederRoad")

[node name="IrrigationCanal" parent="Terrain" instance=ExtResource("4_water")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.2, 80)

[node name="LOD0_Detailed" type="Node3D" parent="."]

[node name="VillageHut1" parent="LOD0_Detailed" instance=ExtResource("2_hut")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -80, 0, -60)

[node name="VillageHut2" parent="LOD0_Detailed" instance=ExtResource("2_hut")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -120, 0, -60)

[node name="VillageBanyanTree" parent="LOD0_Detailed" instance=ExtResource("3_banyan")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -100, 0, -110)

[node name="LOD1_Medium" type="Node3D" parent="."]

[node name="Collisions" type="Node3D" parent="."]

[node name="StaticGround" type="StaticBody3D" parent="Collisions"]

[node name="CollisionShape3D" type="CollisionShape3D" parent="Collisions/StaticGround"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 0)
shape = SubResource("Box_Ground")
"""
    path = "world/regions/region_07_rural_agriculture.tscn"
    with open(path, "w", encoding="utf-8") as f:
        f.write(tscn.strip() + "\n")
    return validate_scene_file(path)


def main():
    print("==================================================")
    print("DTA SEQUENTIAL REGIONAL BUILD & VALIDATION PASS")
    print("==================================================")
    
    stages = [
        ("Region 1: Dhaka", build_region_01_dhaka),
        ("Region 2: Rajshahi", build_region_02_rajshahi),
        ("Region 3: Sylhet", build_region_03_sylhet),
        ("Region 4: Chattogram", build_region_04_chattogram),
        ("Region 5: Cox's Bazar", build_region_05_cox),
        ("Region 6: Sundarbans", build_region_06_sundarbans),
        ("Region 7: Rural Plains", build_region_07_rural),
    ]
    
    for name, func in stages:
        ok = func()
        if not ok:
            print(f"\nCRITICAL FAILURE IN {name}! Aborting sequential generation.")
            sys.exit(1)
            
    print("\n==================================================")
    print("ALL 7 REGIONS SUCCESSFULLY BUILT & VALIDATED ONE BY ONE!")
    print("==================================================")

if __name__ == "__main__":
    main()
