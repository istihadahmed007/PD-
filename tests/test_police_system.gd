# ==============================================================================
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
	
	var info := "=== DTA POLICE & WANTED SYSTEM DIAGNOSTICS ===
"
	info += "Wanted Heat Rating: %d / 5 Stars %s
" % [stars, ("★" * stars + "☆" * (5 - stars))]
	info += "Pursuit State: %s | LOS: %s
" % [state_name, los_status]
	info += "Evasion Cooldown: %2.1fs / %2.1fs (Timer ticks 2x outside zone)
" % [out_of_sight, req_time]
	info += "Search Zone: Radius %2.0fm | Distance from Center: %2.1fm
" % [s_radius, dist_to_search]
	info += "Nearest Police Officer: %2.1fm | Nearest Cruiser: %2.1fm
" % [nearest_police_dist, nearest_cruiser_dist]
	info += "Recent Crime Event: %s
" % recent_crime_log
	info += "Recent 999 Witness Call: %s
" % recent_witness_log
	
	info += "
[ PLAYABLE TEST SCENARIO CONTROLS ]
"
	info += "  [1] Commit Minor Theft (1 Star)
"
	info += "  [2] Brandish Weapon in Public (1 Star)
"
	info += "  [3] Discharge Firearm / Shoot (2 Stars)
"
	info += "  [4] Vehicular Hit & Run (3 Stars)
"
	info += "  [5] Assault Police / Max Lockdown (4-5 Stars)
"
	info += "  [C] Clear Wanted Rating (Surrender / Evade Reset)
"
	info += "  [T] Teleport Suspect to Police Thana (Test Desk / Bail / Armory)
"
	info += "  [B] Teleport Suspect to Canal Bridge Checkpoint (Test Roadblock / Spikes)
"
	info += "  [W, A, S, D, Space, Shift] Player Locomotion / Sprint / Jump
"
	info += "  [E] Board Vehicle / Speak with Duty Officer
"
	
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
