# ==============================================================================
# STORY MISSIONS TEST CONTROLLER (TEST SUITE)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Comprehensive diagnostic harness for Part 06 story missions,
#          interactive dialogue letterbox, objectives, checkpoints, fail/retry,
#          and SaveSystem serialization.
# ==============================================================================
extends Node3D

@onready var mission_system: MissionSystem = $MissionSystem if has_node("MissionSystem") else null
@onready var player: Player = $Player if has_node("Player") else null
@onready var trigger_1: MissionTrigger = $TriggerMission1 if has_node("TriggerMission1") else null
@onready var trigger_2: MissionTrigger = $TriggerMission2 if has_node("TriggerMission2") else null
@onready var trigger_3: MissionTrigger = $TriggerMission3 if has_node("TriggerMission3") else null

var telemetry_label: Label = null
var recent_dialogue_line: String = "None (Dialogue Idle)"
var active_timer_display: String = "N/A (Untimed)"


func _ready() -> void:
	_create_telemetry_ui()
	
	if trigger_1:
		trigger_1.mission_data = StoryMissions.get_mission_1()
	if trigger_2:
		trigger_2.mission_data = StoryMissions.get_mission_2()
	if trigger_3:
		trigger_3.mission_data = StoryMissions.get_mission_3()
	
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
	
	var info := "=== DTA BANGLADESH STORY & MISSION SYSTEM ===\n"
	info += "Active Mission: %s [%s]\n" % [m_title, m_type]
	info += "Current Objective (%d/%d): %s\n" % [m_step, total_steps, step_desc]
	info += "Mission Timer: %s\n" % active_timer_display
	info += "Recent Dialogue: %s\n" % recent_dialogue_line
	info += "Completed Missions Archive: %s\n" % completed_list
	info += "Player Wallet: ৳ %d BDT\n" % GameManager.wallet_bdt
	
	info += "\n[ STORY CONTROLS & DIAGNOSTICS ]\n"
	info += "  [1] Start Mission 01: Shadows & Spark Plugs (ছায়া ও চালক)\n"
	info += "  [2] Start Mission 02: Eyes of the Buriganga (বুড়িগঙ্গার চোখ)\n"
	info += "  [3] Start Mission 03: Smoke Over Padma (পদ্মার ধোঁয়া)\n"
	info += "  [N] Advance / Skip Current Objective Step\n"
	info += "  [R] Retry Mission from Last Checkpoint\n"
	info += "  [F] Trigger Mission Failure (Test somber audio & retry)\n"
	info += "  [K] Save Game State to user://dta_savegame.json\n"
	info += "  [L] Load Game State from JSON\n"
	info += "  [T] Teleport to Active Objective Waypoint Beacon\n"
	info += "  [Space / E] Advance Dialogue / Board Vehicle / Interact\n"
	
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
