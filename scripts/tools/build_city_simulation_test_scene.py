# ==============================================================================
# CITY SIMULATION TEST SCENE GENERATOR
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Programmatically constructs tests/test_city_simulation.tscn
# ==============================================================================
import os

def generate_city_test_scene():
    output_path = r"tests/test_city_simulation.tscn"
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    content = """[gd_scene format=3 uid="uid://d3citytest001"]

[ext_resource type="Script" path="res://tests/test_city_simulation.gd" id="1_testcontroller"]
[ext_resource type="Script" path="res://world/traffic/road_network_3d.gd" id="2_roadnet"]
[ext_resource type="PackedScene" uid="uid://d3trafficlight001" path="res://world/traffic/traffic_light.tscn" id="3_trafficlight"]
[ext_resource type="Script" path="res://scripts/pedestrians/pedestrian_system.gd" id="4_pedsys"]
[ext_resource type="Script" path="res://world/traffic/traffic_system.gd" id="5_trafficsys"]
[ext_resource type="PackedScene" uid="uid://ciqrpd5675boy" path="res://player/player.tscn" id="6_player"]
[ext_resource type="PackedScene" uid="uid://bdahud001scene" path="res://ui/hud/hud.tscn" id="7_hud"]

[sub_resource type="ProceduralSkyMaterial" id="ProceduralSkyMaterial_monsoon"]
sky_top_color = Color(0.35, 0.58, 0.92, 1)
sky_horizon_color = Color(0.74, 0.82, 0.88, 1)
ground_bottom_color = Color(0.2, 0.22, 0.25, 1)
ground_horizon_color = Color(0.74, 0.82, 0.88, 1)

[sub_resource type="Sky" id="Sky_district"]
sky_material = SubResource("ProceduralSkyMaterial_monsoon")

[sub_resource type="Environment" id="Environment_city"]
background_mode = 2
sky = SubResource("Sky_district")
tonemap_mode = 2
glow_enabled = true
ssao_enabled = true

[sub_resource type="StandardMaterial3D" id="Mat_Ground"]
albedo_color = Color(0.38, 0.4, 0.42, 1)
roughness = 0.9

[sub_resource type="StandardMaterial3D" id="Mat_RoadAsphalt"]
albedo_color = Color(0.18, 0.19, 0.21, 1)
roughness = 0.82

[sub_resource type="StandardMaterial3D" id="Mat_YellowStripe"]
albedo_color = Color(0.94, 0.8, 0.12, 1)
roughness = 0.5

[sub_resource type="StandardMaterial3D" id="Mat_Sidewalk"]
albedo_color = Color(0.68, 0.67, 0.65, 1)
roughness = 0.88

[sub_resource type="StandardMaterial3D" id="Mat_ZebraWhite"]
albedo_color = Color(0.95, 0.95, 0.95, 1)
roughness = 0.6

[node name="TestCitySimulation" type="Node3D"]
script = ExtResource("1_testcontroller")

[node name="WorldEnvironment" type="WorldEnvironment" parent="."]
environment = SubResource("Environment_city")

[node name="SunLight" type="DirectionalLight3D" parent="."]
transform = Transform3D(0.819152, -0.40558, 0.40558, 0, 0.707107, 0.707107, -0.573576, -0.579228, 0.579228, 0, 35, 0)
light_color = Color(1, 0.98, 0.92, 1)
light_energy = 1.3
shadow_enabled = true

[node name="GroundBase" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 0)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(300, 1, 300)
material = SubResource("Mat_Ground")

[node name="RoadNetwork" type="Node3D" parent="." groups=["road_network"]]
script = ExtResource("2_roadnet")

[node name="MainRoadAsphalt" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.05, 0)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(8.0, 0.1, 280)
material = SubResource("Mat_RoadAsphalt")

[node name="MainRoadDivider" type="CSGBox3D" parent="MainRoadAsphalt"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.06, 0)
size = Vector3(0.2, 0.02, 280)
material = SubResource("Mat_YellowStripe")

[node name="BazaarAvenueAsphalt" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.05, -38)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(240, 0.1, 7.5)
material = SubResource("Mat_RoadAsphalt")

[node name="Sidewalks" type="Node3D" parent="."]

[node name="SidewalkMainWest" type="CSGBox3D" parent="Sidewalks"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -5.2, 0.15, 0)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(2.4, 0.2, 280)
material = SubResource("Mat_Sidewalk")

[node name="SidewalkMainEast" type="CSGBox3D" parent="Sidewalks"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 5.2, 0.15, 0)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(2.4, 0.2, 280)
material = SubResource("Mat_Sidewalk")

[node name="SidewalkBazaarNorth" type="CSGBox3D" parent="Sidewalks"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.15, -42.5)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(240, 0.2, 1.6)
material = SubResource("Mat_Sidewalk")

[node name="SidewalkBazaarSouth" type="CSGBox3D" parent="Sidewalks"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.15, -33.5)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(240, 0.2, 1.6)
material = SubResource("Mat_Sidewalk")

[node name="ZebraCrossings" type="Node3D" parent="."]

[node name="ZebraNorth" type="CSGBox3D" parent="ZebraCrossings"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.11, -44)
size = Vector3(6.5, 0.02, 2.4)
material = SubResource("Mat_ZebraWhite")

[node name="ZebraSouth" type="CSGBox3D" parent="ZebraCrossings"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.11, -32)
size = Vector3(6.5, 0.02, 2.4)
material = SubResource("Mat_ZebraWhite")

[node name="TrafficLightIntersection" parent="." node_paths=PackedStringArray("road_network") instance=ExtResource("3_trafficlight")]
road_network = NodePath("../RoadNetwork")

[node name="PedestrianSystem" type="Node3D" parent="."]
script = ExtResource("4_pedsys")
pedestrian_density = 0.8
max_pedestrians = 25

[node name="TrafficSystem" type="Node3D" parent="." node_paths=PackedStringArray("road_network")]
script = ExtResource("5_trafficsys")
traffic_density = 0.75
max_traffic_vehicles = 12
road_network = NodePath("../RoadNetwork")

[node name="Player" parent="." instance=ExtResource("6_player")]
unique_name_in_owner = true
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -5.2, 0.2, -25)

[node name="UI" type="CanvasLayer" parent="."]

[node name="HUD" parent="UI" instance=ExtResource("7_hud")]
"""

    with open(output_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Generated {output_path} successfully.")

if __name__ == "__main__":
    generate_city_test_scene()
