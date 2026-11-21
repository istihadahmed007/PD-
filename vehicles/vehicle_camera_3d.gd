# ==============================================================================
# VEHICLE FOLLOW CAMERA (VEHICLE SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Dynamic multi-view vehicle camera featuring smooth chase follow,
#          speed lag, look-behind, collision avoidance, and dynamic speed FOV.
# ==============================================================================
class_name VehicleCamera3D
extends Node3D

enum CameraViewMode {
	CHASE_FAR,
	CHASE_CLOSE,
	HOOD_FIRST_PERSON
}

@export var target_vehicle: VehicleBody3D = null
@export var is_active: bool = false:
	set(val):
		is_active = val
		if camera:
			camera.current = val

var current_mode: CameraViewMode = CameraViewMode.CHASE_FAR

# Preset settings per view mode
var view_params := {
	CameraViewMode.CHASE_FAR: {"dist": 6.2, "height": 2.2, "base_fov": 74.0, "lag_speed": 10.0},
	CameraViewMode.CHASE_CLOSE: {"dist": 4.6, "height": 1.7, "base_fov": 75.0, "lag_speed": 14.0},
	CameraViewMode.HOOD_FIRST_PERSON: {"dist": 0.2, "height": 1.35, "base_fov": 85.0, "lag_speed": 35.0}
}

var current_yaw: float = 0.0
var current_pos: Vector3 = Vector3.ZERO
var look_behind: bool = false

@onready var camera: Camera3D = $Camera3D if has_node("Camera3D") else null
@onready var spring_arm: SpringArm3D = $SpringArm3D if has_node("SpringArm3D") else null


func _ready() -> void:
	top_level = true
	if not camera and not spring_arm:
		_setup_default_nodes()
	
	if target_vehicle:
		current_pos = target_vehicle.global_position
		current_yaw = target_vehicle.global_rotation.y


func _setup_default_nodes() -> void:
	spring_arm = SpringArm3D.new()
	spring_arm.name = "SpringArm3D"
	spring_arm.spring_length = 6.2
	spring_arm.margin = 0.25
	
	# Sphere shape for smooth camera collision against walls
	var sphere = SphereShape3D.new()
	sphere.radius = 0.2
	spring_arm.shape = sphere
	add_child(spring_arm)
	
	camera = Camera3D.new()
	camera.name = "Camera3D"
	spring_arm.add_child(camera)
	camera.position = Vector3.ZERO
	camera.current = is_active


func cycle_camera_view() -> void:
	var next_idx = (int(current_mode) + 1) % CameraViewMode.size()
	current_mode = next_idx as CameraViewMode


func _physics_process(delta: float) -> void:
	if not is_active or not target_vehicle:
		return
	
	_handle_input()
	_update_transform(delta)


func _handle_input() -> void:
	if Input.is_action_just_pressed("vehicle_camera_view"):
		cycle_camera_view()
	
	look_behind = Input.is_action_pressed("vehicle_look_behind")


func _update_transform(delta: float) -> void:
	var params: Dictionary = view_params[current_mode]
	var vehicle_transform := target_vehicle.global_transform
	var vehicle_pos := vehicle_transform.origin
	var vehicle_vel := target_vehicle.linear_velocity
	var forward_dir := -vehicle_transform.basis.z
	var speed_kmh := vehicle_vel.length() * 3.6
	
	# Determine target yaw orientation
	var target_yaw := target_vehicle.global_rotation.y
	
	# If moving backwards significantly or holding look_behind, face backwards
	var moving_backward := forward_dir.dot(vehicle_vel.normalized()) < -0.3 and speed_kmh > 4.0
	if look_behind or moving_backward:
		target_yaw += PI
	
	# Smoothly interpolate yaw to prevent abrupt jarring
	current_yaw = lerp_angle(current_yaw, target_yaw, params["lag_speed"] * delta)
	
	if current_mode == CameraViewMode.HOOD_FIRST_PERSON:
		# Hood mode: snap rigidly to vehicle front
		var hood_offset = vehicle_transform.basis * Vector3(0.0, params["height"], -params["dist"])
		global_position = vehicle_pos + hood_offset
		global_rotation = vehicle_transform.basis.get_euler()
		if camera:
			camera.position = Vector3.ZERO
			camera.rotation = Vector3.ZERO
			camera.fov = params["base_fov"] + clampf(speed_kmh * 0.08, 0.0, 10.0)
	else:
		# Chase mode: SpringArm with height and distance
		var target_camera_pivot := vehicle_pos + Vector3(0.0, params["height"], 0.0)
		global_position = global_position.lerp(target_camera_pivot, 20.0 * delta)
		rotation.y = current_yaw
		rotation.x = -deg_to_rad(10.0) # Look slightly downward
		
		# Dynamic spring length and FOV based on speed
		var speed_factor = clampf(speed_kmh / 140.0, 0.0, 1.0)
		if spring_arm:
			spring_arm.spring_length = params["dist"] + (speed_factor * 1.5)
		if camera:
			camera.fov = params["base_fov"] + (speed_factor * 12.0)
