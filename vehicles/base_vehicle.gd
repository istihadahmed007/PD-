# ==============================================================================
# BASE VEHICLE (VEHICLE SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Master controller for drivable vehicles (Rickshaws, CNGs, Cars, Buses).
# ==============================================================================
class_name BaseVehicle
extends CharacterBody3D

signal driver_mounted(driver: Node)
signal driver_dismounted()

@export_category("Vehicle Attributes")
@export var vehicle_name: String = "Cycle Rickshaw"
@export var max_speed_kmh: float = 28.0
@export var acceleration_rate: float = 8.0
@export var braking_rate: float = 14.0
@export var reverse_max_speed_kmh: float = 10.0
@export var steering_speed: float = 3.2
@export var max_steer_angle_rad: float = deg_to_rad(38.0)
@export var drift_friction: float = 5.0
@export var gravity: float = 16.0

@export_category("Health & Condition")
@export var max_health: float = 100.0
var current_health: float = 100.0

var is_driven: bool = false
var driver_ref: Node = null

var current_steer_angle: float = 0.0
var forward_speed: float = 0.0 # in meters per second

@onready var exit_point: Marker3D = $ExitPoint if has_node("ExitPoint") else null
@onready var camera_mount: Marker3D = $CameraMount if has_node("CameraMount") else null
@onready var interactable_area: Interactable = $InteractableArea if has_node("InteractableArea") else null
@onready var horn_audio: AudioStreamPlayer3D = $HornAudio if has_node("HornAudio") else null
@onready var engine_audio: AudioStreamPlayer3D = $EngineAudio if has_node("EngineAudio") else null


func _ready() -> void:
	current_health = max_health
	collision_layer = 1 << 2 # Layer 3: Vehicles
	collision_mask = 1 | (1 << 1) | (1 << 2) | (1 << 4) # Static, Player, Vehicles, Props
	
	if interactable_area:
		interactable_area.prompt_text = "Ride " + vehicle_name
		interactable_area.interacted.connect(_on_interaction_requested)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = -0.1
	
	if is_driven:
		_process_driving_inputs(delta)
	else:
		_process_idle_friction(delta)
	
	# Apply forward motion in local vehicle orientation
	var forward_dir := -transform.basis.z
	var horizontal_vel := forward_dir * forward_speed
	velocity.x = horizontal_vel.x
	velocity.z = horizontal_vel.z
	
	move_and_slide()
	
	var current_kmh := abs(forward_speed) * 3.6
	if is_driven:
		EventBus.vehicle_speed_changed.emit(current_kmh)
	
	if engine_audio and engine_audio.playing:
		engine_audio.pitch_scale = clampf(0.8 + (current_kmh / max_speed_kmh) * 0.8, 0.8, 1.8)


func _process_driving_inputs(delta: float) -> void:
	var throttle_input := Input.get_axis("move_down", "move_up") # W / S
	var steer_input := Input.get_axis("move_right", "move_left") # A / D (positive is left)
	var is_handbraking := Input.is_action_pressed("jump")
	
	# Handle Vehicle Exit (Press Interact)
	if Input.is_action_just_pressed("interact"):
		GameManager.exit_vehicle()
		return
	
	# Handle Horn (Press H or horn action)
	if Input.is_action_just_pressed("vehicle_horn") or Input.is_key_pressed(KEY_H):
		honk_horn()
	
	# Steering calculation
	var target_steer := steer_input * max_steer_angle_rad
	current_steer_angle = lerp(current_steer_angle, target_steer, steering_speed * delta)
	
	# Rotate vehicle basis around Y axis based on forward speed and steering angle
	if abs(forward_speed) > 0.1:
		var turn_direction := 1.0 if forward_speed > 0 else -1.0
		rotate_y(current_steer_angle * turn_direction * delta * (abs(forward_speed) / 4.0))
	
	# Speed conversion: km/h to m/s
	var max_forward_ms := max_speed_kmh / 3.6
	var max_reverse_ms := reverse_max_speed_kmh / 3.6
	
	if is_handbraking:
		forward_speed = move_toward(forward_speed, 0.0, braking_rate * 1.5 * delta)
	elif throttle_input > 0.0:
		forward_speed = move_toward(forward_speed, max_forward_ms, acceleration_rate * delta * throttle_input)
	elif throttle_input < 0.0:
		if forward_speed > 0.5:
			# Braking while going forward
			forward_speed = move_toward(forward_speed, 0.0, braking_rate * delta)
		else:
			# Reversing
			forward_speed = move_toward(forward_speed, -max_reverse_ms, acceleration_rate * 0.6 * delta)
	else:
		# Rolling resistance / natural friction
		forward_speed = move_toward(forward_speed, 0.0, drift_friction * delta)


func _process_idle_friction(delta: float) -> void:
	forward_speed = move_toward(forward_speed, 0.0, drift_friction * 2.0 * delta)


func mount_driver(driver: Node) -> void:
	is_driven = true
	driver_ref = driver
	if interactable_area:
		interactable_area.is_active = false
	if engine_audio and not engine_audio.playing:
		engine_audio.play()
	driver_mounted.emit(driver)


func dismount_driver() -> void:
	is_driven = false
	driver_ref = null
	if interactable_area:
		interactable_area.is_active = true
	if engine_audio and engine_audio.playing:
		engine_audio.stop()
	driver_dismounted.emit()


func honk_horn() -> void:
	if horn_audio:
		horn_audio.pitch_scale = randfn(1.0, 0.05)
		horn_audio.play()
	EventBus.vehicle_horn_honked.emit(self)


func damage(impact_point: Vector3, force: Vector3) -> void:
	var damage_amount := force.length() * 2.0
	current_health = maxf(0.0, current_health - damage_amount)
	EventBus.vehicle_health_changed.emit(current_health, max_health)
	
	# Apply physical recoil bounce
	velocity += force * 0.2


func _on_interaction_requested(user: Node) -> void:
	if not is_driven:
		GameManager.enter_vehicle(self, "driver")
