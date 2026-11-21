# ==============================================================================
# MISSION TEST SCENE BUILDER
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Programmatically constructs tests/test_story_missions.tscn and
#          tests/test_story_missions.gd for playable validation of Part 06 story missions.
# ==============================================================================
import os

def generate_test_controller():
    out_path = r"tests/test_story_missions.gd"
    content = """# ==============================================================================
# STORY MISSIONS TEST CONTROLLER (TEST SUITE)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Comprehensive diagnostic harness for Part 06 story missions,
#          interactive dialogue letterbox, objectives, checkpoints, fail/retry,
#          and SaveSystem serialization.
# ==============================================================================
extends Node3D

@onready var mission_system: MissionSystem = $MissionSystem if has_node("MissionSystem") else null
@onready var player: Player = $Player if has_node("Player") else null

var telemetry_label: Label = null
var recent_dialogue_line: String = "None (Dialogue Idle)"
var active_timer_display: String = "N/A (Untimed)"


func _ready() -> void:
	_create_telemetry_ui()
	
	EventBus.mission_started.connect(_on_mission_started)
	EventBus.mission_objective_updated.connect(_on_objective_updated)
	EventBus.mission_completed.connect(_on_mission_completed)
	EventBus.mission_failed.connect(_on_mission_failed)
	EventBus.mission_timer_updated.connect(_on_timer_updated)
	EventBus.mission_dialogue_line_triggered.connect(_on_dialogue_line)


func _create_telemetry_ui() -> void:
	var canvas = CanvasLayer.new()
	canvas.name = "TelemetryCanvas"
	canvas.layer = 15
	add_child(canvas)
	
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.position = Vector2(24, 24)
	canvas.add_child(panel)
	
	telemetry_label = Label.new()
	telemetry_label.text = "STORY MISSION ENGINE: INITIALIZING..."
	telemetry_label.add_theme_font_size_override("font_size", 13)
	telemetry_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95, 1))
	panel.add_child(telemetry_label)


func _process(_delta: float) -> void:
	if not telemetry_label:
		return
	
	var m_title = "None (Select Mission [1-3])"
	var m_type = "N/A"
	var m_step = 0
	var total_steps = 0
	var step_desc = "Walk up to any Questgiver beacon or press [1, 2, 3]"
	var completed_list = "None"
	
	if mission_system:
		if mission_system.active_mission:
			m_title = mission_system.active_mission.title
			m_type = MissionResource.MissionType.keys()[mission_system.active_mission.mission_type]
			m_step = mission_system.current_step_index + 1
			total_steps = mission_system.active_mission.get_total_steps()
			var current_step_data = mission_system.active_mission.get_step(mission_system.current_step_index)
			step_desc = current_step_data.get("description", "In Progress")
		
		if not mission_system.completed_mission_ids.is_empty():
			completed_list = ", ".join(mission_system.completed_mission_ids)
	
	var info := "=== DTA BANGLADESH STORY & MISSION SYSTEM ===\\n"
	info += "Active Mission: %s [%s]\\n" % [m_title, m_type]
	info += "Current Objective (%d/%d): %s\\n" % [m_step, total_steps, step_desc]
	info += "Mission Timer: %s\\n" % active_timer_display
	info += "Recent Dialogue: %s\\n" % recent_dialogue_line
	info += "Completed Missions Archive: %s\\n" % completed_list
	info += "Player Wallet: ৳ %d BDT\\n" % GameManager.wallet_bdt
	
	info += "\\n[ STORY CONTROLS & DIAGNOSTICS ]\\n"
	info += "  [1] Start Mission 01: Shadows & Spark Plugs (ছায়া ও চালক)\\n"
	info += "  [2] Start Mission 02: Eyes of the Buriganga (বুড়িগঙ্গার চোখ)\\n"
	info += "  [3] Start Mission 03: Smoke Over Padma (পদ্মার ধোঁয়া)\\n"
	info += "  [N] Advance / Skip Current Objective Step\\n"
	info += "  [R] Retry Mission from Last Checkpoint\\n"
	info += "  [F] Trigger Mission Failure (Test somber audio & retry)\\n"
	info += "  [K] Save Game State to user://dta_savegame.json\\n"
	info += "  [L] Load Game State from JSON\\n"
	info += "  [T] Teleport to Active Objective Waypoint Beacon\\n"
	info += "  [Space / E] Advance Dialogue / Board Vehicle / Interact\\n"
	
	telemetry_label.text = info


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	
	match event.keycode:
		KEY_1:
			if mission_system:
				mission_system.start_mission(StoryMissions.get_mission_1())
		KEY_2:
			if mission_system:
				mission_system.start_mission(StoryMissions.get_mission_2())
		KEY_3:
			if mission_system:
				mission_system.start_mission(StoryMissions.get_mission_3())
		KEY_N:
			if mission_system and mission_system.active_mission:
				mission_system.advance_objective()
		KEY_R:
			if mission_system and mission_system.active_mission:
				mission_system.retry_mission()
		KEY_F:
			if mission_system and mission_system.active_mission:
				mission_system.fail_mission("Manual Diagnostic Failure Triggered")
		KEY_K:
			var player_pos = GameManager.active_player.global_position if is_instance_valid(GameManager.active_player) else Vector3.ZERO
			var completed = mission_system.completed_mission_ids if mission_system else []
			var success = SaveSystem.save_game(player_pos, GameManager.wallet_bdt, GameManager.wanted_stars, completed)
			recent_dialogue_line = "Game Saved: %s" % ("SUCCESS" if success else "FAILED")
		KEY_L:
			var data = SaveSystem.load_game()
			if data:
				recent_dialogue_line = "Game Loaded from Save: Wallet ৳ %d" % data.get("economy", {}).get("wallet_bdt", 0)
		KEY_T:
			if mission_system and mission_system.active_beacon and mission_system.active_beacon.is_active:
				if is_instance_valid(GameManager.active_player):
					GameManager.active_player.global_position = mission_system.active_beacon.global_position + Vector3(0, 0.5, 2.0)
					recent_dialogue_line = "Player teleported to active objective beacon!"


func _on_mission_started(m_id: String, title: String) -> void:
	recent_dialogue_line = "Mission Started: " + title
	active_timer_display = "Active"


func _on_objective_updated(step_idx: int, desc: String) -> void:
	recent_dialogue_line = "Step %d: %s" % [step_idx + 1, desc]


func _on_mission_completed(m_id: String, reward: int) -> void:
	recent_dialogue_line = "Mission Complete! Paid ৳ %d." % reward
	active_timer_display = "Completed"


func _on_mission_failed(m_id: String, reason: String) -> void:
	recent_dialogue_line = "Mission Failed: " + reason
	active_timer_display = "Failed"


func _on_timer_updated(remain: float) -> void:
	active_timer_display = "%2.1f seconds remaining" % remain


func _on_dialogue_line(speaker: String, bn: String, _en: String, _portrait: String) -> void:
	recent_dialogue_line = "%s: %s" % [speaker, bn.substr(0, 45) + "..."]
"""
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Generated: {out_path}")


def generate_test_scene():
    out_path = r"tests/test_story_missions.tscn"
    os.makedirs(os.path.dirname(out_path), exist_ok=True)

    content = """[gd_scene format=3 uid="uid://d3missiontest001"]

[ext_resource type="Script" path="res://tests/test_story_missions.gd" id="1_testcontroller"]
[ext_resource type="Script" path="res://missions/mission_system.gd" id="2_missionsys"]
[ext_resource type="Script" path="res://world/traffic/road_network_3d.gd" id="3_roadnet"]
[ext_resource type="PackedScene" uid="uid://ciqrpd5675boy" path="res://player/player.tscn" id="4_player"]
[ext_resource type="PackedScene" uid="uid://bdahud001scene" path="res://ui/hud/hud.tscn" id="5_hud"]
[ext_resource type="PackedScene" uid="uid://d3missiontrigger001" path="res://missions/mission_trigger.tscn" id="6_trigger"]
[ext_resource type="PackedScene" uid="uid://d3autoworkshop001" path="res://environment/architecture/auto_workshop.tscn" id="7_workshop"]
[ext_resource type="PackedScene" uid="uid://d3commercialmarket001" path="res://environment/architecture/commercial_market.tscn" id="8_market"]
[ext_resource type="PackedScene" uid="uid://d3policestation001" path="res://environment/architecture/police_station.tscn" id="9_policestation"]
[ext_resource type="PackedScene" uid="uid://d3canalbridge001" path="res://environment/infrastructure/canal_bridge.tscn" id="10_bridge"]
[ext_resource type="PackedScene" uid="uid://d3cng001" path="res://vehicles/cng/cng_autorickshaw.tscn" id="11_cng"]
[ext_resource type="PackedScene" uid="uid://d3sedan001" path="res://vehicles/sedan/sedan.tscn" id="12_sedan"]
[ext_resource type="PackedScene" uid="uid://d3pickup001" path="res://vehicles/pickup/pickup_truck.tscn" id="13_pickup"]
[ext_resource type="PackedScene" uid="uid://d3policesedan001" path="res://vehicles/police/police_sedan.tscn" id="14_policesedan"]
[ext_resource type="PackedScene" uid="uid://d3policeradar001" path="res://ui/police_radar/police_radar_hud.tscn" id="15_radarhud"]

[sub_resource type="ProceduralSkyMaterial" id="ProceduralSkyMaterial_sun"]
sky_top_color = Color(0.35, 0.58, 0.92, 1)
sky_horizon_color = Color(0.74, 0.82, 0.88, 1)
ground_bottom_color = Color(0.2, 0.22, 0.25, 1)
ground_horizon_color = Color(0.74, 0.82, 0.88, 1)

[sub_resource type="Sky" id="Sky_mission"]
sky_material = SubResource("ProceduralSkyMaterial_sun")

[sub_resource type="Environment" id="Environment_test"]
background_mode = 2
sky = SubResource("Sky_mission")
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

[sub_resource type="StandardMaterial3D" id="Mat_BrickPaving"]
albedo_color = Color(0.55, 0.32, 0.25, 1)
roughness = 0.85

[node name="TestStoryMissions" type="Node3D"]
script = ExtResource("1_testcontroller")

[node name="WorldEnvironment" type="WorldEnvironment" parent="."]
environment = SubResource("Environment_test")

[node name="SunLight" type="DirectionalLight3D" parent="."]
transform = Transform3D(0.819152, -0.40558, 0.40558, 0, 0.707107, 0.707107, -0.573576, -0.579228, 0.579228, 0, 35, 0)
light_color = Color(1, 0.98, 0.92, 1)
light_energy = 1.3
shadow_enabled = true

[node name="MissionSystem" type="Node" parent="." groups=["mission_system"]]
script = ExtResource("2_missionsys")

[node name="GroundBase" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 0)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(360, 1.0, 360)
material = SubResource("Mat_Ground")

[node name="RoadNetwork" type="Node3D" parent="." groups=["road_network"]]
script = ExtResource("3_roadnet")

[node name="MainAvenue" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.05, 0)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(8.5, 0.1, 280)
material = SubResource("Mat_RoadAsphalt")

[node name="CenterStripe" type="CSGBox3D" parent="RoadNetwork/MainAvenue"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.06, 0)
size = Vector3(0.2, 0.02, 278)
material = SubResource("Mat_YellowStripe")

[node name="WestSidewalk" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -5.5, 0.15, 0)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(2.5, 0.2, 280)
material = SubResource("Mat_Sidewalk")

[node name="EastSidewalk" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 5.5, 0.15, 0)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(2.5, 0.2, 280)
material = SubResource("Mat_Sidewalk")

[node name="BazaarRoad" type="CSGBox3D" parent="RoadNetwork"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -45, 0.05, -42)
use_collision = true
collision_layer = 1
collision_mask = 31
size = Vector3(90, 0.1, 8.5)
material = SubResource("Mat_RoadAsphalt")

[node name="CanalBridge" parent="RoadNetwork" instance=ExtResource("10_bridge")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 50)

[node name="AutoWorkshop" parent="." instance=ExtResource("7_workshop")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -48, 0, 96)

[node name="CommercialMarket" parent="." instance=ExtResource("8_market")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -45, 0, -42.2)

[node name="PoliceStation" parent="." instance=ExtResource("9_policestation")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 75, 0, -105)

[node name="TriggerMission1" parent="." instance=ExtResource("6_trigger")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -48, 0, 96)
prompt_speaker = "Kabir Ustad"
trigger_color = Color(1, 0.8, 0.2, 0.8)

[node name="TriggerMission2" parent="." instance=ExtResource("6_trigger")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -38, 0, 26)
prompt_speaker = "Nila Chowdhury"
trigger_color = Color(0.2, 0.85, 1, 0.8)

[node name="TriggerMission3" parent="." instance=ExtResource("6_trigger")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 45, 0, -31)
prompt_speaker = "SI Mahfuz"
trigger_color = Color(0.2, 0.45, 1, 0.8)

[node name="TunedGreenCNG" parent="." instance=ExtResource("11_cng")]
transform = Transform3D(0.965926, 0, -0.258819, 0, 1, 0, 0.258819, 0, 0.965926, -44, 0.45, 92)

[node name="PrivateSedan" parent="." instance=ExtResource("12_sedan")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 3.8, 0.45, -28)

[node name="SyndicatePickup" parent="." instance=ExtResource("13_pickup")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -65, 0.45, 24)

[node name="DMPPoliceCruiser" parent="." instance=ExtResource("14_policesedan")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 82, 0.45, -98)

[node name="Player" parent="." instance=ExtResource("4_player")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -48, 0.5, 90)

[node name="HUD" parent="." instance=ExtResource("5_hud")]

[node name="PoliceRadarHUD" parent="." instance=ExtResource("15_radarhud")]
"""
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Generated: {out_path}")


if __name__ == "__main__":
    generate_test_controller()
    generate_test_scene()
    print("Story mission test harness successfully created!")
