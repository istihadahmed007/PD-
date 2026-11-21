# ==============================================================================
# ALL VEHICLES BUILDER & FACTORY
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Programmatically constructs the complete suite of 8 Bangladesh-inspired
#          vehicles: Sedan, SUV, Motorcycle, CNG Auto-Rickshaw, Pedal Rickshaw,
#          Local Bus, Pickup Truck, and Delivery Van.
# ==============================================================================
import os

def ensure_dir(path):
    os.makedirs(path, exist_ok=True)

# ------------------------------------------------------------------------------
# 1. SUV (Meghna Explorer 4x4)
# ------------------------------------------------------------------------------
def build_suv():
    ensure_dir("vehicles/suv")
    script_path = "vehicles/suv/suv.gd"
    scene_path = "vehicles/suv/suv.tscn"

    with open(script_path, "w", encoding="utf-8") as f:
        f.write("""# ==============================================================================
# MEGHNA EXPLORER 4x4 SUV (VEHICLE SYSTEM)
# ==============================================================================
class_name SuvVehicle
extends BaseVehicle3D

func _ready() -> void:
	vehicle_name = "Meghna Explorer 4x4 SUV"
	max_engine_force = 520.0
	max_brake_force = 58.0
	base_max_speed_kmh = 175.0
	max_steer_angle_rad = deg_to_rad(32.0)
	high_speed_steer_angle_rad = deg_to_rad(11.0)
	steer_speed = 5.5
	max_health = 160.0
	super._ready()
""")

    scene_content = """[gd_scene format=3 uid="uid://d3suv001"]

[ext_resource type="Script" path="res://vehicles/suv/suv.gd" id="1_suv"]
[ext_resource type="Script" path="res://scripts/interaction/interactable.gd" id="2_interactable"]
[ext_resource type="Script" path="res://vehicles/vehicle_camera_3d.gd" id="3_camera"]
[ext_resource type="AudioStream" path="res://audio/vehicles/engine_suv_loop.wav" id="4_enginesound"]
[ext_resource type="AudioStream" path="res://audio/vehicles/horn_suv.wav" id="5_hornsound"]
[ext_resource type="AudioStream" path="res://audio/vehicles/tire_skid.wav" id="6_skidsound"]
[ext_resource type="AudioStream" path="res://audio/vehicles/vehicle_impact.wav" id="7_impactsound"]
[ext_resource type="AudioStream" path="res://audio/vehicles/car_door_open.wav" id="8_doorsound"]

[sub_resource type="BoxShape3D" id="BoxShape3D_chassis"]
size = Vector3(2.0, 1.1, 4.8)

[sub_resource type="BoxShape3D" id="BoxShape3D_cabin"]
size = Vector3(1.85, 0.85, 3.1)

[sub_resource type="CylinderShape3D" id="CylinderShape3D_interact"]
height = 2.2
radius = 2.6

[sub_resource type="StandardMaterial3D" id="Mat_SuvPaint"]
albedo_color = Color(0.85, 0.85, 0.88, 1)
metallic = 0.8
roughness = 0.3

[sub_resource type="StandardMaterial3D" id="Mat_BlackTrim"]
albedo_color = Color(0.12, 0.12, 0.14, 1)
roughness = 0.85

[sub_resource type="StandardMaterial3D" id="Mat_TintedGlass"]
albedo_color = Color(0.12, 0.15, 0.18, 0.88)
metallic = 0.5
roughness = 0.1
transparency = 1

[sub_resource type="StandardMaterial3D" id="Mat_HeadlightLens"]
albedo_color = Color(1, 0.98, 0.9, 1)
emission_enabled = true
emission = Color(1, 0.95, 0.85, 1)
emission_energy_multiplier = 4.0

[sub_resource type="StandardMaterial3D" id="Mat_TaillightLens"]
albedo_color = Color(0.85, 0.1, 0.1, 1)
emission_enabled = true
emission = Color(0.9, 0.05, 0.05, 1)
emission_energy_multiplier = 2.5

[sub_resource type="StandardMaterial3D" id="Mat_TireRubber"]
albedo_color = Color(0.12, 0.12, 0.13, 1)
roughness = 0.92

[sub_resource type="StandardMaterial3D" id="Mat_AlloyRim"]
albedo_color = Color(0.78, 0.8, 0.82, 1)
metallic = 0.85
roughness = 0.25

[sub_resource type="CylinderMesh" id="CylinderMesh_suv_wheel"]
material = SubResource("Mat_TireRubber")
top_radius = 0.42
bottom_radius = 0.42
height = 0.28
radial_segments = 16

[sub_resource type="CylinderMesh" id="CylinderMesh_suv_rim"]
material = SubResource("Mat_AlloyRim")
top_radius = 0.28
bottom_radius = 0.28
height = 0.29
radial_segments = 12

[node name="Suv" type="VehicleBody3D" groups=["damageables", "vehicles"]]
mass = 2150.0
center_of_mass_mode = 1
center_of_mass = Vector3(0, -0.05, 0)
script = ExtResource("1_suv")

[node name="ChassisCollision" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.75, 0)
shape = SubResource("BoxShape3D_chassis")

[node name="CabinCollision" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.45, 0.2)
shape = SubResource("BoxShape3D_cabin")

[node name="VisualModel" type="Node3D" parent="."]

[node name="BodyLower" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.72, 0)
size = Vector3(1.98, 0.7, 4.78)
material = SubResource("Mat_SuvPaint")

[node name="CabinUpper" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.42, 0.2)
size = Vector3(1.82, 0.8, 3.05)
material = SubResource("Mat_TintedGlass")

[node name="RoofRack" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.86, 0.2)
size = Vector3(1.4, 0.08, 2.4)
material = SubResource("Mat_BlackTrim")

[node name="BumperFront" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.58, -2.42)
size = Vector3(1.98, 0.45, 0.25)
material = SubResource("Mat_BlackTrim")

[node name="BumperRear" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.58, 2.42)
size = Vector3(1.98, 0.45, 0.25)
material = SubResource("Mat_BlackTrim")

[node name="SpareTireRear" type="CSGCylinder3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, -4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0.95, 2.52)
radius = 0.4
height = 0.24
material = SubResource("Mat_BlackTrim")

[node name="DriverDoor" type="Node3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -1.0, 0.65, -0.6)

[node name="DoorMesh" type="CSGBox3D" parent="DriverDoor"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.4, 0.55)
size = Vector3(0.08, 0.95, 1.1)
material = SubResource("Mat_SuvPaint")

[node name="WheelFrontLeft" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -0.92, 0.42, -1.45)
use_as_steering = true
use_as_traction = true
wheel_roll_influence = 0.15
wheel_radius = 0.42
wheel_rest_length = 0.18
wheel_friction_slip = 4.2
suspension_travel = 0.25
suspension_stiffness = 32.0
suspension_max_force = 11000.0
damping_compression = 2.2
damping_relaxation = 3.0

[node name="MeshInstance3D" type="MeshInstance3D" parent="WheelFrontLeft"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_suv_wheel")

[node name="Rim" type="MeshInstance3D" parent="WheelFrontLeft"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_suv_rim")

[node name="WheelFrontRight" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.92, 0.42, -1.45)
use_as_steering = true
use_as_traction = true
wheel_roll_influence = 0.15
wheel_radius = 0.42
wheel_rest_length = 0.18
wheel_friction_slip = 4.2
suspension_travel = 0.25
suspension_stiffness = 32.0
suspension_max_force = 11000.0
damping_compression = 2.2
damping_relaxation = 3.0

[node name="MeshInstance3D" type="MeshInstance3D" parent="WheelFrontRight"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_suv_wheel")

[node name="Rim" type="MeshInstance3D" parent="WheelFrontRight"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_suv_rim")

[node name="WheelRearLeft" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -0.92, 0.42, 1.45)
use_as_traction = true
wheel_roll_influence = 0.15
wheel_radius = 0.42
wheel_rest_length = 0.18
wheel_friction_slip = 4.0
suspension_travel = 0.25
suspension_stiffness = 34.0
suspension_max_force = 11000.0
damping_compression = 2.3
damping_relaxation = 3.2

[node name="MeshInstance3D" type="MeshInstance3D" parent="WheelRearLeft"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_suv_wheel")

[node name="Rim" type="MeshInstance3D" parent="WheelRearLeft"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_suv_rim")

[node name="WheelRearRight" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.92, 0.42, 1.45)
use_as_traction = true
wheel_roll_influence = 0.15
wheel_radius = 0.42
wheel_rest_length = 0.18
wheel_friction_slip = 4.0
suspension_travel = 0.25
suspension_stiffness = 34.0
suspension_max_force = 11000.0
damping_compression = 2.3
damping_relaxation = 3.2

[node name="MeshInstance3D" type="MeshInstance3D" parent="WheelRearRight"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_suv_wheel")

[node name="Rim" type="MeshInstance3D" parent="WheelRearRight"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_suv_rim")

[node name="Lights" type="Node3D" parent="."]

[node name="Headlights" type="Node3D" parent="Lights"]

[node name="SpotLeft" type="SpotLight3D" parent="Lights/Headlights"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -0.72, 0.85, -2.44)
light_color = Color(1, 0.98, 0.92, 1)
light_energy = 3.2
spot_range = 40.0
spot_angle = 42.0

[node name="SpotRight" type="SpotLight3D" parent="Lights/Headlights"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.72, 0.85, -2.44)
light_color = Color(1, 0.98, 0.92, 1)
light_energy = 3.2
spot_range = 40.0
spot_angle = 42.0

[node name="BrakeLights" type="Node3D" parent="Lights"]

[node name="TailLensLeft" type="CSGBox3D" parent="Lights/BrakeLights"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -0.8, 0.92, 2.41)
size = Vector3(0.28, 0.35, 0.06)
material = SubResource("Mat_TaillightLens")

[node name="TailLensRight" type="CSGBox3D" parent="Lights/BrakeLights"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.8, 0.92, 2.41)
size = Vector3(0.28, 0.35, 0.06)
material = SubResource("Mat_TaillightLens")

[node name="Audio" type="Node3D" parent="."]

[node name="EngineAudio" type="AudioStreamPlayer3D" parent="Audio"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.8, -1.3)
stream = ExtResource("4_enginesound")
volume_db = -3.0
max_distance = 50.0

[node name="HornAudio" type="AudioStreamPlayer3D" parent="Audio"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.8, -2.0)
stream = ExtResource("5_hornsound")
volume_db = 2.5
max_distance = 65.0

[node name="SkidAudio" type="AudioStreamPlayer3D" parent="Audio"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.4, 1.3)
stream = ExtResource("6_skidsound")
volume_db = -2.0

[node name="ImpactAudio" type="AudioStreamPlayer3D" parent="Audio"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.8, 0)
stream = ExtResource("7_impactsound")
volume_db = 4.0

[node name="DoorAudio" type="AudioStreamPlayer3D" parent="Audio"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -1.0, 0.8, -0.3)
stream = ExtResource("8_doorsound")

[node name="InteractableArea" type="Area3D" parent="."]
collision_layer = 64
collision_mask = 2
script = ExtResource("2_interactable")
prompt_text = "Drive Meghna Explorer 4x4"

[node name="CollisionShape3D" type="CollisionShape3D" parent="InteractableArea"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -1.3, 0.9, -0.4)
shape = SubResource("CylinderShape3D_interact")

[node name="VehicleCamera3D" type="Node3D" parent="."]
script = ExtResource("3_camera")
"""
    with open(scene_path, "w", encoding="utf-8") as f:
        f.write(scene_content)
    print(f"Generated {scene_path}")

# ------------------------------------------------------------------------------
# 2. MOTORCYCLE (Bikrom 150R)
# ------------------------------------------------------------------------------
def build_motorcycle():
    ensure_dir("vehicles/motorcycle")
    script_path = "vehicles/motorcycle/motorcycle.gd"
    scene_path = "vehicles/motorcycle/motorcycle.tscn"

    with open(script_path, "w", encoding="utf-8") as f:
        f.write("""# ==============================================================================
# BIKROM 150R COMMUTER MOTORCYCLE (VEHICLE SYSTEM)
# ==============================================================================
class_name MotorcycleVehicle
extends BaseVehicle3D

@export var max_lean_deg: float = 24.0

func _ready() -> void:
	vehicle_name = "Bikrom 150R Motorcycle"
	max_engine_force = 185.0
	max_brake_force = 32.0
	base_max_speed_kmh = 138.0
	max_steer_angle_rad = deg_to_rad(36.0)
	high_speed_steer_angle_rad = deg_to_rad(14.0)
	steer_speed = 7.5
	max_health = 55.0
	super._ready()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	# Dynamic motorcycle roll / lean into turns
	if is_driven and has_node("VisualModel"):
		var speed_kmh = linear_velocity.length() * 3.6
		var target_lean = -steering * clampf(speed_kmh / 45.0, 0.0, 1.0) * deg_to_rad(max_lean_deg)
		$VisualModel.rotation.z = lerp_angle($VisualModel.rotation.z, target_lean, 12.0 * delta)
""")

    scene_content = """[gd_scene format=3 uid="uid://d3bike001"]

[ext_resource type="Script" path="res://vehicles/motorcycle/motorcycle.gd" id="1_bike"]
[ext_resource type="Script" path="res://scripts/interaction/interactable.gd" id="2_interactable"]
[ext_resource type="Script" path="res://vehicles/vehicle_camera_3d.gd" id="3_camera"]
[ext_resource type="AudioStream" path="res://audio/vehicles/engine_bike_loop.wav" id="4_enginesound"]
[ext_resource type="AudioStream" path="res://audio/vehicles/horn_bike.wav" id="5_hornsound"]
[ext_resource type="AudioStream" path="res://audio/vehicles/tire_skid.wav" id="6_skidsound"]
[ext_resource type="AudioStream" path="res://audio/vehicles/vehicle_impact.wav" id="7_impactsound"]

[sub_resource type="BoxShape3D" id="BoxShape3D_chassis"]
size = Vector3(0.7, 1.1, 2.1)

[sub_resource type="CylinderShape3D" id="CylinderShape3D_interact"]
height = 1.8
radius = 1.6

[sub_resource type="StandardMaterial3D" id="Mat_BikePaint"]
albedo_color = Color(0.85, 0.15, 0.12, 1)
metallic = 0.85
roughness = 0.25

[sub_resource type="StandardMaterial3D" id="Mat_EngineMetal"]
albedo_color = Color(0.3, 0.32, 0.35, 1)
metallic = 0.9
roughness = 0.3

[sub_resource type="StandardMaterial3D" id="Mat_SeatLeather"]
albedo_color = Color(0.12, 0.12, 0.14, 1)
roughness = 0.85

[sub_resource type="StandardMaterial3D" id="Mat_Headlight"]
albedo_color = Color(1, 0.98, 0.9, 1)
emission_enabled = true
emission = Color(1, 0.95, 0.85, 1)
emission_energy_multiplier = 4.0

[sub_resource type="StandardMaterial3D" id="Mat_TireRubber"]
albedo_color = Color(0.12, 0.12, 0.13, 1)
roughness = 0.92

[sub_resource type="CylinderMesh" id="CylinderMesh_bike_wheel"]
material = SubResource("Mat_TireRubber")
top_radius = 0.34
bottom_radius = 0.34
height = 0.14
radial_segments = 16

[node name="Motorcycle" type="VehicleBody3D" groups=["damageables", "vehicles"]]
mass = 160.0
center_of_mass_mode = 1
center_of_mass = Vector3(0, -0.15, 0)
script = ExtResource("1_bike")

[node name="CollisionShape3D" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.65, 0)
shape = SubResource("BoxShape3D_chassis")

[node name="VisualModel" type="Node3D" parent="."]

[node name="FrameSpine" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.55, 0)
size = Vector3(0.24, 0.5, 1.8)
material = SubResource("Mat_EngineMetal")

[node name="FuelTank" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 0.965926, 0.258819, 0, -0.258819, 0.965926, 0, 0.85, -0.25)
size = Vector3(0.42, 0.32, 0.6)
material = SubResource("Mat_BikePaint")

[node name="Seat" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.78, 0.25)
size = Vector3(0.32, 0.14, 0.65)
material = SubResource("Mat_SeatLeather")

[node name="Handlebars" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.05, -0.55)
size = Vector3(0.72, 0.06, 0.06)
material = SubResource("Mat_EngineMetal")

[node name="HeadlightCowl" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.95, -0.75)
size = Vector3(0.28, 0.28, 0.22)
material = SubResource("Mat_BikePaint")

[node name="WheelFront" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.34, -0.85)
use_as_steering = true
wheel_roll_influence = 0.25
wheel_radius = 0.34
wheel_rest_length = 0.12
wheel_friction_slip = 3.5
suspension_stiffness = 45.0
damping_compression = 2.0
damping_relaxation = 2.8

[node name="MeshInstance3D" type="MeshInstance3D" parent="WheelFront"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_bike_wheel")

[node name="WheelRear" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.34, 0.85)
use_as_traction = true
wheel_roll_influence = 0.25
wheel_radius = 0.34
wheel_rest_length = 0.12
wheel_friction_slip = 3.8
suspension_stiffness = 50.0
damping_compression = 2.2
damping_relaxation = 3.0

[node name="MeshInstance3D" type="MeshInstance3D" parent="WheelRear"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_bike_wheel")

[node name="Lights" type="Node3D" parent="."]

[node name="Headlights" type="Node3D" parent="Lights"]

[node name="SpotBike" type="SpotLight3D" parent="Lights/Headlights"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.95, -0.88)
light_color = Color(1, 0.98, 0.9, 1)
light_energy = 2.8
spot_range = 35.0
spot_angle = 38.0

[node name="Audio" type="Node3D" parent="."]

[node name="EngineAudio" type="AudioStreamPlayer3D" parent="Audio"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.5, 0)
stream = ExtResource("4_enginesound")
volume_db = -2.0

[node name="HornAudio" type="AudioStreamPlayer3D" parent="Audio"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.9, -0.7)
stream = ExtResource("5_hornsound")
volume_db = 1.5

[node name="SkidAudio" type="AudioStreamPlayer3D" parent="Audio"]
stream = ExtResource("6_skidsound")

[node name="ImpactAudio" type="AudioStreamPlayer3D" parent="Audio"]
stream = ExtResource("7_impactsound")

[node name="InteractableArea" type="Area3D" parent="."]
collision_layer = 64
collision_mask = 2
script = ExtResource("2_interactable")
prompt_text = "Ride Bikrom 150R"

[node name="CollisionShape3D" type="CollisionShape3D" parent="InteractableArea"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.7, 0)
shape = SubResource("CylinderShape3D_interact")

[node name="VehicleCamera3D" type="Node3D" parent="."]
script = ExtResource("3_camera")
"""
    with open(scene_path, "w", encoding="utf-8") as f:
        f.write(scene_content)
    print(f"Generated {scene_path}")

# ------------------------------------------------------------------------------
# 3. CNG AUTO-RICKSHAW (Dhaka Green Baby Taxi)
# ------------------------------------------------------------------------------
def build_cng():
    ensure_dir("vehicles/cng")
    script_path = "vehicles/cng/cng_autorickshaw.gd"
    scene_path = "vehicles/cng/cng_autorickshaw.tscn"

    with open(script_path, "w", encoding="utf-8") as f:
        f.write("""# ==============================================================================
# DHAKA GREEN CNG AUTO-RICKSHAW (VEHICLE SYSTEM)
# ==============================================================================
class_name CngAutoRickshawVehicle
extends BaseVehicle3D

func _ready() -> void:
	vehicle_name = "Dhaka Green CNG Auto-Rickshaw"
	max_engine_force = 220.0
	max_brake_force = 36.0
	base_max_speed_kmh = 75.0
	max_steer_angle_rad = deg_to_rad(42.0)
	high_speed_steer_angle_rad = deg_to_rad(18.0)
	steer_speed = 7.0
	max_health = 75.0
	super._ready()
""")

    scene_content = """[gd_scene format=3 uid="uid://d3cng001"]

[ext_resource type="Script" path="res://vehicles/cng/cng_autorickshaw.gd" id="1_cng"]
[ext_resource type="Script" path="res://scripts/interaction/interactable.gd" id="2_interactable"]
[ext_resource type="Script" path="res://vehicles/vehicle_camera_3d.gd" id="3_camera"]
[ext_resource type="AudioStream" path="res://audio/vehicles/engine_cng_loop.wav" id="4_enginesound"]
[ext_resource type="AudioStream" path="res://audio/vehicles/horn_cng.wav" id="5_hornsound"]
[ext_resource type="AudioStream" path="res://audio/vehicles/tire_skid.wav" id="6_skidsound"]
[ext_resource type="AudioStream" path="res://audio/vehicles/vehicle_impact.wav" id="7_impactsound"]

[sub_resource type="BoxShape3D" id="BoxShape3D_chassis"]
size = Vector3(1.35, 1.45, 2.7)

[sub_resource type="CylinderShape3D" id="CylinderShape3D_interact"]
height = 2.0
radius = 2.0

[sub_resource type="StandardMaterial3D" id="Mat_CngGreen"]
albedo_color = Color(0.12, 0.48, 0.22, 1)
metallic = 0.5
roughness = 0.55

[sub_resource type="StandardMaterial3D" id="Mat_CngYellowRoof"]
albedo_color = Color(0.95, 0.75, 0.15, 1)
roughness = 0.65

[sub_resource type="StandardMaterial3D" id="Mat_MetalGrill"]
albedo_color = Color(0.18, 0.2, 0.22, 1)
metallic = 0.8
roughness = 0.4

[sub_resource type="StandardMaterial3D" id="Mat_TireRubber"]
albedo_color = Color(0.12, 0.12, 0.13, 1)
roughness = 0.92

[sub_resource type="CylinderMesh" id="CylinderMesh_cng_wheel"]
material = SubResource("Mat_TireRubber")
top_radius = 0.26
bottom_radius = 0.26
height = 0.16
radial_segments = 14

[node name="CngAutoRickshaw" type="VehicleBody3D" groups=["damageables", "vehicles"]]
mass = 450.0
center_of_mass_mode = 1
center_of_mass = Vector3(0, 0.12, 0)
script = ExtResource("1_cng")

[node name="CollisionShape3D" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.85, 0)
shape = SubResource("BoxShape3D_chassis")

[node name="VisualModel" type="Node3D" parent="."]

[node name="LowerHull" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.55, 0)
size = Vector3(1.32, 0.65, 2.65)
material = SubResource("Mat_CngGreen")

[node name="FrontNose" type="CSGPolygon3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -0.66, 0.25, -1.32)
polygon = PackedVector2Array(0, 0, 0.45, 0.6, 0.87, 0.6, 1.32, 0)
depth = 0.6
material = SubResource("Mat_CngGreen")

[node name="RoofCanopy" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.48, 0.15)
size = Vector3(1.28, 0.12, 2.2)
material = SubResource("Mat_CngYellowRoof")

[node name="PassengerCage" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.1, 0.35)
size = Vector3(1.24, 0.68, 1.6)
material = SubResource("Mat_MetalGrill")

[node name="WheelFront" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.26, -1.05)
use_as_steering = true
wheel_roll_influence = 0.35
wheel_radius = 0.26
wheel_rest_length = 0.12
wheel_friction_slip = 3.2
suspension_stiffness = 38.0
damping_compression = 1.8
damping_relaxation = 2.4

[node name="MeshInstance3D" type="MeshInstance3D" parent="WheelFront"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_cng_wheel")

[node name="WheelRearLeft" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -0.62, 0.26, 0.85)
use_as_traction = true
wheel_roll_influence = 0.35
wheel_radius = 0.26
wheel_rest_length = 0.12
wheel_friction_slip = 3.2
suspension_stiffness = 40.0
damping_compression = 2.0
damping_relaxation = 2.6

[node name="MeshInstance3D" type="MeshInstance3D" parent="WheelRearLeft"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_cng_wheel")

[node name="WheelRearRight" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.62, 0.26, 0.85)
use_as_traction = true
wheel_roll_influence = 0.35
wheel_radius = 0.26
wheel_rest_length = 0.12
wheel_friction_slip = 3.2
suspension_stiffness = 40.0
damping_compression = 2.0
damping_relaxation = 2.6

[node name="MeshInstance3D" type="MeshInstance3D" parent="WheelRearRight"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_cng_wheel")

[node name="Lights" type="Node3D" parent="."]

[node name="Headlights" type="Node3D" parent="Lights"]

[node name="SpotCNG" type="SpotLight3D" parent="Lights/Headlights"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.65, -1.38)
light_color = Color(1, 0.98, 0.9, 1)
light_energy = 2.5
spot_range = 30.0
spot_angle = 35.0

[node name="Audio" type="Node3D" parent="."]

[node name="EngineAudio" type="AudioStreamPlayer3D" parent="Audio"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.45, 0.5)
stream = ExtResource("4_enginesound")
volume_db = -1.0

[node name="HornAudio" type="AudioStreamPlayer3D" parent="Audio"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.7, -1.0)
stream = ExtResource("5_hornsound")
volume_db = 2.0

[node name="SkidAudio" type="AudioStreamPlayer3D" parent="Audio"]
stream = ExtResource("6_skidsound")

[node name="ImpactAudio" type="AudioStreamPlayer3D" parent="Audio"]
stream = ExtResource("7_impactsound")

[node name="InteractableArea" type="Area3D" parent="."]
collision_layer = 64
collision_mask = 2
script = ExtResource("2_interactable")
prompt_text = "Drive Dhaka Green CNG"

[node name="CollisionShape3D" type="CollisionShape3D" parent="InteractableArea"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -0.85, 0.8, -0.2)
shape = SubResource("CylinderShape3D_interact")

[node name="VehicleCamera3D" type="Node3D" parent="."]
script = ExtResource("3_camera")
"""
    with open(scene_path, "w", encoding="utf-8") as f:
        f.write(scene_content)
    print(f"Generated {scene_path}")

# ------------------------------------------------------------------------------
# 4. LOCAL BUS (Dhaka Nagar Paribahan / Murir Tin)
# ------------------------------------------------------------------------------
def build_bus():
    ensure_dir("vehicles/bus")
    script_path = "vehicles/bus/local_bus.gd"
    scene_path = "vehicles/bus/local_bus.tscn"

    with open(script_path, "w", encoding="utf-8") as f:
        f.write("""# ==============================================================================
# DHAKA LOCAL BUS (VEHICLE SYSTEM)
# ==============================================================================
class_name LocalBusVehicle
extends BaseVehicle3D

func _ready() -> void:
	vehicle_name = "Dhaka City Local Bus"
	max_engine_force = 1250.0
	max_brake_force = 140.0
	base_max_speed_kmh = 95.0
	max_steer_angle_rad = deg_to_rad(28.0)
	high_speed_steer_angle_rad = deg_to_rad(9.0)
	steer_speed = 3.8
	max_health = 350.0
	super._ready()
""")

    scene_content = """[gd_scene format=3 uid="uid://d3bus001"]

[ext_resource type="Script" path="res://vehicles/bus/local_bus.gd" id="1_bus"]
[ext_resource type="Script" path="res://scripts/interaction/interactable.gd" id="2_interactable"]
[ext_resource type="Script" path="res://vehicles/vehicle_camera_3d.gd" id="3_camera"]
[ext_resource type="AudioStream" path="res://audio/vehicles/engine_bus_loop.wav" id="4_enginesound"]
[ext_resource type="AudioStream" path="res://audio/vehicles/horn_bus_air.wav" id="5_hornsound"]
[ext_resource type="AudioStream" path="res://audio/vehicles/tire_skid.wav" id="6_skidsound"]
[ext_resource type="AudioStream" path="res://audio/vehicles/vehicle_impact.wav" id="7_impactsound"]

[sub_resource type="BoxShape3D" id="BoxShape3D_chassis"]
size = Vector3(2.5, 2.7, 9.5)

[sub_resource type="CylinderShape3D" id="CylinderShape3D_interact"]
height = 2.5
radius = 3.2

[sub_resource type="StandardMaterial3D" id="Mat_BusRed"]
albedo_color = Color(0.78, 0.22, 0.16, 1)
roughness = 0.65

[sub_resource type="StandardMaterial3D" id="Mat_BusGreenStripe"]
albedo_color = Color(0.12, 0.48, 0.25, 1)
roughness = 0.65

[sub_resource type="StandardMaterial3D" id="Mat_Glass"]
albedo_color = Color(0.2, 0.25, 0.3, 0.85)
transparency = 1

[sub_resource type="StandardMaterial3D" id="Mat_TireRubber"]
albedo_color = Color(0.12, 0.12, 0.13, 1)
roughness = 0.92

[sub_resource type="CylinderMesh" id="CylinderMesh_bus_wheel"]
material = SubResource("Mat_TireRubber")
top_radius = 0.54
bottom_radius = 0.54
height = 0.35
radial_segments = 16

[node name="LocalBus" type="VehicleBody3D" groups=["damageables", "vehicles"]]
mass = 7800.0
center_of_mass_mode = 1
center_of_mass = Vector3(0, 0.2, 0)
script = ExtResource("1_bus")

[node name="CollisionShape3D" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.6, 0)
shape = SubResource("BoxShape3D_chassis")

[node name="VisualModel" type="Node3D" parent="."]

[node name="BodyMain" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.6, 0)
size = Vector3(2.48, 2.65, 9.45)
material = SubResource("Mat_BusRed")

[node name="GreenStripe" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.25, 0)
size = Vector3(2.5, 0.45, 9.47)
material = SubResource("Mat_BusGreenStripe")

[node name="WindowsRowLeft" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -1.25, 2.05, 0.2)
size = Vector3(0.06, 0.75, 7.8)
material = SubResource("Mat_Glass")

[node name="WindowsRowRight" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 1.25, 2.05, 0.2)
size = Vector3(0.06, 0.75, 7.8)
material = SubResource("Mat_Glass")

[node name="WheelFrontLeft" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -1.15, 0.54, -3.2)
use_as_steering = true
wheel_roll_influence = 0.15
wheel_radius = 0.54
wheel_rest_length = 0.22
wheel_friction_slip = 4.5
suspension_stiffness = 55.0
suspension_max_force = 28000.0
damping_compression = 2.8
damping_relaxation = 3.8

[node name="MeshInstance3D" type="MeshInstance3D" parent="WheelFrontLeft"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_bus_wheel")

[node name="WheelFrontRight" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 1.15, 0.54, -3.2)
use_as_steering = true
wheel_roll_influence = 0.15
wheel_radius = 0.54
wheel_rest_length = 0.22
wheel_friction_slip = 4.5
suspension_stiffness = 55.0
suspension_max_force = 28000.0
damping_compression = 2.8
damping_relaxation = 3.8

[node name="MeshInstance3D" type="MeshInstance3D" parent="WheelFrontRight"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_bus_wheel")

[node name="WheelRearLeft" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -1.15, 0.54, 2.6)
use_as_traction = true
wheel_roll_influence = 0.15
wheel_radius = 0.54
wheel_rest_length = 0.22
wheel_friction_slip = 4.5
suspension_stiffness = 65.0
suspension_max_force = 32000.0
damping_compression = 3.0
damping_relaxation = 4.0

[node name="MeshInstance3D" type="MeshInstance3D" parent="WheelRearLeft"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_bus_wheel")

[node name="WheelRearRight" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 1.15, 0.54, 2.6)
use_as_traction = true
wheel_roll_influence = 0.15
wheel_radius = 0.54
wheel_rest_length = 0.22
wheel_friction_slip = 4.5
suspension_stiffness = 65.0
suspension_max_force = 32000.0
damping_compression = 3.0
damping_relaxation = 4.0

[node name="MeshInstance3D" type="MeshInstance3D" parent="WheelRearRight"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_bus_wheel")

[node name="Lights" type="Node3D" parent="."]

[node name="Headlights" type="Node3D" parent="Lights"]

[node name="SpotLeft" type="SpotLight3D" parent="Lights/Headlights"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -0.9, 0.9, -4.75)
light_color = Color(1, 0.98, 0.9, 1)
light_energy = 3.5
spot_range = 45.0

[node name="SpotRight" type="SpotLight3D" parent="Lights/Headlights"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.9, 0.9, -4.75)
light_color = Color(1, 0.98, 0.9, 1)
light_energy = 3.5
spot_range = 45.0

[node name="Audio" type="Node3D" parent="."]

[node name="EngineAudio" type="AudioStreamPlayer3D" parent="Audio"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.0, -3.0)
stream = ExtResource("4_enginesound")
volume_db = -1.0
max_distance = 60.0

[node name="HornAudio" type="AudioStreamPlayer3D" parent="Audio"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 2.5, -4.0)
stream = ExtResource("5_hornsound")
volume_db = 4.0
max_distance = 80.0

[node name="SkidAudio" type="AudioStreamPlayer3D" parent="Audio"]
stream = ExtResource("6_skidsound")

[node name="ImpactAudio" type="AudioStreamPlayer3D" parent="Audio"]
stream = ExtResource("7_impactsound")

[node name="InteractableArea" type="Area3D" parent="."]
collision_layer = 64
collision_mask = 2
script = ExtResource("2_interactable")
prompt_text = "Drive Dhaka City Bus"

[node name="CollisionShape3D" type="CollisionShape3D" parent="InteractableArea"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -1.6, 1.2, -2.5)
shape = SubResource("CylinderShape3D_interact")

[node name="VehicleCamera3D" type="Node3D" parent="."]
script = ExtResource("3_camera")
"""
    with open(scene_path, "w", encoding="utf-8") as f:
        f.write(scene_content)
    print(f"Generated {scene_path}")

# ------------------------------------------------------------------------------
# 5. PICKUP TRUCK (Padma Utility / DMP Patrol)
# ------------------------------------------------------------------------------
def build_pickup():
    ensure_dir("vehicles/pickup")
    script_path = "vehicles/pickup/pickup_truck.gd"
    scene_path = "vehicles/pickup/pickup_truck.tscn"

    with open(script_path, "w", encoding="utf-8") as f:
        f.write("""# ==============================================================================
# PADMA UTILITY PICKUP TRUCK (VEHICLE SYSTEM)
# ==============================================================================
class_name PickupTruckVehicle
extends BaseVehicle3D

func _ready() -> void:
	vehicle_name = "Padma Utility Pickup"
	max_engine_force = 480.0
	max_brake_force = 55.0
	base_max_speed_kmh = 160.0
	max_steer_angle_rad = deg_to_rad(33.0)
	high_speed_steer_angle_rad = deg_to_rad(12.0)
	steer_speed = 6.0
	max_health = 140.0
	super._ready()
""")

    scene_content = """[gd_scene format=3 uid="uid://d3pickup001"]

[ext_resource type="Script" path="res://vehicles/pickup/pickup_truck.gd" id="1_pickup"]
[ext_resource type="Script" path="res://scripts/interaction/interactable.gd" id="2_interactable"]
[ext_resource type="Script" path="res://vehicles/vehicle_camera_3d.gd" id="3_camera"]
[ext_resource type="AudioStream" path="res://audio/vehicles/engine_suv_loop.wav" id="4_enginesound"]
[ext_resource type="AudioStream" path="res://audio/vehicles/horn_suv.wav" id="5_hornsound"]
[ext_resource type="AudioStream" path="res://audio/vehicles/tire_skid.wav" id="6_skidsound"]
[ext_resource type="AudioStream" path="res://audio/vehicles/vehicle_impact.wav" id="7_impactsound"]

[sub_resource type="BoxShape3D" id="BoxShape3D_chassis"]
size = Vector3(1.9, 1.0, 5.0)

[sub_resource type="CylinderShape3D" id="CylinderShape3D_interact"]
height = 2.0
radius = 2.5

[sub_resource type="StandardMaterial3D" id="Mat_PickupPaint"]
albedo_color = Color(0.18, 0.32, 0.58, 1)
metallic = 0.8
roughness = 0.35

[sub_resource type="StandardMaterial3D" id="Mat_CargoBed"]
albedo_color = Color(0.25, 0.26, 0.28, 1)
roughness = 0.9

[sub_resource type="StandardMaterial3D" id="Mat_TireRubber"]
albedo_color = Color(0.12, 0.12, 0.13, 1)
roughness = 0.92

[sub_resource type="CylinderMesh" id="CylinderMesh_pickup_wheel"]
material = SubResource("Mat_TireRubber")
top_radius = 0.38
bottom_radius = 0.38
height = 0.25
radial_segments = 16

[node name="PickupTruck" type="VehicleBody3D" groups=["damageables", "vehicles"]]
mass = 1850.0
center_of_mass_mode = 1
center_of_mass = Vector3(0, -0.1, 0)
script = ExtResource("1_pickup")

[node name="CollisionShape3D" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.7, 0)
shape = SubResource("BoxShape3D_chassis")

[node name="VisualModel" type="Node3D" parent="."]

[node name="CabFront" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.95, -0.6)
size = Vector3(1.88, 1.1, 2.4)
material = SubResource("Mat_PickupPaint")

[node name="CargoBed" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.7, 1.4)
size = Vector3(1.88, 0.6, 2.2)
material = SubResource("Mat_CargoBed")

[node name="WheelFrontLeft" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -0.88, 0.38, -1.45)
use_as_steering = true
wheel_radius = 0.38
wheel_rest_length = 0.16
wheel_friction_slip = 3.9
suspension_stiffness = 36.0

[node name="MeshInstance3D" type="MeshInstance3D" parent="WheelFrontLeft"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_pickup_wheel")

[node name="WheelFrontRight" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.88, 0.38, -1.45)
use_as_steering = true
wheel_radius = 0.38
wheel_rest_length = 0.16
wheel_friction_slip = 3.9
suspension_stiffness = 36.0

[node name="MeshInstance3D" type="MeshInstance3D" parent="WheelFrontRight"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_pickup_wheel")

[node name="WheelRearLeft" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -0.88, 0.38, 1.45)
use_as_traction = true
wheel_radius = 0.38
wheel_rest_length = 0.16
wheel_friction_slip = 4.0
suspension_stiffness = 40.0

[node name="MeshInstance3D" type="MeshInstance3D" parent="WheelRearLeft"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_pickup_wheel")

[node name="WheelRearRight" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.88, 0.38, 1.45)
use_as_traction = true
wheel_radius = 0.38
wheel_rest_length = 0.16
wheel_friction_slip = 4.0
suspension_stiffness = 40.0

[node name="MeshInstance3D" type="MeshInstance3D" parent="WheelRearRight"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_pickup_wheel")

[node name="Lights" type="Node3D" parent="."]

[node name="Headlights" type="Node3D" parent="Lights"]

[node name="SpotLeft" type="SpotLight3D" parent="Lights/Headlights"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -0.68, 0.75, -2.48)
light_energy = 3.0
spot_range = 38.0

[node name="SpotRight" type="SpotLight3D" parent="Lights/Headlights"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.68, 0.75, -2.48)
light_energy = 3.0
spot_range = 38.0

[node name="Audio" type="Node3D" parent="."]

[node name="EngineAudio" type="AudioStreamPlayer3D" parent="Audio"]
stream = ExtResource("4_enginesound")
volume_db = -3.0

[node name="HornAudio" type="AudioStreamPlayer3D" parent="Audio"]
stream = ExtResource("5_hornsound")

[node name="SkidAudio" type="AudioStreamPlayer3D" parent="Audio"]
stream = ExtResource("6_skidsound")

[node name="ImpactAudio" type="AudioStreamPlayer3D" parent="Audio"]
stream = ExtResource("7_impactsound")

[node name="InteractableArea" type="Area3D" parent="."]
collision_layer = 64
collision_mask = 2
script = ExtResource("2_interactable")
prompt_text = "Drive Padma Utility Pickup"

[node name="CollisionShape3D" type="CollisionShape3D" parent="InteractableArea"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -1.2, 0.8, -0.5)
shape = SubResource("CylinderShape3D_interact")

[node name="VehicleCamera3D" type="Node3D" parent="."]
script = ExtResource("3_camera")
"""
    with open(scene_path, "w", encoding="utf-8") as f:
        f.write(scene_content)
    print(f"Generated {scene_path}")

# ------------------------------------------------------------------------------
# 6. DELIVERY VAN (Chander Gari / Courier Microbus)
# ------------------------------------------------------------------------------
def build_van():
    ensure_dir("vehicles/van")
    script_path = "vehicles/van/delivery_van.gd"
    scene_path = "vehicles/van/delivery_van.tscn"

    with open(script_path, "w", encoding="utf-8") as f:
        f.write("""# ==============================================================================
# CHANDER GARI DELIVERY VAN (VEHICLE SYSTEM)
# ==============================================================================
class_name DeliveryVanVehicle
extends BaseVehicle3D

func _ready() -> void:
	vehicle_name = "Chander Gari Delivery Van"
	max_engine_force = 450.0
	max_brake_force = 52.0
	base_max_speed_kmh = 145.0
	max_steer_angle_rad = deg_to_rad(32.0)
	high_speed_steer_angle_rad = deg_to_rad(11.0)
	steer_speed = 5.8
	max_health = 130.0
	super._ready()
""")

    scene_content = """[gd_scene format=3 uid="uid://d3van001"]

[ext_resource type="Script" path="res://vehicles/van/delivery_van.gd" id="1_van"]
[ext_resource type="Script" path="res://scripts/interaction/interactable.gd" id="2_interactable"]
[ext_resource type="Script" path="res://vehicles/vehicle_camera_3d.gd" id="3_camera"]
[ext_resource type="AudioStream" path="res://audio/vehicles/engine_sedan_loop.wav" id="4_enginesound"]
[ext_resource type="AudioStream" path="res://audio/vehicles/horn_sedan.wav" id="5_hornsound"]
[ext_resource type="AudioStream" path="res://audio/vehicles/tire_skid.wav" id="6_skidsound"]
[ext_resource type="AudioStream" path="res://audio/vehicles/vehicle_impact.wav" id="7_impactsound"]

[sub_resource type="BoxShape3D" id="BoxShape3D_chassis"]
size = Vector3(1.85, 1.7, 4.8)

[sub_resource type="CylinderShape3D" id="CylinderShape3D_interact"]
height = 2.0
radius = 2.5

[sub_resource type="StandardMaterial3D" id="Mat_VanWhite"]
albedo_color = Color(0.9, 0.9, 0.92, 1)
roughness = 0.4

[sub_resource type="StandardMaterial3D" id="Mat_TireRubber"]
albedo_color = Color(0.12, 0.12, 0.13, 1)
roughness = 0.92

[sub_resource type="CylinderMesh" id="CylinderMesh_van_wheel"]
material = SubResource("Mat_TireRubber")
top_radius = 0.35
bottom_radius = 0.35
height = 0.22
radial_segments = 16

[node name="DeliveryVan" type="VehicleBody3D" groups=["damageables", "vehicles"]]
mass = 1950.0
center_of_mass_mode = 1
center_of_mass = Vector3(0, -0.05, 0)
script = ExtResource("1_van")

[node name="CollisionShape3D" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.05, 0)
shape = SubResource("BoxShape3D_chassis")

[node name="VisualModel" type="Node3D" parent="."]

[node name="BoxBody" type="CSGBox3D" parent="VisualModel"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.05, 0)
size = Vector3(1.82, 1.65, 4.75)
material = SubResource("Mat_VanWhite")

[node name="WheelFrontLeft" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -0.85, 0.35, -1.4)
use_as_steering = true
wheel_radius = 0.35
wheel_rest_length = 0.15
wheel_friction_slip = 3.8
suspension_stiffness = 38.0

[node name="MeshInstance3D" type="MeshInstance3D" parent="WheelFrontLeft"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_van_wheel")

[node name="WheelFrontRight" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.85, 0.35, -1.4)
use_as_steering = true
wheel_radius = 0.35
wheel_rest_length = 0.15
wheel_friction_slip = 3.8
suspension_stiffness = 38.0

[node name="MeshInstance3D" type="MeshInstance3D" parent="WheelFrontRight"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_van_wheel")

[node name="WheelRearLeft" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -0.85, 0.35, 1.4)
use_as_traction = true
wheel_radius = 0.35
wheel_rest_length = 0.15
wheel_friction_slip = 3.8
suspension_stiffness = 42.0

[node name="MeshInstance3D" type="MeshInstance3D" parent="WheelRearLeft"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_van_wheel")

[node name="WheelRearRight" type="VehicleWheel3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.85, 0.35, 1.4)
use_as_traction = true
wheel_radius = 0.35
wheel_rest_length = 0.15
wheel_friction_slip = 3.8
suspension_stiffness = 42.0

[node name="MeshInstance3D" type="MeshInstance3D" parent="WheelRearRight"]
transform = Transform3D(-4.37114e-08, -1, 0, 1, -4.37114e-08, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("CylinderMesh_van_wheel")

[node name="Lights" type="Node3D" parent="."]

[node name="Headlights" type="Node3D" parent="Lights"]

[node name="SpotLeft" type="SpotLight3D" parent="Lights/Headlights"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -0.65, 0.72, -2.4)
light_energy = 2.8
spot_range = 35.0

[node name="SpotRight" type="SpotLight3D" parent="Lights/Headlights"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.65, 0.72, -2.4)
light_energy = 2.8
spot_range = 35.0

[node name="Audio" type="Node3D" parent="."]

[node name="EngineAudio" type="AudioStreamPlayer3D" parent="Audio"]
stream = ExtResource("4_enginesound")
volume_db = -3.0

[node name="HornAudio" type="AudioStreamPlayer3D" parent="Audio"]
stream = ExtResource("5_hornsound")

[node name="SkidAudio" type="AudioStreamPlayer3D" parent="Audio"]
stream = ExtResource("6_skidsound")

[node name="ImpactAudio" type="AudioStreamPlayer3D" parent="Audio"]
stream = ExtResource("7_impactsound")

[node name="InteractableArea" type="Area3D" parent="."]
collision_layer = 64
collision_mask = 2
script = ExtResource("2_interactable")
prompt_text = "Drive Chander Gari Van"

[node name="CollisionShape3D" type="CollisionShape3D" parent="InteractableArea"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -1.2, 0.9, -0.4)
shape = SubResource("CylinderShape3D_interact")

[node name="VehicleCamera3D" type="Node3D" parent="."]
script = ExtResource("3_camera")
"""
    with open(scene_path, "w", encoding="utf-8") as f:
        f.write(scene_content)
    print(f"Generated {scene_path}")

def main():
    build_suv()
    build_motorcycle()
    build_cng()
    build_bus()
    build_pickup()
    build_van()

if __name__ == "__main__":
    main()
