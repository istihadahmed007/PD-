# ==============================================================================
# POLICE SYSTEM TEST SCENE GENERATOR
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Programmatically constructs tests/test_police_system.tscn and
#          tests/test_police_system.gd for exhaustive validation of:
#          - Crime detection & witness reporting
#          - Wanted level progression (1-5 stars)
#          - Non-teleporting navigation & vehicle pursuit AI
#          - Police checkpoints & spike strip dynamics
#          - Search areas, line-of-sight tracking, evasion & cooldown
#          - Police station desk surrender, fines, impound, and trespassing
# ==============================================================================
import os

def generate_test_controller_script():
    out_path = r"tests/test_police_system.gd"
    content = """# ==============================================================================
# POLICE SYSTEM TEST CONTROLLER (TEST SUITE)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Diagnostic test harness for police crime response, pursuit AI,
#          witness reporting, checkpoints, search areas, and station interactions.
# ==============================================================================
extends Node3D

@onready var police_system: PoliceSystem = $PoliceSystem if has_node("PoliceSystem") else null
@onready var player: Player = $Player if has_node("Player") else null
@onready var checkpoint: PoliceCheckpoint = $PoliceCheckpoint if has_node("PoliceCheckpoint") else null
@onready var police_station: PoliceStationController = $PoliceStation if has_node("PoliceStation") else null

var telemetry_label: Label = null
var recent_crime_log: String = "None (Peaceful)"
var recent_witness_log: String = "None"
var nearest_police_dist: float = 999.0
var nearest_cruiser_dist: float = 999.0


func _ready() -> void:
	_create_telemetry_ui()
	EventBus.crime_committed.connect(_on_crime_committed)
	EventBus.witness_reported_crime.connect(_on_witness_reported)
	EventBus.police_arrest_triggered.connect(_on_arrest_triggered)
	EventBus.police_pursuit_evaded.connect(_on_pursuit_evaded)


func _create_telemetry_ui() -> void:
	var canvas = CanvasLayer.new()
	canvas.name = "TelemetryCanvas"
	add_child(canvas)
	
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.position = Vector2(24, 24)
	canvas.add_child(panel)
	
	telemetry_label = Label.new()
	telemetry_label.text = "POLICE SYSTEM DIAGNOSTICS: INITIALIZING..."
	telemetry_label.add_theme_font_size_override("font_size", 13)
	telemetry_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95, 1))
	panel.add_child(telemetry_label)


func _process(_delta: float) -> void:
	if not telemetry_label:
		return
	
	_calculate_nearest_units()
	
	var stars = GameManager.wanted_stars
	var state_name = "PEACEFUL"
	var los_status = "HIDDEN"
	var out_of_sight = 0.0
	var req_time = 0.0
	var s_radius = 0.0
	var dist_to_search = 0.0
	
	if police_system:
		state_name = PoliceSystem.PursuitState.keys()[police_system.current_pursuit_state]
		los_status = "SPOTTED (LINE OF SIGHT ACTIVE)" if police_system.is_player_spotted else "HIDDEN (LOS BROKEN)"
		out_of_sight = police_system.time_out_of_sight
		req_time = police_system.required_evade_time
		s_radius = police_system.current_search_radius
		if is_instance_valid(GameManager.active_player):
			dist_to_search = GameManager.active_player.global_position.distance_to(police_system.last_known_player_position)
	
	var info := "=== DTA POLICE & WANTED SYSTEM DIAGNOSTICS ===\n"
	info += "Wanted Heat Rating: %d / 5 Stars %s\n" % [stars, ("★" * stars + "☆" * (5 - stars))]
	info += "Pursuit State: %s | LOS: %s\n" % [state_name, los_status]
	info += "Evasion Cooldown: %2.1fs / %2.1fs (Timer ticks 2x outside zone)\n" % [out_of_sight, req_time]
	info += "Search Zone: Radius %2.0fm | Distance from Center: %2.1fm\n" % [s_radius, dist_to_search]
	info += "Nearest Police Officer: %2.1fm | Nearest Cruiser: %2.1fm\n" % [nearest_police_dist, nearest_cruiser_dist]
	info += "Recent Crime Event: %s\n" % recent_crime_log
	info += "Recent 999 Witness Call: %s\n" % recent_witness_log
	
	info += "\n[ PLAYABLE TEST SCENARIO CONTROLS ]\n"
	info += "  [1] Commit Minor Theft (1 Star)\n"
	info += "  [2] Brandish Weapon in Public (1 Star)\n"
	info += "  [3] Discharge Firearm / Shoot (2 Stars)\n"
	info += "  [4] Vehicular Hit & Run (3 Stars)\n"
	info += "  [5] Assault Police / Max Lockdown (4-5 Stars)\n"
	info += "  [C] Clear Wanted Rating (Surrender / Evade Reset)\n"
	info += "  [T] Teleport Suspect to Police Thana (Test Desk / Bail / Armory)\n"
	info += "  [B] Teleport Suspect to Canal Bridge Checkpoint (Test Roadblock / Spikes)\n"
	info += "  [W, A, S, D, Space, Shift] Player Locomotion / Sprint / Jump\n"
	info += "  [E] Board Vehicle / Speak with Duty Officer\n"
	
	telemetry_label.text = info


func _calculate_nearest_units() -> void:
	nearest_police_dist = 999.0
	nearest_cruiser_dist = 999.0
	
	var player_pos = GameManager.active_player.global_position if is_instance_valid(GameManager.active_player) else Vector3.ZERO
	
	var officers = get_tree().get_nodes_in_group("police_officers")
	for o in officers:
		if is_instance_valid(o):
			var d = o.global_position.distance_to(player_pos)
			if d < nearest_police_dist:
				nearest_police_dist = d
	
	var cruisers = get_tree().get_nodes_in_group("police_vehicles")
	for c in cruisers:
		if is_instance_valid(c):
			var d = c.global_position.distance_to(player_pos)
			if d < nearest_cruiser_dist:
				nearest_cruiser_dist = d


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	
	var player_pos = GameManager.active_player.global_position if is_instance_valid(GameManager.active_player) else Vector3.ZERO
	
	match event.keycode:
		KEY_1:
			recent_crime_log = "Theft committed (Severity 1)"
			EventBus.crime_committed.emit("THEFT_PETTY", 1, player_pos)
		KEY_2:
			recent_crime_log = "Brandishing weapon in public (Severity 1)"
			EventBus.crime_committed.emit("BRANDISHING_WEAPON", 1, player_pos)
		KEY_3:
			recent_crime_log = "Firearm discharge in city streets (Severity 2)"
			EventBus.crime_committed.emit("FIREARM_DISCHARGE", 2, player_pos)
		KEY_4:
			recent_crime_log = "Vehicular hit and run incident (Severity 3)"
			EventBus.crime_committed.emit("VEHICLE_HIT_AND_RUN", 3, player_pos)
		KEY_5:
			recent_crime_log = "Assault on DMP Police / Tactical Alert (Severity 4)"
			EventBus.crime_committed.emit("ASSAULT_POLICE", 4, player_pos)
		KEY_C:
			recent_crime_log = "Wanted rating manually cleared"
			GameManager.set_wanted_level(0)
		KEY_T:
			# Teleport to Police Thana Porch
			if is_instance_valid(GameManager.active_player):
				GameManager.active_player.global_position = Vector3(45.0, 0.5, -31.0)
				recent_crime_log = "Player teleported to Lalbagh Police Thana porch"
		KEY_B:
			# Teleport to Checkpoint Roadblock
			if is_instance_valid(GameManager.active_player):
				GameManager.active_player.global_position = Vector3(0.0, 0.5, 38.0)
				recent_crime_log = "Player teleported to Canal Bridge Checkpoint"


func _on_crime_committed(crime_type: String, _sev: int, _loc: Vector3) -> void:
	recent_crime_log = crime_type


func _on_witness_reported(witness_name: String, crime_type: String, _loc: Vector3) -> void:
	recent_witness_log = "%s reported %s via 999" % [witness_name, crime_type]


func _on_arrest_triggered(officer: Node) -> void:
	recent_crime_log = "ARRESTED by %s! Fined ৳ 500." % (officer.name if officer else "Police")


func _on_pursuit_evaded() -> void:
	recent_crime_log = "PURSUIT EVADED! Wanted level cleared."
"""
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Generated: {out_path}")


def generate_test_scene():
    out_path = r"tests/test_police_system.tscn"
    os.makedirs(os.path.dirname(out_path), exist_ok=True)

    content = """[gd_scene format=3 uid="uid://d3policetest001"]

[ext_resource type="Script" path="res://tests/test_police_system.gd" id="1_testcontroller"]
[ext_resource type="Script" path="res://scripts/police/police_system.gd" id="2_policesys"]
[ext_resource type="Script" path="res://world/traffic/road_network_3d.gd" id="3_roadnet"]
[ext_resource type="PackedScene" uid="uid://ciqrpd5675boy" path="res://player/player.tscn" id="4_player"]
[ext_resource type="PackedScene" uid="uid://bdahud001scene" path="res://ui/hud/hud.tscn" id="5_hud"]
[ext_resource type="PackedScene" uid="uid://d3policeradar001" path="res://ui/police_radar/police_radar_hud.tscn" id="6_radarhud"]
[ext_resource type="PackedScene" uid="uid://d3policestation001" path="res://environment/architecture/police_station.tscn" id="7_policestation"]
[ext_resource type="PackedScene" uid="uid://d3policecheckpoint001" path="res://environment/police/police_checkpoint.tscn" id="8_checkpoint"]
[ext_resource type="PackedScene" uid="uid://d3policesedan001" path="res://vehicles/police/police_sedan.tscn" id="9_policesedan"]
[ext_resource type="PackedScene" uid="uid://d3policeofficer001" path="res://characters/police/police_officer.tscn" id="10_policeofficer"]
[ext_resource type="PackedScene" uid="uid://d3sedan001" path="res://vehicles/sedan/sedan.tscn" id="11_civiliansedan"]
[ext_resource type="PackedScene" uid="uid://d3pedestrian001" path="res://characters/pedestrians/bangladeshi_pedestrian.tscn" id="12_pedestrian"]

[sub_resource type="ProceduralSkyMaterial" id="ProceduralSkyMaterial_sun"]
sky_top_color = Color(0.35, 0.58, 0.92, 1)
sky_horizon_color = Color(0.74, 0.82, 0.88, 1)
ground_bottom_color = Color(0.2, 0.22, 0.25, 1)
ground_horizon_color = Color(0.74, 0.82, 0.88, 1)

[sub_resource type="Sky" id="Sky_police"]
sky_material = SubResource("ProceduralSkyMaterial_sun")

[sub_resource type="Environment" id="Environment_test"]
background_mode = 2
sky = SubResource("Sky_police")
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

[sub_resource type="StandardMaterial3D" id="Mat_BuildingWall"]
albedo_color = Color(0.75, 0.72, 0.68, 1)
roughness = 0.85

[node name="TestPoliceSystem" type="Node3D"]
script = ExtResource("1_testcontroller")

[node name="WorldEnvironment" type="WorldEnvironment" parent="."]
environment = SubResource("Environment_test")

[node name="SunLight" type="DirectionalLight3D" parent="."]
transform = Transform3D(0.819152, -0.40558, 0.40558, 0, 0.707107, 0.707107, -0.573576, -0.579228, 0.579228, 0, 35, 0)
light_color = Color(1, 0.98, 0.92, 1)
light_energy = 1.3
shadow_enabled = true

[node name="PoliceSystem" type="Node" parent="." groups=["police_system"]]
script = ExtResource("2_policesys")
base_evade_time_per_star = 16.0
search_radius_per_star = 26.0

[node name="GroundBase" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 0)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(320, 1.0, 320)
material = SubResource("Mat_Ground")

[node name="RoadNetwork" type="Node3D" parent="." groups=["road_network"]]
script = ExtResource("3_roadnet")

[node name="MainAvenue" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.05, 0)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(8.5, 0.1, 260)
material = SubResource("Mat_RoadAsphalt")

[node name="CenterStripe" type="CSGBox3D" parent="RoadNetwork/MainAvenue"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.06, 0)
size = Vector3(0.2, 0.02, 258)
material = SubResource("Mat_YellowStripe")

[node name="WestSidewalk" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -5.5, 0.15, 0)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(2.5, 0.2, 260)
material = SubResource("Mat_Sidewalk")

[node name="EastSidewalk" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 5.5, 0.15, 0)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(2.5, 0.2, 260)
material = SubResource("Mat_Sidewalk")

[node name="CrossAvenue" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.05, -35)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(180, 0.1, 8.5)
material = SubResource("Mat_RoadAsphalt")

[node name="UrbanObstacle1" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -22, 4.0, -10)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(16, 8, 24)
material = SubResource("Mat_BuildingWall")

[node name="UrbanObstacle2" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -22, 4.0, 35)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(16, 8, 28)
material = SubResource("Mat_BuildingWall")

[node name="UrbanObstacle3" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 24, 3.5, 35)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(14, 7, 26)
material = SubResource("Mat_BuildingWall")

[node name="PoliceStation" parent="." instance=ExtResource("7_policestation")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 45, 0, -40)

[node name="StationCruiser" parent="." instance=ExtResource("9_policesedan")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 52, 0.45, -32)

[node name="StationOfficer" parent="." instance=ExtResource("10_policeofficer")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 45, 0.2, -31)

[node name="PatrolCruiser" parent="." instance=ExtResource("9_policesedan")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 2.2, 0.45, -75)

[node name="PatrolOfficer" parent="." instance=ExtResource("10_policeofficer")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -5.5, 0.25, -20)

[node name="PoliceCheckpoint" parent="." instance=ExtResource("8_checkpoint")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 50)

[node name="CivilianVehicle" parent="." instance=ExtResource("11_civiliansedan")]
transform = Transform3D(-1, 0, -8.74228e-08, 0, 1, 0, 8.74228e-08, 0, -1, -2.2, 0.45, -8)

[node name="WitnessPedestrian1" parent="." instance=ExtResource("12_pedestrian")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -5.5, 0.25, -12)

[node name="WitnessPedestrian2" parent="." instance=ExtResource("12_pedestrian")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 5.5, 0.25, -16)

[node name="WitnessPedestrian3" parent="." instance=ExtResource("12_pedestrian")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -5.5, 0.25, 15)

[node name="Player" parent="." instance=ExtResource("4_player")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.5, -18)

[node name="HUD" parent="." instance=ExtResource("5_hud")]

[node name="PoliceRadarHUD" parent="." instance=ExtResource("6_radarhud")]
"""
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Generated: {out_path}")


if __name__ == "__main__":
    generate_test_controller_script()
    generate_test_scene()
    print("Playable police test scenario successfully created!")
