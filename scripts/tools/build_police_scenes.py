# ==============================================================================
# POLICE SCENES BUILDER
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Programmatically constructs Godot 4 scenes for:
#          1. vehicles/police/police_sedan.tscn
#          2. characters/police/police_officer.tscn
#          3. environment/police/police_checkpoint.tscn
# ==============================================================================
import os

def build_police_sedan_scene():
    out_path = r"vehicles/police/police_sedan.tscn"
    os.makedirs(os.path.dirname(out_path), exist_ok=True)

    content = """[gd_scene format=3 uid="uid://d3policesedan001"]

[ext_resource type="Script" path="res://vehicles/police/police_sedan.gd" id="1_psedan"]
[ext_resource type="Script" path="res://scripts/interaction/interactable.gd" id="2_interactable"]
[ext_resource type="Script" path="res://vehicles/vehicle_camera_3d.gd" id="3_camera"]
[ext_resource type="Script" path="res://scripts/police/police_vision_sensor.gd" id="4_sensor"]
[ext_resource type="Script" path="res://scripts/police/police_vehicle_agent.gd" id="5_agent"]
[ext_resource type="Texture2D" path="res://assets/textures/signboards/police_car_decal.png" id="6_decal"]
[ext_resource type="AudioStream" path="res://audio/vehicles/engine_sedan_loop.wav" id="7_enginesound"]
[ext_resource type="AudioStream" path="res://audio/vehicles/horn_sedan.wav" id="8_hornsound"]
[ext_resource type="AudioStream" path="res://audio/vehicles/tire_skid.wav" id="9_skidsound"]
[ext_resource type="AudioStream" path="res://audio/vehicles/vehicle_impact.wav" id="10_impactsound"]
[ext_resource type="AudioStream" path="res://audio/police/siren_wail.wav" id="11_siren"]

[sub_resource type="BoxShape3D" id="BoxShape3D_chassis"]
size = Vector3(1.85, 0.95, 4.5)

[sub_resource type="BoxShape3D" id="BoxShape3D_cabin"]
size = Vector3(1.6, 0.65, 2.3)

[sub_resource type="CylinderShape3D" id="CylinderShape3D_interact"]
height = 2.0
radius = 2.5

[sub_resource type="StandardMaterial3D" id="Mat_PoliceWhite"]
albedo_color = Color(0.95, 0.95, 0.97, 1)
metallic = 0.5
roughness = 0.35

[sub_resource type="StandardMaterial3D" id="Mat_PoliceNavy"]
albedo_color = Color(0.08, 0.16, 0.35, 1)
metallic = 0.7
roughness = 0.3

[sub_resource type="StandardMaterial3D" id="Mat_PoliceDecal"]
albedo_texture = ExtResource("6_decal")
roughness = 0.3
transparency = 1

[sub_resource type="StandardMaterial3D" id="Mat_RedBeacon"]
albedo_color = Color(0.95, 0.1, 0.1, 1)
emission_enabled = true
emission = Color(1.0, 0.1, 0.1, 1)
emission_energy_multiplier = 4.0

[sub_resource type="StandardMaterial3D" id="Mat_BlueBeacon"]
albedo_color = Color(0.1, 0.3, 0.95, 1)
emission_enabled = true
emission = Color(0.1, 0.35, 1.0, 1)
emission_energy_multiplier = 4.0

[sub_resource type="StandardMaterial3D" id="Mat_TintedGlass"]
albedo_color = Color(0.1, 0.15, 0.2, 0.85)
metallic = 0.6
roughness = 0.1
transparency = 1

[sub_resource type="StandardMaterial3D" id="Mat_TireRubber"]
albedo_color = Color(0.12, 0.12, 0.13, 1)
roughness = 0.92

[sub_resource type="StandardMaterial3D" id="Mat_SteelRim"]
albedo_color = Color(0.3, 0.32, 0.35, 1)
metallic = 0.8
roughness = 0.25

[sub_resource type="CylinderMesh" id="CylinderMesh_wheel"]
material = SubResource("Mat_TireRubber")
top_radius = 0.32
bottom_radius = 0.32
height = 0.24
radial_segments = 16

[sub_resource type="CylinderMesh" id="CylinderMesh_rim"]
material = SubResource("Mat_SteelRim")
top_radius = 0.22
bottom_radius = 0.22
height = 0.25
radial_segments = 12

[node name="PolicePatrolSedan" type="VehicleBody3D" groups=["damageables", "police_vehicles", "vehicles"]]
mass = 1450.0
center_of_mass_mode = 1
center_of_mass = Vector3(0, -0.15, 0)
script = ExtResource("1_psedan")
vehicle_name = "DMP Police Patrol Cruiser"
max_engine_force = 480.0
max_brake_force = 55.0
base_max_speed_kmh = 175.0
max_health = 140.0

[node name="ChassisCollision" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.55, 0)
shape = SubResource("BoxShape3D_chassis")

[node name="CabinCollision" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.25, -0.15)
shape = SubResource("BoxShape3D_cabin")

[node name="VisualModel" type="Node3D" parent="."]

[node name="BodyLower" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.5, 0)
size = Vector3(1.82, 0.55, 4.48)
material = SubResource("Mat_PoliceWhite")

[node name="NavySideStripeLeft" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -0.92, 0.52, 0)
size = Vector3(0.04, 0.35, 3.2)
material = SubResource("Mat_PoliceNavy")

[node name="NavySideStripeRight" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.92, 0.52, 0)
size = Vector3(0.04, 0.35, 3.2)
material = SubResource("Mat_PoliceNavy")

[node name="DecalLeft" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -0.93, 0.52, 0)
size = Vector3(0.02, 0.32, 0.64)
material = SubResource("Mat_PoliceDecal")

[node name="DecalRight" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(-1, 0, -8.74228e-08, 0, 1, 0, 8.74228e-08, 0, -1, 0.93, 0.52, 0)
size = Vector3(0.02, 0.32, 0.64)
material = SubResource("Mat_PoliceDecal")

[node name="HoodSlope" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 0.984808, -0.173648, 0, 0.173648, 0.984808, 0, 0.72, -1.5)
size = Vector3(1.78, 0.15, 1.3)
material = SubResource("Mat_PoliceNavy")

[node name="CabinRoof" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.48, -0.15)
size = Vector3(1.5, 0.08, 2.0)
material = SubResource("Mat_PoliceWhite")

[node name="Windshield" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 0.819152, 0.573576, 0, -0.573576, 0.819152, 0, 1.15, -1.0)
size = Vector3(1.48, 0.08, 0.85)
material = SubResource("Mat_TintedGlass")

[node name="RearWindshield" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 0.866025, -0.5, 0, 0.5, 0.866025, 0, 1.18, 0.78)
size = Vector3(1.48, 0.08, 0.8)
material = SubResource("Mat_TintedGlass")

[node name="Lightbar" type="Node3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.58, -0.15)

[node name="MountBase" type="CSGBox3D" parent="Lightbar"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0)
size = Vector3(1.1, 0.06, 0.22)
material = SubResource("Mat_PoliceNavy")

[node name="RedMesh" type="CSGBox3D" parent="Lightbar"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -0.32, 0.07, 0)
size = Vector3(0.42, 0.09, 0.18)
material = SubResource("Mat_RedBeacon")

[node name="BlueMesh" type="CSGBox3D" parent="Lightbar"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.32, 0.07, 0)
size = Vector3(0.42, 0.09, 0.18)
material = SubResource("Mat_BlueBeacon")

[node name="RedLight" type="OmniLight3D" parent="Lightbar"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -0.35, 0.2, 0)
light_color = Color(1, 0.15, 0.15, 1)
light_energy = 5.0
omni_range = 14.0

[node name="BlueLight" type="OmniLight3D" parent="Lightbar"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.35, 0.2, 0)
light_color = Color(0.15, 0.35, 1, 1)
light_energy = 5.0
omni_range = 14.0

[node name="VisionSensor" type="Node3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.4, -2.0)
script = ExtResource("4_sensor")
fov_degrees = 135.0
base_view_distance = 42.0

[node name="PoliceVehicleAgent" type="Node" parent="."]
script = ExtResource("5_agent")

[node name="Audio" type="Node3D" parent="."]

[node name="EngineAudio" type="AudioStreamPlayer3D" parent="Audio"]
stream = ExtResource("7_enginesound")
volume_db = -4.0
max_distance = 35.0

[node name="HornAudio" type="AudioStreamPlayer3D" parent="Audio"]
stream = ExtResource("8_hornsound")
volume_db = 2.0
max_distance = 50.0

[node name="SkidAudio" type="AudioStreamPlayer3D" parent="Audio"]
stream = ExtResource("9_skidsound")
volume_db = -2.0
max_distance = 30.0

[node name="ImpactAudio" type="AudioStreamPlayer3D" parent="Audio"]
stream = ExtResource("10_impactsound")
volume_db = 4.0
max_distance = 45.0

[node name="SirenAudio" type="AudioStreamPlayer3D" parent="Audio"]
stream = ExtResource("11_siren")
volume_db = 6.0
max_distance = 80.0
attenuation_model = 1

[node name="WheelFrontLeft" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -0.85, 0.32, -1.35)
use_as_steering = true
wheel_roll_influence = 0.35
wheel_radius = 0.32
wheel_rest_length = 0.15
wheel_friction_slip = 3.2
suspension_stiffness = 38.0
suspension_max_force = 12000.0

[node name="TireMesh" type="MeshInstance3D" parent="WheelFrontLeft"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_wheel")

[node name="RimMesh" type="MeshInstance3D" parent="WheelFrontLeft"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_rim")

[node name="WheelFrontRight" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.85, 0.32, -1.35)
use_as_steering = true
wheel_roll_influence = 0.35
wheel_radius = 0.32
wheel_rest_length = 0.15
wheel_friction_slip = 3.2
suspension_stiffness = 38.0
suspension_max_force = 12000.0

[node name="TireMesh" type="MeshInstance3D" parent="WheelFrontRight"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_wheel")

[node name="RimMesh" type="MeshInstance3D" parent="WheelFrontRight"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_rim")

[node name="WheelRearLeft" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -0.85, 0.32, 1.35)
use_as_traction = true
wheel_roll_influence = 0.35
wheel_radius = 0.32
wheel_rest_length = 0.15
wheel_friction_slip = 3.4
suspension_stiffness = 40.0
suspension_max_force = 14000.0

[node name="TireMesh" type="MeshInstance3D" parent="WheelRearLeft"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_wheel")

[node name="RimMesh" type="MeshInstance3D" parent="WheelRearLeft"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_rim")

[node name="WheelRearRight" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.85, 0.32, 1.35)
use_as_traction = true
wheel_roll_influence = 0.35
wheel_radius = 0.32
wheel_rest_length = 0.15
wheel_friction_slip = 3.4
suspension_stiffness = 40.0
suspension_max_force = 14000.0

[node name="TireMesh" type="MeshInstance3D" parent="WheelRearRight"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_wheel")

[node name="RimMesh" type="MeshInstance3D" parent="WheelRearRight"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_rim")

[node name="InteractableArea" type="Area3D" parent="."]
script = ExtResource("2_interactable")
prompt_text = "Drive Police Patrol Cruiser"

[node name="CollisionShape3D" type="CollisionShape3D" parent="InteractableArea"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.8, 0)
shape = SubResource("CylinderShape3D_interact")

[node name="VehicleCamera3D" type="Camera3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 0.965926, 0.258819, 0, -0.258819, 0.965926, 0, 2.4, 5.2)
script = ExtResource("3_camera")
"""
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Generated: {out_path}")


def build_police_officer_scene():
    out_path = r"characters/police/police_officer.tscn"
    os.makedirs(os.path.dirname(out_path), exist_ok=True)

    content = """[gd_scene format=3 uid="uid://d3policeofficer001"]

[ext_resource type="Script" path="res://scripts/police/police_officer.gd" id="1_officer"]
[ext_resource type="Script" path="res://scripts/police/police_vision_sensor.gd" id="2_sensor"]
[ext_resource type="AudioStream" path="res://audio/police/police_whistle.wav" id="3_whistle"]
[ext_resource type="AudioStream" path="res://audio/police/police_radio.wav" id="4_radio"]
[ext_resource type="AudioStream" path="res://audio/city/crossing_beep.wav" id="5_shoot"]

[sub_resource type="CapsuleShape3D" id="CapsuleShape3D_officer"]
radius = 0.35
height = 1.75

[sub_resource type="StandardMaterial3D" id="Mat_SkinTone"]
albedo_color = Color(0.72, 0.52, 0.38, 1)
roughness = 0.75

[sub_resource type="StandardMaterial3D" id="Mat_PoliceShirt"]
albedo_color = Color(0.12, 0.22, 0.42, 1)
roughness = 0.65

[sub_resource type="StandardMaterial3D" id="Mat_PoliceTrousers"]
albedo_color = Color(0.12, 0.14, 0.18, 1)
roughness = 0.85

[sub_resource type="StandardMaterial3D" id="Mat_PoliceCap"]
albedo_color = Color(0.08, 0.14, 0.28, 1)
roughness = 0.5

[sub_resource type="StandardMaterial3D" id="Mat_GoldBadge"]
albedo_color = Color(0.92, 0.78, 0.18, 1)
metallic = 0.9
roughness = 0.2

[sub_resource type="StandardMaterial3D" id="Mat_BambooLathi"]
albedo_color = Color(0.78, 0.65, 0.35, 1)
roughness = 0.6

[sub_resource type="StandardMaterial3D" id="Mat_GunSteel"]
albedo_color = Color(0.2, 0.22, 0.25, 1)
metallic = 0.85
roughness = 0.3

[sub_resource type="Animation" id="Animation_idle"]
resource_name = "idle"
length = 2.0
loop_mode = 1
tracks/0/type = "value"
tracks/0/imported = false
tracks/0/enabled = true
tracks/0/path = NodePath("VisualRoot/Torso:position")
tracks/0/interp = 2
tracks/0/loop_wrap = true
tracks/0/keys = {
"times": PackedFloat32Array(0, 1.0, 2.0),
"transitions": PackedFloat32Array(1, 1, 1),
"update": 0,
"values": [Vector3(0, 1.05, 0), Vector3(0, 1.07, 0), Vector3(0, 1.05, 0)]
}

[sub_resource type="Animation" id="Animation_walk"]
resource_name = "walk"
length = 0.8
loop_mode = 1
tracks/0/type = "value"
tracks/0/imported = false
tracks/0/enabled = true
tracks/0/path = NodePath("VisualRoot:position")
tracks/0/interp = 2
tracks/0/loop_wrap = true
tracks/0/keys = {
"times": PackedFloat32Array(0, 0.2, 0.4, 0.6, 0.8),
"transitions": PackedFloat32Array(1, 1, 1, 1, 1),
"update": 0,
"values": [Vector3(0, 0, 0), Vector3(0, 0.05, 0), Vector3(0, 0, 0), Vector3(0, 0.05, 0), Vector3(0, 0, 0)]
}

[sub_resource type="Animation" id="Animation_run"]
resource_name = "run"
length = 0.5
loop_mode = 1
tracks/0/type = "value"
tracks/0/imported = false
tracks/0/enabled = true
tracks/0/path = NodePath("VisualRoot:position")
tracks/0/interp = 2
tracks/0/loop_wrap = true
tracks/0/keys = {
"times": PackedFloat32Array(0, 0.12, 0.25, 0.38, 0.5),
"transitions": PackedFloat32Array(1, 1, 1, 1, 1),
"update": 0,
"values": [Vector3(0, 0, 0), Vector3(0, 0.1, 0), Vector3(0, 0, 0), Vector3(0, 0.1, 0), Vector3(0, 0, 0)]
}

[sub_resource type="AnimationLibrary" id="AnimationLibrary_officer"]
_data = {
"idle": SubResource("Animation_idle"),
"run": SubResource("Animation_run"),
"walk": SubResource("Animation_walk")
}

[node name="PoliceOfficer" type="CharacterBody3D" groups=["damageables", "police_officers"]]
collision_layer = 8
collision_mask = 7
script = ExtResource("1_officer")
officer_name = "DMP Police Constable"
walk_speed = 2.6
run_speed = 7.0
max_health = 110.0

[node name="CollisionShape3D" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.88, 0)
shape = SubResource("CapsuleShape3D_officer")

[node name="VisionSensor" type="Node3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.55, 0)
script = ExtResource("2_sensor")
fov_degrees = 120.0
base_view_distance = 38.0

[node name="AudioWhistle" type="AudioStreamPlayer3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.5, 0)
stream = ExtResource("3_whistle")
volume_db = 4.0
max_distance = 45.0

[node name="AudioRadio" type="AudioStreamPlayer3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.2, 0)
stream = ExtResource("4_radio")
volume_db = 2.0
max_distance = 25.0

[node name="AudioShoot" type="AudioStreamPlayer3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.3, -0.4)
stream = ExtResource("5_shoot")
volume_db = 5.0
max_distance = 60.0

[node name="VisualRoot" type="Node3D" parent="."]

[node name="Head" type="CSGSphere3D" parent="VisualRoot"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.55, 0)
radius = 0.18
material = SubResource("Mat_SkinTone")

[node name="PoliceCap" type="CSGCylinder3D" parent="VisualRoot/Head"]
transform = Transform3D(1, 0, 0, 0, 0.984808, 0.173648, 0, -0.173648, 0.984808, 0, 0.15, -0.02)
radius = 0.22
height = 0.14
material = SubResource("Mat_PoliceCap")

[node name="CapVisor" type="CSGBox3D" parent="VisualRoot/Head/PoliceCap"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.05, -0.16)
size = Vector3(0.24, 0.02, 0.12)
material = SubResource("Mat_PoliceTrousers")

[node name="CapBadge" type="CSGBox3D" parent="VisualRoot/Head/PoliceCap"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.02, -0.22)
size = Vector3(0.06, 0.06, 0.02)
material = SubResource("Mat_GoldBadge")

[node name="Torso" type="CSGBox3D" parent="VisualRoot"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.05, 0)
size = Vector3(0.48, 0.65, 0.28)
material = SubResource("Mat_PoliceShirt")

[node name="ChestBadge" type="CSGBox3D" parent="VisualRoot/Torso"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -0.14, 0.15, -0.15)
size = Vector3(0.06, 0.07, 0.02)
material = SubResource("Mat_GoldBadge")

[node name="UtilityBelt" type="CSGBox3D" parent="VisualRoot/Torso"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.3, 0)
size = Vector3(0.5, 0.1, 0.3)
material = SubResource("Mat_PoliceTrousers")

[node name="Legs" type="CSGBox3D" parent="VisualRoot"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.42, 0)
size = Vector3(0.42, 0.72, 0.25)
material = SubResource("Mat_PoliceTrousers")

[node name="RightHand" type="Node3D" parent="VisualRoot"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.32, 0.95, -0.18)

[node name="Baton" type="CSGCylinder3D" parent="VisualRoot/RightHand"]
transform = Transform3D(1, 0, 0, 0, 0.866025, 0.5, 0, -0.5, 0.866025, 0, 0.15, 0)
radius = 0.025
height = 0.85
material = SubResource("Mat_BambooLathi")

[node name="Gun" type="Node3D" parent="VisualRoot/RightHand"]
visible = false

[node name="GunBody" type="CSGBox3D" parent="VisualRoot/RightHand/Gun"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, -0.1)
size = Vector3(0.06, 0.12, 0.22)
material = SubResource("Mat_GunSteel")

[node name="MuzzleFlash" type="OmniLight3D" parent="VisualRoot/RightHand/Gun"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.05, -0.28)
visible = false
light_color = Color(1, 0.8, 0.3, 1)
light_energy = 6.0
omni_range = 8.0

[node name="AnimationPlayer" type="AnimationPlayer" parent="."]
libraries = {
"": SubResource("AnimationLibrary_officer")
}
autoplay = "idle"
"""
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Generated: {out_path}")


def build_police_checkpoint_scene():
    out_path = r"environment/police/police_checkpoint.tscn"
    os.makedirs(os.path.dirname(out_path), exist_ok=True)

    content = """[gd_scene format=3 uid="uid://d3policecheckpoint001"]

[ext_resource type="Script" path="res://scripts/police/police_checkpoint.gd" id="1_checkpoint"]
[ext_resource type="Texture2D" path="res://assets/textures/signboards/checkpoint_barrier_stripes.png" id="2_stripes"]
[ext_resource type="Texture2D" path="res://assets/textures/signboards/sign_checkpoint.png" id="3_sign"]
[ext_resource type="AudioStream" path="res://audio/police/spike_puncture.wav" id="4_puncture"]
[ext_resource type="PackedScene" path="res://characters/police/police_officer.tscn" id="5_officer"]

[sub_resource type="StandardMaterial3D" id="Mat_BarrierStripes"]
albedo_texture = ExtResource("2_stripes")
roughness = 0.5

[sub_resource type="StandardMaterial3D" id="Mat_SignboardCheckpoint"]
albedo_texture = ExtResource("3_sign")
roughness = 0.4

[sub_resource type="StandardMaterial3D" id="Mat_SteelSpikes"]
albedo_color = Color(0.25, 0.26, 0.28, 1)
metallic = 0.95
roughness = 0.2

[sub_resource type="StandardMaterial3D" id="Mat_OrangeCone"]
albedo_color = Color(1.0, 0.45, 0.05, 1)
roughness = 0.6

[sub_resource type="BoxShape3D" id="BoxShape3D_barrier"]
size = Vector3(4.5, 1.2, 0.6)

[sub_resource type="BoxShape3D" id="BoxShape3D_spikestrip"]
size = Vector3(5.5, 0.4, 1.2)

[node name="PoliceCheckpoint" type="Node3D"]
script = ExtResource("1_checkpoint")
checkpoint_id = "cp_padma_bridge"
checkpoint_name = "Canal Bridge DMP Roadblock"
activate_at_wanted_level = 3

[node name="BarricadeWest" type="StaticBody3D" parent="."]
transform = Transform3D(0.965926, 0, 0.258819, 0, 1, 0, -0.258819, 0, 0.965926, -3.2, 0, 0)
collision_layer = 1
collision_mask = 31

[node name="CollisionShape3D" type="CollisionShape3D" parent="BarricadeWest"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.6, 0)
shape = SubResource("BoxShape3D_barrier")

[node name="BarrierMesh" type="CSGBox3D" parent="BarricadeWest"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.6, 0)
size = Vector3(4.5, 1.2, 0.5)
material = SubResource("Mat_BarrierStripes")

[node name="BarricadeEast" type="StaticBody3D" parent="."]
transform = Transform3D(0.965926, 0, -0.258819, 0, 1, 0, 0.258819, 0, 0.965926, 3.2, 0, 0)
collision_layer = 1
collision_mask = 31

[node name="CollisionShape3D" type="CollisionShape3D" parent="BarricadeEast"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.6, 0)
shape = SubResource("BoxShape3D_barrier")

[node name="BarrierMesh" type="CSGBox3D" parent="BarricadeEast"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.6, 0)
size = Vector3(4.5, 1.2, 0.5)
material = SubResource("Mat_BarrierStripes")

[node name="SignboardPanel" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 2.6, 0)
size = Vector3(4.8, 1.2, 0.1)
material = SubResource("Mat_SignboardCheckpoint")

[node name="GantryPostLeft" type="CSGCylinder3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -2.5, 1.3, 0)
radius = 0.08
height = 2.6
material = SubResource("Mat_SteelSpikes")

[node name="GantryPostRight" type="CSGCylinder3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 2.5, 1.3, 0)
radius = 0.08
height = 2.6
material = SubResource("Mat_SteelSpikes")

[node name="HazardLights" type="Node3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 3.3, 0)

[node name="Light1" type="OmniLight3D" parent="HazardLights"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -1.8, 0, 0)
light_color = Color(1, 0.6, 0.1, 1)
light_energy = 4.0
omni_range = 10.0

[node name="Light2" type="OmniLight3D" parent="HazardLights"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 1.8, 0, 0)
light_color = Color(1, 0.1, 0.1, 1)
light_energy = 4.0
omni_range = 10.0

[node name="SpikeStripArea" type="Area3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.1, 1.2)
collision_layer = 128
collision_mask = 6

[node name="CollisionShape3D" type="CollisionShape3D" parent="SpikeStripArea"]
shape = SubResource("BoxShape3D_spikestrip")

[node name="SpikeStripBase" type="CSGBox3D" parent="SpikeStripArea"]
size = Vector3(5.2, 0.08, 0.8)
material = SubResource("Mat_SteelSpikes")

[node name="AudioPuncture" type="AudioStreamPlayer3D" parent="."]
stream = ExtResource("4_puncture")
volume_db = 4.0
max_distance = 45.0

[node name="Guards" type="Node3D" parent="."]

[node name="Officer1" parent="Guards" instance=ExtResource("5_officer")]
transform = Transform3D(0.866025, 0, 0.5, 0, 1, 0, -0.5, 0, 0.866025, -2.6, 0, -1.5)

[node name="Officer2" parent="Guards" instance=ExtResource("5_officer")]
transform = Transform3D(0.866025, 0, -0.5, 0, 1, 0, 0.5, 0, 0.866025, 2.6, 0, -1.5)
"""
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Generated: {out_path}")


if __name__ == "__main__":
    build_police_sedan_scene()
    build_police_officer_scene()
    build_police_checkpoint_scene()
    print("All police scenes successfully generated!")
