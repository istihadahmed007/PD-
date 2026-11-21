# ==============================================================================
# POLICE SYSTEM (MASTER HEAT & RESPONSE ORCHESTRATOR)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Orchestrates Dhaka Metropolitan Police (DMP) heat levels (1-5 stars),
#          line-of-sight tracking, search areas, evasion cooldowns, and navigation-based
#          patrol/pursuit dispatching without artificial teleportation.
# ==============================================================================
class_name PoliceSystem
extends Node

enum PursuitState {
	PEACEFUL,
	PURSUIT,
	SEARCHING_EVADING,
	ARRESTED
}

@export_category("Evasion & Search Settings")
@export var base_evade_time_per_star: float = 18.0
@export var search_radius_per_star: float = 28.0
@export var outside_zone_cooldown_multiplier: float = 2.0

var current_wanted_stars: int = 0
var current_pursuit_state: PursuitState = PursuitState.PEACEFUL
var last_known_player_position: Vector3 = Vector3.ZERO
var current_search_radius: float = 40.0
var time_out_of_sight: float = 0.0
var required_evade_time: float = 20.0
var is_player_spotted: bool = false

# Dispatch Tracking
var max_active_cruisers: int = 4
var max_active_officers: int = 6
var dispatch_cooldown: float = 0.0

# Road network reference for navigation-based spawning
var road_network: RoadNetwork3D = null


func _ready() -> void:
	EventBus.crime_committed.connect(_on_crime_committed)
	EventBus.wanted_level_changed.connect(_on_wanted_level_changed)
	EventBus.police_spotted_player.connect(_on_police_spotted_player)
	EventBus.police_arrest_triggered.connect(_on_police_arrest_triggered)
	
	road_network = get_tree().get_first_node_in_group("road_network")


func _process(delta: float) -> void:
	if current_wanted_stars <= 0:
		return
	
	dispatch_cooldown -= delta
	
	# Aggregate Line-of-Sight from all active police units
	_update_global_line_of_sight()
	
	if is_player_spotted:
		# Active pursuit: update last known position and reset evasion timer
		current_pursuit_state = PursuitState.PURSUIT
		time_out_of_sight = 0.0
		
		var target_pos = _get_player_or_vehicle_position()
		last_known_player_position = target_pos
		EventBus.police_search_area_updated.emit(last_known_player_position, current_search_radius, false)
	else:
		# Police have lost line of sight: enter or continue search/evasion mode
		current_pursuit_state = PursuitState.SEARCHING_EVADING
		
		# Check if player is outside search radius
		var player_pos = _get_player_or_vehicle_position()
		var dist_to_search_center = player_pos.distance_to(last_known_player_position)
		var is_outside_zone = dist_to_search_center > current_search_radius
		
		# Cooldown ticks faster when escaping outside search perimeter
		var rate = outside_zone_cooldown_multiplier if is_outside_zone else 1.0
		time_out_of_sight += delta * rate
		
		EventBus.police_search_area_updated.emit(last_known_player_position, current_search_radius, true)
		
		# Check evasion completion
		if time_out_of_sight >= required_evade_time:
			_cooldown_wanted_step()


func _update_global_line_of_sight() -> void:
	var any_sees_player = false
	
	# Check on-foot officers
	var officers = get_tree().get_nodes_in_group("police_officers")
	for officer in officers:
		if is_instance_valid(officer) and officer.has_node("VisionSensor"):
			var sensor: PoliceVisionSensor = officer.get_node("VisionSensor") as PoliceVisionSensor
			if sensor and sensor.can_see_player:
				any_sees_player = true
				break
	
	# Check police cruisers
	if not any_sees_player:
		var vehicles = get_tree().get_nodes_in_group("police_vehicles")
		for v in vehicles:
			if is_instance_valid(v) and v.has_node("VisionSensor"):
				var sensor: PoliceVisionSensor = v.get_node("VisionSensor") as PoliceVisionSensor
				if sensor and sensor.can_see_player:
					any_sees_player = true
					break
	
	is_player_spotted = any_sees_player


func _on_crime_committed(crime_type: String, severity: int, location: Vector3) -> void:
	last_known_player_position = location
	time_out_of_sight = 0.0
	
	# Escalate wanted level based on severity
	var new_stars = clampi(current_wanted_stars + severity, 1, 5)
	GameManager.set_wanted_level(new_stars)
	
	# Dispatch dynamic reinforcement units using road network navigation
	_dispatch_response_units(crime_type, location)


func _on_wanted_level_changed(new_stars: int) -> void:
	current_wanted_stars = new_stars
	
	if current_wanted_stars <= 0:
		current_pursuit_state = PursuitState.PEACEFUL
		time_out_of_sight = 0.0
		is_player_spotted = false
		EventBus.police_search_area_updated.emit(Vector3.ZERO, 0.0, false)
		EventBus.police_pursuit_evaded.emit()
	else:
		required_evade_time = 14.0 + (current_wanted_stars * base_evade_time_per_star)
		current_search_radius = 25.0 + (current_wanted_stars * search_radius_per_star)
		current_pursuit_state = PursuitState.PURSUIT
		EventBus.police_pursuit_started.emit()


func _on_police_spotted_player(_officer: Node, location: Vector3) -> void:
	last_known_player_position = location
	time_out_of_sight = 0.0
	is_player_spotted = true
	current_pursuit_state = PursuitState.PURSUIT


func _on_police_arrest_triggered(_officer: Node) -> void:
	current_pursuit_state = PursuitState.ARRESTED
	time_out_of_sight = 0.0
	is_player_spotted = false


func _cooldown_wanted_step() -> void:
	time_out_of_sight = 0.0
	if current_wanted_stars > 1:
		GameManager.set_wanted_level(current_wanted_stars - 1)
	else:
		GameManager.set_wanted_level(0)


func _dispatch_response_units(crime_type: String, location: Vector3) -> void:
	if dispatch_cooldown > 0.0:
		return
	dispatch_cooldown = 4.0
	
	# Determine response units based on location and severity
	# Narrow alley / walking bazaar -> foot patrol / motorcycle
	# Main road / high severity -> patrol cars and tactical pickups
	var active_cruisers = get_tree().get_nodes_in_group("police_vehicles").size()
	
	if current_wanted_stars >= 2 and active_cruisers < max_active_cruisers:
		_dispatch_patrol_car(location)


func _dispatch_patrol_car(target_location: Vector3) -> void:
	if not road_network:
		road_network = get_tree().get_first_node_in_group("road_network")
	
	# Find a road waypoint outside the player's direct camera frustum (e.g. 60-80m away)
	var spawn_pos := Vector3.ZERO
	var spawn_rot := 0.0
	
	if road_network:
		var candidate_wps = road_network.waypoints
		var best_dist := 0.0
		for wp in candidate_wps:
			var d = wp.pos.distance_to(target_location)
			if d >= 50.0 and d <= 95.0:
				spawn_pos = wp.pos + Vector3(0, 0.45, 0)
				spawn_rot = wp.target_heading if "target_heading" in wp else 0.0
				break
	
	# If no road waypoint, spawn offset from crime scene
	if spawn_pos == Vector3.ZERO:
		var offset = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)).normalized() * 65.0
		spawn_pos = target_location + offset
		spawn_pos.y = 0.45
	
	# Instance police patrol sedan
	var sedan_scene = load("res://vehicles/police/police_sedan.tscn")
	if sedan_scene:
		var car: BaseVehicle3D = sedan_scene.instantiate()
		car.global_position = spawn_pos
		car.rotation.y = spawn_rot
		get_parent().add_child(car)
		
		# Command vehicle AI to dispatch to scene
		if car.has_node("PoliceVehicleAgent"):
			var agent: PoliceVehicleAgent = car.get_node("PoliceVehicleAgent") as PoliceVehicleAgent
			agent.destination_pos = target_location
			agent.drive_mode = PoliceVehicleAgent.PoliceDriveMode.DISPATCH_DRIVE
			agent._set_emergency_lights(true)


func _get_player_or_vehicle_position() -> Vector3:
	if GameManager.current_state == GameManager.GameState.IN_VEHICLE and is_instance_valid(GameManager.active_vehicle):
		return (GameManager.active_vehicle as Node3D).global_position
	elif is_instance_valid(GameManager.active_player):
		return GameManager.active_player.global_position
	return Vector3.ZERO
