# ==============================================================================
# ADVANCED THIRD-PERSON CAMERA CONTROLLER (CAMERA SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Independent smooth follow camera with collision avoidance, dual-pivot
#          shoulder aiming transition, dynamic FOV, and obstruction handling.
# ==============================================================================
class_name CameraController
extends Node3D

enum CAMERA_PIVOT { OVER_SHOULDER, THIRD_PERSON }

@export_category("Orbit & Sensitivity")
@export var mouse_sensitivity: float = 0.0025
@export var joystick_sensitivity: float = 2.4
@export var invert_mouse_y: bool = false
@export var tilt_upper_limit: float = 0.52   # Looking down limit (radians)
@export var tilt_lower_limit: float = -0.85  # Looking up limit (radians)

@export_category("Follow Smoothing")
@export var position_follow_speed: float = 18.0
@export var ground_height_lerp_speed: float = 10.0
@export var rotation_smoothing: float = 26.0

@export_category("Distance & FOV")
@export var explore_fov: float = 72.0
@export var sprint_fov: float = 82.0
@export var aim_fov: float = 48.0
@export var transition_speed: float = 7.5

# Node References
@onready var camera: Camera3D = $PlayerCamera
@onready var _over_shoulder_pivot: Node3D = $CameraOverShoulderPivot
@onready var _camera_spring_arm: SpringArm3D = $CameraSpringArm
@onready var _third_person_pivot: Node3D = $CameraSpringArm/CameraThirdPersonPivot
@onready var _camera_raycast: RayCast3D = $PlayerCamera/CameraRayCast

var _anchor: CharacterBody3D = null
var _euler_rotation: Vector3 = Vector3.ZERO
var _current_pivot_type: CAMERA_PIVOT = CAMERA_PIVOT.THIRD_PERSON

var _aim_blend: float = 0.0
var _current_ground_y: float = 0.0

var _aim_target: Vector3 = Vector3.ZERO
var _aim_collider: Node = null

var _rotation_input: float = 0.0
var _tilt_input: float = 0.0


func _ready() -> void:
	top_level = true
	if _camera_spring_arm:
		# Use SphereShape3D for reliable collision clearance
		var sphere = SphereShape3D.new()
		sphere.radius = 0.22
		_camera_spring_arm.shape = sphere
		_camera_spring_arm.margin = 0.15


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_rotation_input -= event.relative.x * mouse_sensitivity
		_tilt_input -= event.relative.y * mouse_sensitivity


func _process(delta: float) -> void:
	if not _anchor:
		return
	
	_handle_joystick_input(delta)
	_update_rotation(delta)
	_update_follow_position(delta)
	_update_aim_raycast()
	_update_camera_transition(delta)


func _handle_joystick_input(delta: float) -> void:
	var joy_look_x = Input.get_action_raw_strength("camera_left") - Input.get_action_raw_strength("camera_right")
	var joy_look_y = Input.get_action_raw_strength("camera_up") - Input.get_action_raw_strength("camera_down")
	
	_rotation_input += joy_look_x * joystick_sensitivity * delta
	_tilt_input += joy_look_y * joystick_sensitivity * delta


func _update_rotation(delta: float) -> void:
	if invert_mouse_y:
		_tilt_input = -_tilt_input
	
	_euler_rotation.x += _tilt_input
	_euler_rotation.x = clamp(_euler_rotation.x, tilt_lower_limit, tilt_upper_limit)
	_euler_rotation.y += _rotation_input
	
	_rotation_input = 0.0
	_tilt_input = 0.0
	
	var target_basis = Basis.from_euler(_euler_rotation)
	transform.basis = transform.basis.slerp(target_basis, rotation_smoothing * delta)


func _update_follow_position(delta: float) -> void:
	# Smooth ground elevation tracking prevents camera stutter on steps and curbs
	var anchor_ground = _anchor.get("_ground_height")
	if anchor_ground == null:
		anchor_ground = _anchor.global_position.y
	_current_ground_y = lerp(_current_ground_y, float(anchor_ground), ground_height_lerp_speed * delta)
	
	var target_pos = _anchor.global_position
	target_pos.y = _current_ground_y
	global_position = global_position.lerp(target_pos, position_follow_speed * delta)


func _update_camera_transition(delta: float) -> void:
	var target_blend := 1.0 if _current_pivot_type == CAMERA_PIVOT.OVER_SHOULDER else 0.0
	_aim_blend = move_toward(_aim_blend, target_blend, transition_speed * delta)
	
	# Align over-shoulder pivot to aim target
	if _aim_target != Vector3.ZERO:
		_over_shoulder_pivot.look_at(_aim_target)
	
	# Smoothly blend between third-person orbit and over-shoulder pivot transforms
	var target_transform = _third_person_pivot.global_transform.interpolate_with(
		_over_shoulder_pivot.global_transform,
		_aim_blend
	)
	
	camera.global_transform = camera.global_transform.interpolate_with(target_transform, 24.0 * delta)
	camera.rotation.z = 0.0
	
	# Dynamic FOV interpolation (Sprint widening / Aim zoom-in)
	var desired_base_fov = sprint_fov if (_anchor.get("is_sprinting") == true) else explore_fov
	var target_fov = lerpf(desired_base_fov, aim_fov, _aim_blend)
	camera.fov = lerpf(camera.fov, target_fov, 8.0 * delta)


func _update_aim_raycast() -> void:
	if not _camera_raycast:
		return
	
	if _camera_raycast.is_colliding():
		_aim_target = _camera_raycast.get_collision_point()
		_aim_collider = _camera_raycast.get_collider()
	else:
		_aim_target = _camera_raycast.global_transform * _camera_raycast.target_position
		_aim_collider = null


func setup(anchor: CharacterBody3D) -> void:
	_anchor = anchor
	global_position = _anchor.global_position
	_current_ground_y = _anchor.global_position.y
	_euler_rotation = rotation
	
	if _camera_spring_arm:
		_camera_spring_arm.add_excluded_object(_anchor.get_rid())
	if _camera_raycast:
		_camera_raycast.add_exception_rid(_anchor.get_rid())
	
	set_pivot(CAMERA_PIVOT.THIRD_PERSON)
	camera.global_transform = _third_person_pivot.global_transform


func set_pivot(pivot_type: CAMERA_PIVOT) -> void:
	_current_pivot_type = pivot_type


func get_aim_target() -> Vector3:
	return _aim_target


func get_aim_collider() -> Node:
	if is_instance_valid(_aim_collider):
		return _aim_collider
	return null
