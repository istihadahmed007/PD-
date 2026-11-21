# ==============================================================================
# MISSION SYSTEM COORDINATOR (MISSION SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Master mission engine managing narrative quests, dynamic 3D beacons,
#          dialogue letterbox sequences, checkpoints, fail/retry, rewards,
#          and persistence integration with SaveSystem.
# ==============================================================================
class_name MissionSystem
extends Node

signal mission_started(mission_id: String, title: String)
signal objective_updated(step_index: int, description: String, target_pos: Vector3)
signal checkpoint_saved(checkpoint_index: int, location: Vector3)
signal mission_completed(mission_id: String, reward_bdt: int)
signal mission_failed(mission_id: String, reason: String)
signal mission_retried(mission_id: String)

@export var beacon_scene: PackedScene = preload("res://missions/mission_waypoint_beacon.tscn")
@export var dialogue_ui_scene: PackedScene = preload("res://ui/mission_ui/mission_dialogue_ui.tscn")

var active_mission: MissionResource = null
var current_step_index: int = 0
var completed_mission_ids: Array[String] = []

# Step Execution Attributes
var current_checkpoint_pos: Vector3 = Vector3.ZERO
var step_timer: float = 0.0
var is_timed_step: bool = false
var fragile_cargo_active: bool = false
var initial_vehicle_health: float = 100.0

# Active Entities & Sub-nodes
var active_beacon: MissionWaypointBeacon = null
var dialogue_ui: MissionDialogueUI = null

# Audio
var audio_start: AudioStreamPlayer = null
var audio_update: AudioStreamPlayer = null
var audio_checkpoint: AudioStreamPlayer = null
var audio_complete: AudioStreamPlayer = null
var audio_fail: AudioStreamPlayer = null


func _ready() -> void:
	add_to_group("mission_system")
	_setup_audio_players()
	_setup_beacon_and_ui()
	_load_saved_progress()
	
	EventBus.player_died.connect(_on_player_died)


func _setup_audio_players() -> void:
	audio_start = _create_audio_player("res://audio/missions/mission_started.wav")
	audio_update = _create_audio_player("res://audio/missions/objective_updated.wav")
	audio_checkpoint = _create_audio_player("res://audio/missions/checkpoint_reached.wav")
	audio_complete = _create_audio_player("res://audio/missions/mission_completed.wav")
	audio_fail = _create_audio_player("res://audio/missions/mission_failed.wav")


func _create_audio_player(path: String) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	if ResourceLoader.exists(path):
		player.stream = load(path)
	player.volume_db = -2.0
	add_child(player)
	return player


func _setup_beacon_and_ui() -> void:
	if beacon_scene:
		active_beacon = beacon_scene.instantiate() as MissionWaypointBeacon
		active_beacon.name = "ActiveMissionBeacon"
		add_child(active_beacon)
		active_beacon.beacon_reached.connect(_on_beacon_reached)
		active_beacon.hide_beacon()
	
	if dialogue_ui_scene:
		var canvas = CanvasLayer.new()
		canvas.name = "DialogueCanvas"
		canvas.layer = 20
		add_child(canvas)
		
		dialogue_ui = dialogue_ui_scene.instantiate() as MissionDialogueUI
		canvas.add_child(dialogue_ui)
		dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)


func _load_saved_progress() -> void:
	var data = SaveSystem.load_game()
	if data and data.has("missions") and data["missions"].has("completed"):
		for m_id in data["missions"]["completed"]:
			if not completed_mission_ids.has(str(m_id)):
				completed_mission_ids.append(str(m_id))


func _physics_process(delta: float) -> void:
	if not active_mission:
		return
	
	var step = active_mission.get_step(current_step_index)
	if step.is_empty():
		return
	
	# 1. Timer countdown for timed objectives
	if is_timed_step:
		step_timer -= delta
		EventBus.mission_timer_updated.emit(maxf(0.0, step_timer))
		if step_timer <= 0.0:
			fail_mission("Time expired! Failed to reach destination in time.")
			return
	
	# 2. Fragile cargo monitoring
	if fragile_cargo_active and GameManager.current_state == GameManager.GameState.IN_VEHICLE:
		var veh = GameManager.active_vehicle as BaseVehicle3D
		if veh and veh.current_health < (veh.max_health * 0.45):
			fail_mission("Cargo destroyed! Vehicle sustained critical impact damage.")
			return


func start_mission(mission: MissionResource) -> void:
	if not mission:
		return
	
	active_mission = mission
	current_step_index = 0
	
	if audio_start and audio_start.stream:
		audio_start.play()
	
	EventBus.mission_started.emit(mission.mission_id, mission.title)
	
	# Establish starting checkpoint at player position
	if is_instance_valid(GameManager.active_player):
		current_checkpoint_pos = GameManager.active_player.global_position
	
	_execute_current_step()


func _execute_current_step() -> void:
	if not active_mission:
		return
	
	var step = active_mission.get_step(current_step_index)
	if step.is_empty():
		complete_mission()
		return
	
	var desc = step.get("description", "Objective")
	var target_pos = step.get("target_position", Vector3.ZERO)
	var target_radius = step.get("target_radius", 4.5)
	var time_limit = step.get("time_limit", 0.0)
	var checkpoint = step.get("checkpoint", Vector3.ZERO)
	var dialogue_before = step.get("dialogue_before", "")
	
	# Save checkpoint if specified
	if checkpoint != Vector3.ZERO:
		current_checkpoint_pos = checkpoint
		if audio_checkpoint and audio_checkpoint.stream:
			audio_checkpoint.play()
		checkpoint_saved.emit(current_step_index, current_checkpoint_pos)
		EventBus.mission_checkpoint_reached.emit(current_step_index, current_checkpoint_pos)
	
	# Timer setup
	if time_limit > 0.0:
		is_timed_step = true
		step_timer = time_limit
	else:
		is_timed_step = false
		step_timer = 0.0
	
	fragile_cargo_active = step.get("fragile_cargo", false)
	
	# Setup visual 3D beacon
	if active_beacon and target_pos != Vector3.ZERO:
		active_beacon.set_beacon_data(target_pos, desc, target_radius)
	elif active_beacon:
		active_beacon.hide_beacon()
	
	EventBus.mission_objective_updated.emit(current_step_index, desc)
	objective_updated.emit(current_step_index, desc, target_pos)
	
	# Play opening dialogue if configured
	if not dialogue_before.is_empty() and dialogue_ui:
		var lines = active_mission.get_dialogue(dialogue_before)
		if not lines.is_empty():
			dialogue_ui.play_dialogue_sequence(lines)


func advance_objective() -> void:
	if not active_mission:
		return
	
	var step = active_mission.get_step(current_step_index)
	var dialogue_after = step.get("dialogue_after", "")
	
	# If dialogue after step, play it then advance
	if not dialogue_after.is_empty() and dialogue_ui:
		var lines = active_mission.get_dialogue(dialogue_after)
		if not lines.is_empty():
			dialogue_ui.play_dialogue_sequence(lines)
			await dialogue_ui.dialogue_finished
	
	current_step_index += 1
	
	if current_step_index < active_mission.get_total_steps():
		if audio_update and audio_update.stream:
			audio_update.play()
		_execute_current_step()
	else:
		complete_mission()


func complete_mission() -> void:
	if not active_mission:
		return
	
	var id = active_mission.mission_id
	var reward = active_mission.reward_bdt
	
	if not completed_mission_ids.has(id):
		completed_mission_ids.append(id)
	
	GameManager.add_money(reward)
	
	if audio_complete and audio_complete.stream:
		audio_complete.play()
	
	EventBus.mission_completed.emit(id, reward)
	mission_completed.emit(id, reward)
	
	# Hide beacon
	if active_beacon:
		active_beacon.hide_beacon()
	
	# Auto-save game progression
	var player_pos = GameManager.active_player.global_position if is_instance_valid(GameManager.active_player) else Vector3.ZERO
	SaveSystem.save_game(player_pos, GameManager.wallet_bdt, GameManager.wanted_stars, completed_mission_ids)
	
	active_mission = null
	current_step_index = 0
	is_timed_step = false
	fragile_cargo_active = false


func fail_mission(reason: String) -> void:
	if not active_mission:
		return
	
	var id = active_mission.mission_id
	if audio_fail and audio_fail.stream:
		audio_fail.play()
	
	EventBus.mission_failed.emit(id, reason)
	mission_failed.emit(id, reason)
	
	if active_beacon:
		active_beacon.hide_beacon()
	
	is_timed_step = false
	fragile_cargo_active = false


func retry_mission() -> void:
	if not active_mission:
		return
	
	var id = active_mission.mission_id
	
	# Respawn player at last checkpoint
	if is_instance_valid(GameManager.active_player):
		GameManager.active_player.global_position = current_checkpoint_pos
		GameManager.active_player.current_health = GameManager.active_player.max_health
		EventBus.player_health_changed.emit(GameManager.active_player.current_health, GameManager.active_player.max_health)
	
	# Clear police heat if failed during police pursuit
	GameManager.set_wanted_level(0)
	
	EventBus.mission_retried.emit(id)
	mission_retried.emit(id)
	
	# Re-execute current step
	_execute_current_step()


func _on_beacon_reached(_body: Node) -> void:
	advance_objective()


func _on_dialogue_finished() -> void:
	# Optional hook when dialogue ends
	pass


func _on_player_died() -> void:
	if active_mission:
		fail_mission("Joy collapsed from severe injuries!")
