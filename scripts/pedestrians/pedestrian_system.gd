# ==============================================================================
# PEDESTRIAN CROWD SIMULATION SYSTEM (PEDESTRIAN SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Manages open-world pedestrian population density, streaming rings,
#          diverse demographic archetypes, day/night schedules, and sidewalk routes.
# ==============================================================================
class_name PedestrianSystem
extends Node3D

@export var pedestrian_density: float = 0.75 # 0.0 = empty, 1.0 = Dhaka rush hour
@export var max_pedestrians: int = 30
@export var spawn_radius_min: float = 18.0
@export var spawn_radius_max: float = 65.0
@export var despawn_radius: float = 75.0

const PEDESTRIAN_SCENE = preload("res://characters/pedestrians/bangladeshi_pedestrian.tscn")

var active_pedestrians: Array[BangladeshiPedestrian] = []
var player_ref: Node3D = null
var spawn_timer: float = 0.0

# Sidewalk Waypoint Graph for Pedestrians
var sidewalk_routes: Array[Array] = []


func _ready() -> void:
	_init_sidewalk_routes()
	EventBus.time_of_day_updated.connect(_on_time_of_day_updated)


func _init_sidewalk_routes() -> void:
	# Route 1: Main Road West Sidewalk (Z: -160m -> +160m, X = -5.2)
	sidewalk_routes.append([
		Vector3(-5.2, 0.2, -160.0),
		Vector3(-5.2, 0.2, -100.0),
		Vector3(-5.2, 0.2, -50.0),
		Vector3(-5.2, 0.2, -15.0),
		Vector3(-5.2, 0.2, 20.0),
		Vector3(-4.9, 0.95, 50.0), # Bridge Walkway West
		Vector3(-5.2, 0.2, 85.0),
		Vector3(-5.2, 0.2, 160.0)
	])
	
	# Route 2: Main Road East Sidewalk (Z: +160m -> -160m, X = +5.2)
	sidewalk_routes.append([
		Vector3(5.2, 0.2, 160.0),
		Vector3(5.2, 0.2, 85.0),
		Vector3(4.9, 0.95, 50.0), # Bridge Walkway East
		Vector3(5.2, 0.2, 20.0),
		Vector3(5.2, 0.2, -15.0),
		Vector3(5.2, 0.2, -50.0),
		Vector3(5.2, 0.2, -100.0),
		Vector3(5.2, 0.2, -160.0)
	])
	
	# Route 3: Commercial Bazaar Footpath (Z = -42.2m, X: -120m -> 10m)
	sidewalk_routes.append([
		Vector3(-120.0, 0.2, -42.2),
		Vector3(-75.0, 0.2, -42.2),
		Vector3(-45.0, 0.2, -42.2), # Shopfronts
		Vector3(-15.0, 0.2, -32.0), # Bismillah Tea Stall
		Vector3(5.2, 0.2, -38.0)
	])
	
	# Route 4: Riverside Ghat Path (Z = 24m, X: -5m -> -70m)
	sidewalk_routes.append([
		Vector3(-5.2, 0.2, 24.0),
		Vector3(-25.0, 0.2, 24.0),
		Vector3(-38.0, 0.0, 26.0), # Stepped Ghat
		Vector3(-65.0, 0.2, 24.0)
	])


func _process(delta: float) -> void:
	if not player_ref and GameManager.active_player:
		player_ref = GameManager.active_player
	
	if not player_ref:
		return
	
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_timer = randf_range(1.5, 3.0)
		_manage_pedestrian_population()


func _manage_pedestrian_population() -> void:
	var target_count = int(max_pedestrians * pedestrian_density)
	
	# Despawn distant pedestrians
	var i = active_pedestrians.size() - 1
	while i >= 0:
		var ped = active_pedestrians[i]
		if not is_instance_valid(ped):
			active_pedestrians.remove_at(i)
		else:
			var dist = ped.global_position.distance_to(player_ref.global_position)
			if dist > despawn_radius:
				ped.queue_free()
				active_pedestrians.remove_at(i)
		i -= 1
	
	# Spawn new pedestrians if under target
	if active_pedestrians.size() < target_count:
		_spawn_pedestrian_near_player()


func _spawn_pedestrian_near_player() -> void:
	if sidewalk_routes.is_empty():
		return
	
	var route_idx = randi() % sidewalk_routes.size()
	var route: Array = sidewalk_routes[route_idx]
	if route.is_empty():
		return
	
	var wp_idx = randi() % route.size()
	var spawn_pos: Vector3 = route[wp_idx]
	var dist_to_player = spawn_pos.distance_to(player_ref.global_position)
	
	# Must be within spawn ring (not on top of player, not too far)
	if dist_to_player < spawn_radius_min or dist_to_player > spawn_radius_max:
		return
	
	var ped: BangladeshiPedestrian = PEDESTRIAN_SCENE.instantiate()
	ped.position = spawn_pos
	
	# Randomize archetype (0 = Chacha, 1 = Youth, 2 = Hawker, 3 = Babu, 4 = Salwar)
	var archetypes = [
		BangladeshiPedestrian.Archetype.CHACHA_PANJABI,
		BangladeshiPedestrian.Archetype.STUDENT_YOUTH,
		BangladeshiPedestrian.Archetype.HAWKER_LUNGI,
		BangladeshiPedestrian.Archetype.OFFICE_BABU,
		BangladeshiPedestrian.Archetype.FEMALE_SALWAR
	]
	ped.archetype = archetypes[randi() % archetypes.size()]
	
	# Assign route
	ped.waypoint_path = []
	for p in route:
		ped.waypoint_path.append(p)
	ped.path_index = wp_idx
	
	add_child(ped)
	active_pedestrians.append(ped)


func _on_time_of_day_updated(hours: int, _minutes: int, _norm: float) -> void:
	# Dynamic Day/Night Schedule Modulation
	if hours >= 7 and hours <= 18:
		# Daytime commercial peak
		pedestrian_density = 0.85
	elif hours > 18 and hours <= 23:
		# Evening tea stall and bazaar peak
		pedestrian_density = 1.0
	else:
		# Late night tranquility
		pedestrian_density = 0.25
