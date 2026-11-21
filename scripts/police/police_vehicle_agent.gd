# ==============================================================================
# POLICE VEHICLE AI AGENT (POLICE SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Autonomous pursuit AI controller driving DMP Police Patrol Sedans
#          and Tactical Pickups. Features RoadNetwork3D waypoint navigation,
#          high-speed pursuit, tactical PIT maneuvers, roadblock cutoffs,
#          dual-mode sirens (wail/yelp), and flashing red/blue lightbars.
# ==============================================================================
class_name PoliceVehicleAgent
extends Node

enum PoliceDriveMode {
	CRUISE_PATROL,
	DISPATCH_DRIVE,
	VEHICLE_PURSUIT,
	STOP_DISMOUNT
}

@export var vehicle: BaseVehicle3D = null
@export var road_network: RoadNetwork3D = null
@export var target_lane: int = 1
@export var max_pursuit_speed_kmh: float = 125.0
@export var pit_maneuver_enabled: bool = true

var drive_mode: PoliceDriveMode = PoliceDriveMode.CRUISE_PATROL
var current_waypoint_id: int = 0
var target_waypoint_id: int = 0
var destination_pos: Vector3 = Vector3.ZERO

# Steering & Throttle AI
var lookahead_dist: float = 7.0
var ram_timer: float = 0.0
var lightbar_flash_timer: float = 0.0
var lightbar_phase: bool = false

# References
@onready var vision_sensor: PoliceVisionSensor = get_parent().get_node_or_null("VisionSensor") as PoliceVisionSensor
@onready var lightbar_root: Node3D = get_parent().get_node_or_null("Lightbar")
@onready var red_strobe: Light3D = get_parent().get_node_or_null("Lightbar/RedLight")
@onready var blue_strobe: Light3D = get_parent().get_node_or_null("Lightbar/BlueLight")
@onready var red_mesh: MeshInstance3D = get_parent().get_node_or_null("Lightbar/RedMesh")
@onready var blue_mesh: MeshInstance3D = get_parent().get_node_or_null("Lightbar/BlueMesh")
@onready var siren_audio: AudioStreamPlayer3D = get_parent().get_node_or_null("Audio/SirenAudio")


func _ready() -> void:
	if not vehicle and get_parent() is BaseVehicle3D:
		vehicle = get_parent() as BaseVehicle3D
	
	if not road_network:
		road_network = get_tree().get_first_node_in_group("road_network")
	
	if vehicle:
		vehicle.add_to_group("police_vehicles")
		if road_network:
			current_waypoint_id = road_network.get_nearest_waypoint(vehicle.global_position, target_lane)
			target_waypoint_id = road_network.get_next_waypoint(current_waypoint_id)
	
	EventBus.wanted_level_changed.connect(_on_wanted_level_changed)
	EventBus.crime_committed.connect(_on_crime_committed)
	
	_set_emergency_lights(false)


func _physics_process(delta: float) -> void:
	if not vehicle or vehicle.is_driven:
		return
	
	# Lightbar strobe update
	if drive_mode == PoliceDriveMode.DISPATCH_DRIVE or drive_mode == PoliceDriveMode.VEHICLE_PURSUIT:
		_process_lightbar(delta)
	
	match drive_mode:
		PoliceDriveMode.CRUISE_PATROL:
			_process_patrol(delta)
		PoliceDriveMode.DISPATCH_DRIVE:
			_process_dispatch(delta)
		PoliceDriveMode.VEHICLE_PURSUIT:
			_process_pursuit(delta)
		PoliceDriveMode.STOP_DISMOUNT:
			_apply_full_stop(delta)


func _process_patrol(delta: float) -> void:
	if not road_network:
		return
	
	var target_pos = road_network.get_waypoint_pos(target_waypoint_id)
	var to_target = target_pos - vehicle.global_position
	to_target.y = 0
	
	if to_target.length() < lookahead_dist:
		current_waypoint_id = target_waypoint_id
		target_waypoint_id = road_network.get_next_waypoint(current_waypoint_id)
	
	_steer_towards(target_pos, delta)
	
	# Cruise at 40 km/h
	var current_kmh = vehicle.linear_velocity.length() * 3.6
	if current_kmh < 42.0:
		vehicle.engine_force = vehicle.max_engine_force * 0.45
		vehicle.brake = 0.0
	else:
		vehicle.engine_force = 0.0
		vehicle.brake = 8.0


func _process_dispatch(delta: float) -> void:
	# Driving towards reported crime scene
	var dist_to_dest = vehicle.global_position.distance_to(destination_pos)
	
	if dist_to_dest < 18.0:
		# Arrived near crime scene, switch to search or dismount
		drive_mode = PoliceDriveMode.STOP_DISMOUNT
		return
	
	# If road network available, route towards destination; else direct drive
	var target_pos = destination_pos
	if road_network:
		var target_wp_pos = road_network.get_waypoint_pos(target_waypoint_id)
		var to_wp = target_wp_pos - vehicle.global_position
		to_wp.y = 0
		if to_wp.length() < lookahead_dist:
			current_waypoint_id = target_waypoint_id
			target_waypoint_id = road_network.get_next_waypoint(current_waypoint_id)
		target_pos = target_wp_pos
	
	_steer_towards(target_pos, delta)
	
	# Urgent dispatch speed (70 km/h)
	var current_kmh = vehicle.linear_velocity.length() * 3.6
	if current_kmh < 75.0:
		vehicle.engine_force = vehicle.max_engine_force * 0.8
		vehicle.brake = 0.0
	else:
		vehicle.engine_force = 0.0
		vehicle.brake = 12.0


func _process_pursuit(delta: float) -> void:
	var target_entity = _get_target_entity()
	if not is_instance_valid(target_entity):
		drive_mode = PoliceDriveMode.CRUISE_PATROL
		_set_emergency_lights(false)
		return
	
	var target_pos = target_entity.global_position
	var to_target = target_pos - vehicle.global_position
	var dist = to_target.length()
	
	# Tactical steering: predict target path or execute PIT maneuver
	var steer_target = target_pos
	if pit_maneuver_enabled and dist < 12.0 and target_entity is BaseVehicle3D:
		# Target the rear quarter of suspect car
		var suspect_rear = target_pos + target_entity.global_transform.basis.z * 1.8
		var suspect_side = target_entity.global_transform.basis.x * (1.6 if to_target.dot(target_entity.global_transform.basis.x) > 0 else -1.6)
		steer_target = suspect_rear + suspect_side
	
	_steer_towards(steer_target, delta)
	
	var current_kmh = vehicle.linear_velocity.length() * 3.6
	
	# Pursuit acceleration
	if dist > 8.0:
		if current_kmh < max_pursuit_speed_kmh:
			vehicle.engine_force = vehicle.max_engine_force * 1.15 # Police interceptor boost
			vehicle.brake = 0.0
		else:
			vehicle.engine_force = 0.0
	else:
		# Close range: ram or box in!
		if target_entity is BaseVehicle3D:
			# Ram suspect car
			vehicle.engine_force = vehicle.max_engine_force * 0.9
			vehicle.brake = 0.0
		else:
			# Suspect is on foot! Cut off and stop to dismount
			if dist < 6.0:
				drive_mode = PoliceDriveMode.STOP_DISMOUNT


func _apply_full_stop(_delta: float) -> void:
	vehicle.engine_force = 0.0
	vehicle.brake = vehicle.max_brake_force * 1.5


func _steer_towards(target_world_pos: Vector3, delta: float) -> void:
	var local_target := vehicle.to_local(target_world_pos)
	local_target.y = 0.0
	
	var target_steer_angle := -atan2(local_target.x, -local_target.z)
	target_steer_angle = clampf(target_steer_angle, -vehicle.max_steer_angle_rad, vehicle.max_steer_angle_rad)
	
	vehicle.target_steer = move_toward(vehicle.target_steer, target_steer_angle, vehicle.steer_speed * delta)
	vehicle.steering = vehicle.target_steer


func _process_lightbar(delta: float) -> void:
	lightbar_flash_timer += delta
	if lightbar_flash_timer >= 0.12:
		lightbar_flash_timer = 0.0
		lightbar_phase = not lightbar_phase
		
		if red_strobe:
			red_strobe.visible = lightbar_phase
		if blue_strobe:
			blue_strobe.visible = not lightbar_phase


func _set_emergency_lights(active: bool) -> void:
	if red_strobe:
		red_strobe.visible = active
	if blue_strobe:
		blue_strobe.visible = active
	
	if siren_audio:
		if active and not siren_audio.playing:
			siren_audio.play()
		elif not active and siren_audio.playing:
			siren_audio.stop()


func _on_wanted_level_changed(stars: int) -> void:
	if stars <= 0:
		drive_mode = PoliceDriveMode.CRUISE_PATROL
		_set_emergency_lights(false)
	else:
		drive_mode = PoliceDriveMode.VEHICLE_PURSUIT
		_set_emergency_lights(true)


func _on_crime_committed(_type: String, _sev: int, loc: Vector3) -> void:
	if drive_mode == PoliceDriveMode.CRUISE_PATROL:
		destination_pos = loc
		drive_mode = PoliceDriveMode.DISPATCH_DRIVE
		_set_emergency_lights(true)


func _get_target_entity() -> Node3D:
	if GameManager.current_state == GameManager.GameState.IN_VEHICLE and is_instance_valid(GameManager.active_vehicle):
		return GameManager.active_vehicle as Node3D
	return GameManager.active_player
