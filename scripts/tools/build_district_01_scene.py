# ==============================================================================
# DISTRICT 01 SCENE GENERATOR
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Programmatically constructs the complete 400m x 400m Godot 4 scene
#          file: scenes/districts/district_01_padma_buriganga.tscn
# ==============================================================================
import os

def generate_district_scene():
    output_path = r"scenes/districts/district_01_padma_buriganga.tscn"
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    header = """[gd_scene format=3 uid="uid://d3district01padma001"]

[ext_resource type="Script" path="res://scenes/districts/district_01_padma_buriganga.gd" id="1_controller"]
[ext_resource type="Script" path="res://environment/weather_system.gd" id="2_weather"]
[ext_resource type="PackedScene" uid="uid://ciqrpd5675boy" path="res://player/player.tscn" id="3_player"]
[ext_resource type="PackedScene" uid="uid://bdahud001scene" path="res://ui/hud/hud.tscn" id="4_hud"]
[ext_resource type="PackedScene" uid="uid://d3rickshaw001" path="res://vehicles/rickshaw/rickshaw.tscn" id="5_rickshaw"]
[ext_resource type="PackedScene" uid="uid://d3canalbridge001" path="res://environment/infrastructure/canal_bridge.tscn" id="6_bridge"]
[ext_resource type="PackedScene" uid="uid://d3watersurf001" path="res://environment/infrastructure/water_surface.tscn" id="7_water"]
[ext_resource type="PackedScene" uid="uid://d3elecpole001" path="res://environment/infrastructure/electric_pole.tscn" id="8_pole"]
[ext_resource type="PackedScene" uid="uid://d3streetlight001" path="res://environment/infrastructure/streetlight.tscn" id="9_light"]
[ext_resource type="PackedScene" uid="uid://d3marketrow001" path="res://environment/architecture/commercial_market.tscn" id="10_market"]
[ext_resource type="PackedScene" uid="uid://d3policestation001" path="res://environment/architecture/police_station.tscn" id="11_police"]
[ext_resource type="PackedScene" uid="uid://d3autoworkshop001" path="res://environment/architecture/auto_workshop.tscn" id="12_workshop"]
[ext_resource type="PackedScene" uid="uid://d3teastalltong001" path="res://environment/architecture/tea_stall_tong.tscn" id="13_tong"]
[ext_resource type="PackedScene" uid="uid://d3cngbusstand001" path="res://environment/architecture/cng_bus_stand.tscn" id="14_cngstand"]
[ext_resource type="PackedScene" uid="uid://d3resflats001" path="res://environment/architecture/residential_flats.tscn" id="15_flats"]
[ext_resource type="PackedScene" uid="uid://d3tinhouse001" path="res://environment/architecture/tin_roof_house.tscn" id="16_tinhouse"]
[ext_resource type="PackedScene" uid="uid://d3coconutpalm001" path="res://environment/foliage/coconut_palm.tscn" id="17_palm"]
[ext_resource type="PackedScene" uid="uid://d3banyantree001" path="res://environment/foliage/banyan_tree.tscn" id="18_banyan"]
[ext_resource type="PackedScene" uid="uid://d3sedan001" path="res://vehicles/sedan/sedan.tscn" id="19_sedan"]
[ext_resource type="PackedScene" uid="uid://d3cng001" path="res://vehicles/cng/cng_autorickshaw.tscn" id="20_cng"]
[ext_resource type="PackedScene" uid="uid://d3bus001" path="res://vehicles/bus/local_bus.tscn" id="21_bus"]
[ext_resource type="PackedScene" uid="uid://d3suv001" path="res://vehicles/suv/suv.tscn" id="22_suv"]
[ext_resource type="PackedScene" uid="uid://d3bike001" path="res://vehicles/motorcycle/motorcycle.tscn" id="23_bike"]
[ext_resource type="PackedScene" uid="uid://d3pickup001" path="res://vehicles/pickup/pickup_truck.tscn" id="24_pickup"]
[ext_resource type="Script" path="res://world/traffic/road_network_3d.gd" id="25_roadnet"]
[ext_resource type="PackedScene" uid="uid://d3trafficlight001" path="res://world/traffic/traffic_light.tscn" id="26_trafficlight"]
[ext_resource type="Script" path="res://scripts/pedestrians/pedestrian_system.gd" id="27_pedsys"]
[ext_resource type="Script" path="res://world/traffic/traffic_system.gd" id="28_trafficsys"]
[ext_resource type="Script" path="res://scripts/police/police_system.gd" id="29_policesys"]
[ext_resource type="PackedScene" uid="uid://d3policeradar001" path="res://ui/police_radar/police_radar_hud.tscn" id="30_radarhud"]
[ext_resource type="PackedScene" uid="uid://d3policecheckpoint001" path="res://environment/police/police_checkpoint.tscn" id="31_checkpoint"]
[ext_resource type="PackedScene" uid="uid://d3policesedan001" path="res://vehicles/police/police_sedan.tscn" id="32_policesedan"]
[ext_resource type="PackedScene" uid="uid://d3policeofficer001" path="res://characters/police/police_officer.tscn" id="33_policeofficer"]

[sub_resource type="ProceduralSkyMaterial" id="ProceduralSkyMaterial_monsoon"]
sky_top_color = Color(0.35, 0.58, 0.92, 1)
sky_horizon_color = Color(0.74, 0.82, 0.88, 1)
ground_bottom_color = Color(0.2, 0.22, 0.25, 1)
ground_horizon_color = Color(0.74, 0.82, 0.88, 1)

[sub_resource type="Sky" id="Sky_district"]
sky_material = SubResource("ProceduralSkyMaterial_monsoon")

[sub_resource type="Environment" id="Environment_district"]
background_mode = 2
sky = SubResource("Sky_district")
tonemap_mode = 2
glow_enabled = true
glow_intensity = 0.4
ssao_enabled = true
ssao_radius = 1.2
ssao_intensity = 2.0
fog_enabled = true
fog_light_color = Color(0.72, 0.78, 0.85, 1)
fog_density = 0.0015
fog_aerial_perspective = 0.4

[sub_resource type="StandardMaterial3D" id="Mat_NorthTerrain"]
albedo_color = Color(0.42, 0.4, 0.36, 1)
roughness = 0.92

[sub_resource type="StandardMaterial3D" id="Mat_SouthTerrain"]
albedo_color = Color(0.38, 0.42, 0.32, 1)
roughness = 0.95

[sub_resource type="StandardMaterial3D" id="Mat_CanalBed"]
albedo_color = Color(0.22, 0.2, 0.18, 1)
roughness = 0.98

[sub_resource type="StandardMaterial3D" id="Mat_CanalRevetment"]
albedo_color = Color(0.52, 0.53, 0.55, 1)
roughness = 0.85

[sub_resource type="StandardMaterial3D" id="Mat_AsphaltRoad"]
albedo_color = Color(0.18, 0.19, 0.21, 1)
roughness = 0.82

[sub_resource type="StandardMaterial3D" id="Mat_RoadYellowStripe"]
albedo_color = Color(0.94, 0.8, 0.12, 1)
roughness = 0.5

[sub_resource type="StandardMaterial3D" id="Mat_ConcreteSidewalk"]
albedo_color = Color(0.68, 0.67, 0.65, 1)
roughness = 0.88

[sub_resource type="StandardMaterial3D" id="Mat_OpenDrain"]
albedo_color = Color(0.25, 0.24, 0.22, 1)
roughness = 0.95

[sub_resource type="StandardMaterial3D" id="Mat_BoundaryWall"]
albedo_color = Color(0.62, 0.35, 0.28, 1)
roughness = 0.92

[sub_resource type="StandardMaterial3D" id="Mat_BrickGoliPaving"]
albedo_color = Color(0.58, 0.32, 0.25, 1)
roughness = 0.88
"""

    content = [header]

    # Root Node
    content.append("""[node name="District01PadmaBuriganga" type="Node3D"]
script = ExtResource("1_controller")
""")

    # World Environment & Directional Light
    content.append("""[node name="WorldEnvironment" type="WorldEnvironment" parent="."]
environment = SubResource("Environment_district")

[node name="SunLight" type="DirectionalLight3D" parent="."]
transform = Transform3D(0.819152, -0.40558, 0.40558, 0, 0.707107, 0.707107, -0.573576, -0.579228, 0.579228, 0, 45, 0)
light_color = Color(1, 0.96, 0.9, 1)
light_energy = 1.25
shadow_enabled = true
shadow_bias = 0.04
directional_shadow_max_distance = 250.0

[node name="WeatherSystem" type="Node3D" parent="." node_paths=PackedStringArray("sun_light", "world_env")]
script = ExtResource("2_weather")
sun_light = NodePath("../SunLight")
world_env = NodePath("../WorldEnvironment")
""")

    # 400m x 400m Terrain Base
    # North Urban Ground: X in [-200, 200], Z in [-200, +28], width 400, depth 228, Y = -0.5
    # Canal Depression: X in [-200, 200], Z in [+28, +72], bed at Y = -3.2, depth 44
    # South Rural/Workshop Ground: X in [-200, 200], Z in [+72, +200], width 400, depth 128, Y = -0.5
    content.append("""[node name="Terrain" type="Node3D" parent="."]

[node name="NorthGroundBlock" type="CSGBox3D" parent="Terrain"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, -86)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(400, 1, 228)
material = SubResource("Mat_NorthTerrain")

[node name="CanalBed" type="CSGBox3D" parent="Terrain"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -3.2, 50)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(400, 1, 44)
material = SubResource("Mat_CanalBed")

[node name="CanalNorthRevetment" type="CSGBox3D" parent="Terrain"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -1.5, 27.5)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(400, 3, 1)
material = SubResource("Mat_CanalRevetment")

[node name="CanalSouthRevetment" type="CSGBox3D" parent="Terrain"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -1.5, 72.5)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(400, 3, 1)
material = SubResource("Mat_CanalRevetment")

[node name="SouthGroundBlock" type="CSGBox3D" parent="Terrain"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 136)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(400, 1, 128)
material = SubResource("Mat_SouthTerrain")

[node name="GhatStepsBlock" type="CSGCombiner3D" parent="Terrain"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -38, 0, 28)
use_collision = true
collision_layer = 1
collision_mask = 31

[node name="GhatStep1" type="CSGBox3D" parent="Terrain/GhatStepsBlock"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.3, 1)
size = Vector3(14, 0.4, 2)
material = SubResource("Mat_CanalRevetment")

[node name="GhatStep2" type="CSGBox3D" parent="Terrain/GhatStepsBlock"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.7, 2.5)
size = Vector3(14, 0.4, 2)
material = SubResource("Mat_CanalRevetment")

[node name="GhatStep3" type="CSGBox3D" parent="Terrain/GhatStepsBlock"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -1.1, 4)
size = Vector3(14, 0.4, 2)
material = SubResource("Mat_CanalRevetment")

[node name="WaterSurface" parent="Terrain" instance=ExtResource("7_water")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -1.2, 50)
""")

    # Road Network
    content.append("""[node name="RoadNetwork" type="Node3D" parent="." groups=["road_network"]]
script = ExtResource("25_roadnet")

[node name="MainRoadNorthAsphalt" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.05, -85)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(8, 0.1, 230)
material = SubResource("Mat_AsphaltRoad")

[node name="MainRoadSouthAsphalt" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.05, 135)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(8, 0.1, 130)
material = SubResource("Mat_AsphaltRoad")

[node name="MainRoadNorthDivider" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.11, -85)
size = Vector3(0.2, 0.02, 230)
material = SubResource("Mat_RoadYellowStripe")

[node name="MainRoadSouthDivider" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.11, 135)
size = Vector3(0.2, 0.02, 130)
material = SubResource("Mat_RoadYellowStripe")

[node name="MainRoadWestSidewalkNorth" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -5.2, 0.15, -85)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(2.4, 0.2, 230)
material = SubResource("Mat_ConcreteSidewalk")

[node name="MainRoadEastSidewalkNorth" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 5.2, 0.15, -85)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(2.4, 0.2, 230)
material = SubResource("Mat_ConcreteSidewalk")

[node name="MainRoadWestSidewalkSouth" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -5.2, 0.15, 135)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(2.4, 0.2, 130)
material = SubResource("Mat_ConcreteSidewalk")

[node name="MainRoadEastSidewalkSouth" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 5.2, 0.15, 135)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(2.4, 0.2, 130)
material = SubResource("Mat_ConcreteSidewalk")

[node name="OpenDrainWest" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -6.8, -0.15, -85)
size = Vector3(0.8, 0.5, 230)
material = SubResource("Mat_OpenDrain")

[node name="OpenDrainEast" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 6.8, -0.15, -85)
size = Vector3(0.8, 0.5, 230)
material = SubResource("Mat_OpenDrain")

[node name="BazaarAvenueAsphalt" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -25, 0.05, -38)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(180, 0.1, 7)
material = SubResource("Mat_AsphaltRoad")

[node name="BazaarAvenueSidewalkNorth" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -25, 0.15, -42.2)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(180, 0.2, 1.4)
material = SubResource("Mat_ConcreteSidewalk")

[node name="BazaarAvenueSidewalkSouth" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -25, 0.15, -33.8)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(180, 0.2, 1.4)
material = SubResource("Mat_ConcreteSidewalk")

[node name="ResidentialGoliPaving" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -95, 0.06, -105)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(4.0, 0.1, 130)
material = SubResource("Mat_BrickGoliPaving")

[node name="WorkshopLanePaving" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -40, 0.06, 95)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(70, 0.1, 5.5)
material = SubResource("Mat_AsphaltRoad")

[node name="RiversideGhatLane" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -45, 0.06, 24)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(80, 0.1, 4.5)
material = SubResource("Mat_BrickGoliPaving")

[node name="CanalBridge" parent="RoadNetwork" instance=ExtResource("6_bridge")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 50)

[node name="TrafficLightIntersection" parent="." node_paths=PackedStringArray("road_network") instance=ExtResource("26_trafficlight")]
road_network = NodePath("../RoadNetwork")

[node name="PedestrianSystem" type="Node3D" parent="."]
script = ExtResource("27_pedsys")
pedestrian_density = 0.8
max_pedestrians = 32

[node name="TrafficSystem" type="Node3D" parent="." node_paths=PackedStringArray("road_network")]
script = ExtResource("28_trafficsys")
traffic_density = 0.75
max_traffic_vehicles = 14
road_network = NodePath("../RoadNetwork")

[node name="PoliceSystem" type="Node" parent="." groups=["police_system"]]
script = ExtResource("29_policesys")

[node name="PoliceRadarHUD" parent="." instance=ExtResource("30_radarhud")]

[node name="PoliceCheckpoint" parent="." instance=ExtResource("31_checkpoint")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 48)
""")

    # Boundary Walls (Lining alleys and compounds)
    content.append("""[node name="BoundaryWalls" type="Node3D" parent="."]

[node name="GoliWallWest" type="CSGBox3D" parent="BoundaryWalls"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -97.3, 1.2, -105)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(0.5, 2.4, 130)
material = SubResource("Mat_BoundaryWall")

[node name="GoliWallEast1" type="CSGBox3D" parent="BoundaryWalls"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -92.7, 1.2, -75)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(0.5, 2.4, 60)
material = SubResource("Mat_BoundaryWall")

[node name="GoliWallEast2" type="CSGBox3D" parent="BoundaryWalls"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -92.7, 1.2, -145)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(0.5, 2.4, 50)
material = SubResource("Mat_BoundaryWall")

[node name="ThanaPerimeterWallNorth" type="CSGBox3D" parent="BoundaryWalls"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 75, 1.4, -135)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(60, 2.8, 0.5)
material = SubResource("Mat_BoundaryWall")

[node name="ThanaPerimeterWallEast" type="CSGBox3D" parent="BoundaryWalls"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 105, 1.4, -105)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(0.5, 2.8, 60)
material = SubResource("Mat_BoundaryWall")

[node name="ThanaPerimeterWallSouth" type="CSGBox3D" parent="BoundaryWalls"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 75, 1.4, -75)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(60, 2.8, 0.5)
material = SubResource("Mat_BoundaryWall")

[node name="ThanaPerimeterWallWest" type="CSGBox3D" parent="BoundaryWalls"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 45, 1.4, -120)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(0.5, 2.8, 30)
material = SubResource("Mat_BoundaryWall")
""")

    # 10 Landmarks
    content.append("""[node name="Landmarks" type="Node3D" parent="."]

[node name="CommercialMarketBlock1" parent="Landmarks" instance=ExtResource("10_market")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -48, 0, -48)

[node name="CommercialMarketBlock2" parent="Landmarks" instance=ExtResource("10_market")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -76, 0, -48)

[node name="BismillahTeaStall" parent="Landmarks" instance=ExtResource("13_tong")]
unique_name_in_owner = true
transform = Transform3D(0.965926, 0, -0.258819, 0, 1, 0, 0.258819, 0, 0.965926, -11.5, 0.15, -31)

[node name="CngBusStand" parent="Landmarks" instance=ExtResource("14_cngstand")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 42, 0, -18)

[node name="ParkedRickshaw" parent="Landmarks" instance=ExtResource("5_rickshaw")]
transform = Transform3D(0.866025, 0, 0.5, 0, 1, 0, -0.5, 0, 0.866025, 36, 0.15, -12)

[node name="PoliceStation" parent="Landmarks" instance=ExtResource("11_police")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 75, 0, -105)

[node name="ThanaGuardOfficer" parent="Landmarks" instance=ExtResource("33_policeofficer")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 75, 0.2, -96)

[node name="AutoWorkshop" parent="Landmarks" instance=ExtResource("12_workshop")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -48, 0, 96)

[node name="ResidentialFlats1" parent="Landmarks" instance=ExtResource("15_flats")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -125, 0, -85)

[node name="ResidentialFlats2" parent="Landmarks" instance=ExtResource("15_flats")]
transform = Transform3D(-4.37114e-08, 0, 1, 0, 1, 0, -1, 0, -4.37114e-08, -135, 0, -135)

[node name="ResidentialFlats3" parent="Landmarks" instance=ExtResource("15_flats")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -65, 0, -140)

[node name="TinRoofHouse1" parent="Landmarks" instance=ExtResource("16_tinhouse")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -85, 0, -85)

[node name="TinRoofHouse2" parent="Landmarks" instance=ExtResource("16_tinhouse")]
transform = Transform3D(0.707107, 0, 0.707107, 0, 1, 0, -0.707107, 0, 0.707107, -85, 0, -120)

[node name="TinRoofHouse3" parent="Landmarks" instance=ExtResource("16_tinhouse")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -115, 0, -165)
""")

    # Open-World District Vehicles
    content.append("""[node name="DistrictVehicles" type="Node3D" parent="."]

[node name="ShonarToronSedan" parent="DistrictVehicles" instance=ExtResource("19_sedan")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 3.8, 0.45, -28)

[node name="DhakaGreenCNG" parent="DistrictVehicles" instance=ExtResource("20_cng")]
transform = Transform3D(0.965926, 0, -0.258819, 0, 1, 0, 0.258819, 0, 0.965926, 48, 0.4, -16)

[node name="DhakaCityBus" parent="DistrictVehicles" instance=ExtResource("21_bus")]
transform = Transform3D(0.965926, 0, 0.258819, 0, 1, 0, -0.258819, 0, 0.965926, 48, 0.6, -38)

[node name="MeghnaExplorerSUV" parent="DistrictVehicles" instance=ExtResource("22_suv")]
transform = Transform3D(-1, 0, -8.74228e-08, 0, 1, 0, 8.74228e-08, 0, -1, -44, 0.45, 92)

[node name="Bikrom150RMotorcycle" parent="DistrictVehicles" instance=ExtResource("23_bike")]
transform = Transform3D(0.866025, 0, 0.5, 0, 1, 0, -0.5, 0, 0.866025, -14, 0.35, -24)

[node name="PadmaPickupTruck" parent="DistrictVehicles" instance=ExtResource("24_pickup")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 65, 0.45, -95)

[node name="DMPPoliceCruiser" parent="DistrictVehicles" instance=ExtResource("32_policesedan")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 82, 0.45, -98)
""")

    # Infrastructure: Electric Poles
    content.append("""[node name="ElectricPoles" type="Node3D" parent="."]
""")
    pole_coords = [
        # Along Main Road East Sidewalk
        (6.8, -170), (6.8, -125), (6.8, -80), (6.8, -35), (6.8, 10), (6.8, 85), (6.8, 130), (6.8, 175),
        # Along Bazaar Avenue North Sidewalk
        (-130, -42), (-95, -42), (-60, -42), (-25, -42), (25, -42), (70, -42), (110, -42),
        # Along Residential Goli
        (-93, -70), (-93, -105), (-93, -140),
        # Near Auto Workshop
        (-48, 88), (-70, 95)
    ]
    for i, (px, pz) in enumerate(pole_coords, start=1):
        content.append(f"""[node name="ElectricPole_{i}" parent="ElectricPoles" instance=ExtResource("8_pole")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {px}, 0, {pz})
""")

    # Infrastructure: Streetlights with SpotLight3D
    content.append("""[node name="Streetlights" type="Node3D" parent="."]
""")
    light_coords = [
        # Main Road West
        (-5.2, -150, 0), (-5.2, -100, 0), (-5.2, -50, 0), (-5.2, -15, 0), (-5.2, 85, 0), (-5.2, 135, 0), (-5.2, 170, 0),
        # Main Road East
        (5.2, -130, 3.14159), (5.2, -75, 3.14159), (5.2, 100, 3.14159), (5.2, 150, 3.14159),
        # Commercial Bazaar
        (-40, -41, 1.5708), (-70, -41, 1.5708), (-100, -41, 1.5708),
        # CNG Stand & Police Yard
        (35, -24, 0), (70, -80, 0)
    ]
    for i, (lx, lz, ry) in enumerate(light_coords, start=1):
        if ry == 0:
            rot_str = "1, 0, 0, 0, 1, 0, 0, 0, 1"
        elif abs(ry - 3.14159) < 0.01:
            rot_str = "-1, 0, -8.74228e-08, 0, 1, 0, 8.74228e-08, 0, -1"
        else: # 1.5708 rad = 90 deg
            rot_str = "0, 0, 1, 0, 1, 0, -1, 0, 0"
        content.append(f"""[node name="StreetLight_{i}" parent="Streetlights" instance=ExtResource("9_light")]
transform = Transform3D({rot_str}, {lx}, 0, {lz})
""")

    # Foliage: Coconut Palms & Ancient Banyan Trees
    content.append("""[node name="Foliage" type="Node3D" parent="."]

[node name="BanyanTreeTeaStall" parent="Foliage" instance=ExtResource("18_banyan")]
transform = Transform3D(1.15, 0, 0, 0, 1.15, 0, 0, 0, 1.15, -16.5, 0, -28)

[node name="BanyanTreeGhat" parent="Foliage" instance=ExtResource("18_banyan")]
transform = Transform3D(1.2, 0, 0, 0, 1.2, 0, 0, 0, 1.2, -45, 0, 24)
""")
    palm_coords = [
        # North Canal Bank
        (-170, 24), (-135, 25), (-100, 24), (-65, 25), (-20, 25), (20, 25), (60, 24), (100, 25), (145, 24), (180, 25),
        # South Canal Bank
        (-160, 75), (-120, 76), (-80, 75), (-35, 76), (25, 75), (75, 76), (115, 75), (155, 76),
        # Residential gardens & Courtyards
        (-145, -95), (-105, -135), (-75, -155), (-135, -165),
        # Thana Compound & Stand
        (55, -130), (95, -130), (52, -30)
    ]
    for i, (px, pz) in enumerate(palm_coords, start=1):
        content.append(f"""[node name="CoconutPalm_{i}" parent="Foliage" instance=ExtResource("17_palm")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {px}, 0, {pz})
""")

    # Player Instance
    content.append("""[node name="Player" parent="." instance=ExtResource("3_player")]
unique_name_in_owner = true
transform = Transform3D(0.965926, 0, 0.258819, 0, 1, 0, -0.258819, 0, 0.965926, -5.5, 0.2, -22)
""")

    # UI / HUD CanvasLayer
    content.append("""[node name="UI" type="CanvasLayer" parent="."]

[node name="HUD" parent="UI" instance=ExtResource("4_hud")]
""")

    # Write out to file
    with open(output_path, "w", encoding="utf-8") as f:
        f.writelines(content)
    
    print(f"Successfully generated {output_path} ({len(content)} blocks).")

if __name__ == "__main__":
    generate_district_scene()
