# ==============================================================================
# AUTONOMOUS TRAFFIC VEHICLE AGENT (TRAFFIC SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: AI controller driving mixed traffic vehicles along RoadNetwork3D lanes,
#          handling obstacle avoidance, braking, traffic light stop lines,
#          congestion honk cascades, and overtaking.
# ==============================================================================
class_name TrafficVehicleAgent
extends Node

@export var vehicle: BaseVehicle3D = null
@export var road_network: RoadNetwork3D = null
@export var target_lane: int = 1

var current_waypoint_id: int = 0
var target_waypoint_id: int = 0

# Navigation & Obstacle Detection
var forward_lookahead_dist: float = 6.0
var safe_following_dist: float = 4.0
var stopped_timer: float = 0.0
var honk_cooldown: float = 0.0
var is_overtaking: bool = false
var overtake_offset: float = 0.0


func _ready() -> void:
	if not vehicle and get_parent() is BaseVehicle3D:
		vehicle = get_parent() as BaseVehicle3D
	
	if not road_network:
		road_network = get_tree().get_first_node_in_group("road_network")
	
	if road_network and vehicle:
		current_waypoint_id = road_network.get_nearest_waypoint(vehicle.global_position, target_lane)
		target_waypoint_id = road_network.get_next_waypoint(current_waypoint_id)
	
	EventBus.vehicle_horn_honked.connect(_on_nearby_horn_heard)


func _physics_process(delta: float) -> void:
	if not vehicle or not road_network or vehicle.is_driven:
		return
	
	honk_cooldown -= delta
	_process_ai_driving(delta)


func _process_ai_driving(delta: float) -> void:
	var target_pos = road_network.get_waypoint_pos(target_waypoint_id)
	if is_overtaking:
		target_pos += vehicle.global_transform.basis.x * overtake_offset
	
	var to_target: Vector3 = target_pos - vehicle.global_position
	to_target.y = 0
	
	# Advance to next waypoint when close
	if to_target.length() < forward_lookahead_dist:
		current_waypoint_id = target_waypoint_id
		target_waypoint_id = road_network.get_next_waypoint(current_waypoint_id)
		# Chance to reset overtaking
		if is_overtaking and randf() < 0.4:
			is_overtaking = false
			overtake_offset = 0.0
	
	# Obstacle Check
	var obstacle_ahead = _check_obstacle_ahead()
	var stop_line_active = road_network.is_stop_active(current_waypoint_id)
	
	var should_stop: bool = bool(obstacle_ahead["hit"] or stop_line_active)
	
	if should_stop:
		# Apply braking
		_apply_ai_braking(delta)
		
		# Congestion & Honking
		stopped_timer += delta
		if stopped_timer > 2.8 and honk_cooldown <= 0.0:
			vehicle.honk_horn()
			honk_cooldown = randf_range(3.5, 7.0)
			EventBus.traffic_jam_detected.emit("jam_main_road")
			# Check if we can overtake!
			_attempt_overtake()
	else:
		stopped_timer = 0.0
		_apply_ai_throttle(delta, to_target)
	
	_apply_ai_steering(delta, to_target)


func _check_obstacle_ahead() -> Dictionary:
	var space_state := vehicle.get_world_3d().direct_space_state
	var start_pos := vehicle.global_position + Vector3(0, 0.5, 0)
	var forward_dir := -vehicle.global_transform.basis.z
	
	# Dynamic ray length based on current speed
	var current_kmh := vehicle.linear_velocity.length() * 3.6
	var ray_length := clampf(safe_following_dist + (current_kmh * 0.25), 4.0, 20.0)
	var end_pos := start_pos + (forward_dir * ray_length)
	
	var query := PhysicsRayQueryParameters3D.create(start_pos, end_pos)
	query.exclude = [vehicle.get_rid()]
	query.collision_mask = (1 << 1) | (1 << 2) | (1 << 3) # Player, Vehicles, Pedestrians
	
	var result = space_state.intersect_ray(query)
	if not result.is_empty():
		return {"hit": true, "distance": start_pos.distance_to(result["position"]), "collider": result["collider"]}
	return {"hit": false, "distance": ray_length, "collider": null}


func _apply_ai_throttle(_delta: float, _to_target: Vector3) -> void:
	var target_speed_kmh := 50.0
	if current_waypoint_id in road_network.waypoints:
		target_speed_kmh = road_network.waypoints[current_waypoint_id].get("speed_limit", 50.0)
	
	var current_kmh := vehicle.linear_velocity.length() * 3.6
	
	if current_kmh < target_speed_kmh:
		# Throttle up
		var throttle_force = vehicle.max_engine_force * 0.65
		for w in vehicle.rear_wheels:
			w.engine_force = throttle_force
			w.brake = 0.0
		for w in vehicle.front_wheels:
			w.brake = 0.0
	else:
		# Coast
		for w in vehicle.all_wheels:
			w.engine_force = 0.0
			w.brake = 4.0


func _apply_ai_braking(_delta: float) -> void:
	for w in vehicle.all_wheels:
		w.engine_force = 0.0
		w.brake = vehicle.max_brake_force * 0.9


func _apply_ai_steering(delta: float, to_target: Vector3) -> void:
	var local_target := vehicle.global_transform.basis.inverse() * to_target
	var steer_angle := -atan2(local_target.x, -local_target.z)
	
	var max_steer = vehicle.max_steer_angle_rad
	var clamped_steer = clampf(steer_angle, -max_steer, max_steer)
	vehicle.steering = lerpf(vehicle.steering, clamped_steer, vehicle.steer_speed * delta)


func _attempt_overtake() -> void:
	if is_overtaking:
		return
	
	var space_state := vehicle.get_world_3d().direct_space_state
	# Check adjacent lane (offset X = 2.4m)
	var right_dir = vehicle.global_transform.basis.x
	var check_start = vehicle.global_position + (right_dir * 2.4) + Vector3(0, 0.5, 0)
	var forward_dir = -vehicle.global_transform.basis.z
	var check_end = check_start + (forward_dir * 18.0)
	
	var query = PhysicsRayQueryParameters3D.create(check_start, check_end)
	query.exclude = [vehicle.get_rid()]
	query.collision_mask = (1 << 2) # Vehicles
	
	var hit = space_state.intersect_ray(query)
	if hit.is_empty():
		# Path is clear to pass!
		is_overtaking = true
		overtake_offset = 2.4


func _on_nearby_horn_heard(other_vehicle: Node) -> void:
	if other_vehicle == vehicle or not is_instance_valid(vehicle):
		return
	
	# If this vehicle is stopped in traffic and hears another honk, participate in the honk cascade!
	if stopped_timer > 1.2 and honk_cooldown <= 0.0:
		if vehicle.global_position.distance_to(other_vehicle.global_position) < 25.0:
			# Staggered reply honk
			await get_tree().create_timer(randf_range(0.3, 0.8)).timeout
			if is_instance_valid(vehicle) and not vehicle.is_driven:
				vehicle.honk_horn()
				honk_cooldown = randf_range(4.0, 8.0)
