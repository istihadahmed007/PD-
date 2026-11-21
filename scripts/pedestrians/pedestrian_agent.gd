# ==============================================================================
# PEDESTRIAN AGENT (PEDESTRIAN SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Autonomous street pedestrian AI with wandering, chatter, and panic states.
# ==============================================================================
class_name PedestrianAgent
extends CharacterBody3D

enum PedestrianState {
	WANDER,
	IDLE_CHATTING,
	WAIT_AT_CROSSING,
	PANIC_FLEE
}

@export var walk_speed: float = 2.4
@export var panic_run_speed: float = 6.8
@export var gravity: float = 16.0

@export var waypoints: Array[Node3D] = []

var current_state: PedestrianState = PedestrianState.WANDER
var current_waypoint_index: int = 0
var panic_source: Vector3 = Vector3.ZERO
var panic_timer: float = 0.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null


func _ready() -> void:
	collision_layer = 1 << 3 # Layer 4: Pedestrians
	collision_mask = 1 | (1 << 1) | (1 << 2) # World, Player, Vehicles
	EventBus.pedestrian_panicked.connect(_on_panic_signal)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = -0.1
	
	match current_state:
		PedestrianState.WANDER:
			_process_wander(delta)
		PedestrianState.PANIC_FLEE:
			_process_panic(delta)
		PedestrianState.IDLE_CHATTING:
			velocity.x = 0
			velocity.z = 0
	
	move_and_slide()


func _process_wander(delta: float) -> void:
	if waypoints.is_empty():
		return
	
	var target = waypoints[current_waypoint_index]
	if not is_instance_valid(target):
		return
	
	var to_target = target.global_position - global_position
	to_target.y = 0
	
	if to_target.length() < 1.2:
		current_waypoint_index = (current_waypoint_index + 1) % waypoints.size()
		return
	
	var move_dir = to_target.normalized()
	velocity.x = move_dir.x * walk_speed
	velocity.z = move_dir.z * walk_speed
	
	# Rotate towards walking direction
	var target_basis = Basis.looking_at(move_dir, Vector3.UP)
	transform.basis = transform.basis.slerp(target_basis, 6.0 * delta)


func _process_panic(delta: float) -> void:
	panic_timer -= delta
	if panic_timer <= 0:
		current_state = PedestrianState.WANDER
		return
	
	# Run directly away from panic source
	var flee_dir = (global_position - panic_source)
	flee_dir.y = 0
	if flee_dir.length() < 0.1:
		flee_dir = Vector3.FORWARD
	flee_dir = flee_dir.normalized()
	
	velocity.x = flee_dir.x * panic_run_speed
	velocity.z = flee_dir.z * panic_run_speed
	
	var target_basis = Basis.looking_at(flee_dir, Vector3.UP)
	transform.basis = transform.basis.slerp(target_basis, 10.0 * delta)


func trigger_panic(threat_origin: Vector3) -> void:
	panic_source = threat_origin
	panic_timer = randf_range(6.0, 12.0)
	current_state = PedestrianState.PANIC_FLEE


func _on_panic_signal(threat_pos: Vector3) -> void:
	if global_position.distance_to(threat_pos) < 35.0:
		trigger_panic(threat_pos)


func damage(impact_point: Vector3, force: Vector3) -> void:
	trigger_panic(global_position - impact_point)
	EventBus.crime_committed.emit("assault", 1, global_position)
