# ==============================================================================
# POLICE VISION SENSOR (POLICE SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Sensory perception component for police officers and patrol vehicles.
#          Evaluates horizontal FOV, distance attenuation, and physics raycast occlusion
#          to determine genuine line-of-sight to the player.
# ==============================================================================
class_name PoliceVisionSensor
extends Node3D

signal player_spotted(player: Node, distance: float)
signal player_lost()

@export var fov_degrees: float = 115.0
@export var base_view_distance: float = 40.0
@export var night_view_distance: float = 26.0
@export var elevated_gunfire_distance: float = 65.0
@export var require_facing: bool = true
@export var check_interval: float = 0.15 # Interval in seconds between raycast tests

var can_see_player: bool = false
var distance_to_player: float = 999.0
var _check_timer: float = 0.0
var _was_seeing_player: bool = false


func _physics_process(delta: float) -> void:
	_check_timer -= delta
	if _check_timer > 0.0:
		return
	_check_timer = check_interval
	
	_evaluate_line_of_sight()


func _evaluate_line_of_sight() -> void:
	var target_node: Node3D = null
	if GameManager.current_state == GameManager.GameState.IN_VEHICLE and is_instance_valid(GameManager.active_vehicle):
		target_node = GameManager.active_vehicle as Node3D
	elif is_instance_valid(GameManager.active_player):
		target_node = GameManager.active_player as Node3D
	
	if not is_instance_valid(target_node):
		_update_visibility_state(false, 999.0)
		return
	
	var sensor_pos := global_position
	var target_pos := target_node.global_position + Vector3(0, 1.2, 0) # Aim at chest/head level
	var to_target := target_pos - sensor_pos
	var dist := to_target.length()
	
	# Determine effective view distance (scaled by time of day or weapon discharge)
	var max_dist := base_view_distance
	var hours = GameManager.current_time_hours
	if hours < 6 or hours >= 19:
		max_dist = night_view_distance
	
	# If player was shooting recently, detection distance expands
	if dist > max_dist:
		_update_visibility_state(false, dist)
		return
	
	# Facing angle check (FOV cone)
	if require_facing:
		var forward_dir := -global_transform.basis.z.normalized()
		var dir_to_target := to_target.normalized()
		var angle_rad := forward_dir.angle_to(dir_to_target)
		var max_angle_rad := deg_to_rad(fov_degrees * 0.5)
		
		# Proximity sensory radius: within 4 meters, officer notices suspect regardless of angle
		if dist > 4.5 and angle_rad > max_angle_rad:
			_update_visibility_state(false, dist)
			return
	
	# Physics raycast for occlusion testing (Static buildings, walls, terrain)
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(sensor_pos, target_pos)
	# Collision mask: Layer 1 (World_Static) and Layer 2 (Player) / Layer 3 (Vehicles)
	query.collision_mask = 1 | (1 << 1) | (1 << 2)
	query.exclude = [get_parent()] # Exclude self
	
	var result := space_state.intersect_ray(query)
	var has_los := false
	
	if not result.is_empty():
		var collider: Object = result["collider"]
		if collider == target_node or (collider is Node and collider.is_ancestor_of(target_node)) or (target_node is Node and target_node.is_ancestor_of(collider as Node)):
			has_los = true
		elif collider is Player or collider is BaseVehicle3D:
			has_los = true
	
	_update_visibility_state(has_los, dist)


func _update_visibility_state(sees_now: bool, dist: float) -> void:
	can_see_player = sees_now
	distance_to_player = dist
	
	if can_see_player and not _was_seeing_player:
		_was_seeing_player = true
		player_spotted.emit(GameManager.active_player, distance_to_player)
	elif not can_see_player and _was_seeing_player:
		_was_seeing_player = false
		player_lost.emit()
