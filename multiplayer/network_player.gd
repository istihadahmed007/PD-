# ==============================================================================
# NETWORK PLAYER CONTROLLER (SERVER-AUTHORITATIVE MULTIPLAYER)
# Project: Bangladesh Online Multiplayer Game (DTA: Dhaka Theft Auto)
# Architecture: Godot 4 Server-Authoritative CharacterBody3D
# Key Guarantees:
#   - Server simulates physics, validates inputs, and authors authoritative positions
#   - Clients send unreliable ordered input messages (WASD, sprint, jump, camera yaw)
#   - Remote clients smoothly interpolate position and rotation with zero jitter
#   - Camera and mouse ownership is strictly restricted to the local owning client
#   - 3D Billboard displays player nickname and host/peer identification
# ==============================================================================
class_name NetworkPlayer
extends CharacterBody3D

enum LocomotionState {
	IDLE = 0,
	WALK = 1,
	RUN = 2,
	SPRINT = 3,
	JUMP = 4,
	FALL = 5,
	LAND = 6
}

# Network Identity (Synchronized)
@export var player_peer_id: int = 1:
	set(val):
		player_peer_id = val
		_update_ownership()

@export var player_nickname: String = "Player":
	set(val):
		player_nickname = val
		_update_nickname_display()

# Synchronized State (Server -> All Clients)
@export var sync_position: Vector3 = Vector3.ZERO
@export var sync_rotation_y: float = 0.0
@export var sync_velocity: Vector3 = Vector3.ZERO
@export var sync_locomotion_state: int = 0

# Movement Attributes (Balanced for responsive urban navigation)
@export_category("Movement Speeds")
@export var walk_speed: float = 3.2
@export var run_speed: float = 6.8
@export var sprint_speed: float = 11.5
@export var acceleration: float = 18.0
@export var deceleration: float = 22.0
@export var rotation_speed: float = 14.0

@export_category("Jumping & Gravity")
@export var jump_impulse: float = 8.5
@export var gravity: float = 24.0
@export var max_fall_speed: float = 35.0

# Node References
@onready var character_skin: Node3D = $CharacterSkin
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var nickname_label: Label3D = $NicknameBillboard
@onready var synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var camera_rig: Node3D = $CameraRig
@onready var spring_arm: SpringArm3D = $CameraRig/SpringArm3D
@onready var player_camera: Camera3D = $CameraRig/SpringArm3D/PlayerCamera

# Local Client State
var is_local_player: bool = false
var _cam_yaw: float = 0.0
var _cam_pitch: float = -0.15
var _mouse_sensitivity: float = 0.0028
var _camera_follow_pos: Vector3 = Vector3.ZERO

# Server-Authoritative Input Buffer
var _input_dir: Vector2 = Vector2.ZERO
var _is_sprinting: bool = false
var _jump_requested: bool = false
var _input_cam_yaw: float = 0.0

# Audio / Step timing
var _step_timer: float = 0.0


func _ready() -> void:
	# Configure SceneReplicationConfig programmatically for absolute stability
	_setup_synchronizer_config()
	
	_update_ownership()
	_update_nickname_display()
	
	if sync_position != Vector3.ZERO:
		global_position = sync_position
	else:
		sync_position = global_position
	
	_camera_follow_pos = global_position


func _setup_synchronizer_config() -> void:
	if not synchronizer:
		return
	
	var config := SceneReplicationConfig.new()
	
	# Real-time movement synchronization (ALWAYS at replication rate)
	config.add_property(NodePath(".:sync_position"))
	config.property_set_replication_mode(NodePath(".:sync_position"), SceneReplicationConfig.REPLICATION_MODE_ALWAYS)
	config.property_set_spawn(NodePath(".:sync_position"), true)
	
	config.add_property(NodePath(".:sync_rotation_y"))
	config.property_set_replication_mode(NodePath(".:sync_rotation_y"), SceneReplicationConfig.REPLICATION_MODE_ALWAYS)
	config.property_set_spawn(NodePath(".:sync_rotation_y"), true)
	
	config.add_property(NodePath(".:sync_velocity"))
	config.property_set_replication_mode(NodePath(".:sync_velocity"), SceneReplicationConfig.REPLICATION_MODE_ALWAYS)
	config.property_set_spawn(NodePath(".:sync_velocity"), true)
	
	config.add_property(NodePath(".:sync_locomotion_state"))
	config.property_set_replication_mode(NodePath(".:sync_locomotion_state"), SceneReplicationConfig.REPLICATION_MODE_ALWAYS)
	config.property_set_spawn(NodePath(".:sync_locomotion_state"), true)
	
	# Identity replication (ON_CHANGE)
	config.add_property(NodePath(".:player_nickname"))
	config.property_set_replication_mode(NodePath(".:player_nickname"), SceneReplicationConfig.REPLICATION_MODE_ON_CHANGE)
	config.property_set_spawn(NodePath(".:player_nickname"), true)
	
	config.add_property(NodePath(".:player_peer_id"))
	config.property_set_replication_mode(NodePath(".:player_peer_id"), SceneReplicationConfig.REPLICATION_MODE_ON_CHANGE)
	config.property_set_spawn(NodePath(".:player_peer_id"), true)
	
	synchronizer.replication_config = config
	synchronizer.set_multiplayer_authority(1) # Server is absolute authority


func _update_ownership() -> void:
	if not is_inside_tree():
		return
	
	var unique_id := 0
	if multiplayer and multiplayer.has_multiplayer_peer():
		unique_id = multiplayer.get_unique_id()
	is_local_player = (player_peer_id == unique_id)
	
	if is_local_player:
		# Local client owns camera and mouse input
		if camera_rig:
			camera_rig.visible = true
			if player_camera:
				player_camera.current = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		# Remote players MUST NOT have active cameras or process mouse
		if camera_rig:
			camera_rig.visible = false
			if player_camera:
				player_camera.current = false
			camera_rig.queue_free()


func _update_nickname_display() -> void:
	if not nickname_label:
		return
	
	var badge := ""
	if player_peer_id == 1:
		badge = " [HOST]"
	elif is_local_player:
		badge = " [YOU]"
	
	nickname_label.text = "%s%s" % [player_nickname, badge]


# ==============================================================================
# INPUT HANDLING (LOCAL CLIENT ONLY)
# ==============================================================================
func _unhandled_input(event: InputEvent) -> void:
	if not is_local_player:
		return
	
	# Mouse look when mouse is captured
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_cam_yaw -= event.relative.x * _mouse_sensitivity
		_cam_pitch -= event.relative.y * _mouse_sensitivity
		_cam_pitch = clampf(_cam_pitch, -1.2, 0.45) # Clamped pitch bounds
	
	# Toggle mouse cursor with Escape
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# ==============================================================================
# PHYSICS PROCESS (SERVER-AUTHORITATIVE SIMULATION & CLIENT SAMPLING)
# ==============================================================================
func _physics_process(delta: float) -> void:
	# --------------------------------------------------------------------------
	# A) LOCAL CLIENT: Sample input and transmit to Server via Unreliable Ordered RPC
	# --------------------------------------------------------------------------
	if is_local_player:
		var raw_input := Vector2.ZERO
		# Read WASD or mapped input actions
		if InputMap.has_action("move_left"):
			raw_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		else:
			# Fallback to direct key polling if actions differ
			if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): raw_input.x -= 1.0
			if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): raw_input.x += 1.0
			if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): raw_input.y += 1.0
			if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): raw_input.y -= 1.0
		
		var sprint_down := Input.is_action_pressed("sprint") or Input.is_key_pressed(KEY_SHIFT)
		var jump_pressed := Input.is_action_just_pressed("jump") or Input.is_key_pressed(KEY_SPACE)
		
		# Send input to authoritative server if remote client, or feed directly if host
		if not multiplayer.is_server():
			c2s_send_input.rpc_id(1, raw_input, sprint_down, jump_pressed, _cam_yaw)
		else:
			_receive_input_internal(raw_input, sprint_down, jump_pressed, _cam_yaw)
	
	# --------------------------------------------------------------------------
	# B) SERVER: Run authoritative movement physics with move_and_slide()
	# --------------------------------------------------------------------------
	if multiplayer.is_server():
		_process_server_movement(delta)
		
		# Push authoritative state to synchronized properties
		sync_position = global_position
		if character_skin:
			sync_rotation_y = character_skin.rotation.y
		sync_velocity = velocity
		sync_locomotion_state = _determine_locomotion_state()


func _process_server_movement(delta: float) -> void:
	# Calculate camera-relative movement vector on server
	var forward := Vector3(-sin(_input_cam_yaw), 0, -cos(_input_cam_yaw))
	var right := Vector3(cos(_input_cam_yaw), 0, -sin(_input_cam_yaw))
	var desired_dir := (right * _input_dir.x + forward * _input_dir.y)
	if desired_dir.length_squared() > 1.0:
		desired_dir = desired_dir.normalized()
	
	# Determine target horizontal speed
	var target_speed := 0.0
	if desired_dir.length() > 0.05:
		if _is_sprinting:
			target_speed = sprint_speed
		elif desired_dir.length() > 0.6:
			target_speed = run_speed
		else:
			target_speed = walk_speed
	
	# Acceleration / Deceleration
	var target_horiz_vel := desired_dir * target_speed
	var accel_rate := acceleration if desired_dir.length() > 0.05 else deceleration
	velocity.x = move_toward(velocity.x, target_horiz_vel.x, accel_rate * delta)
	velocity.z = move_toward(velocity.z, target_horiz_vel.z, accel_rate * delta)
	
	# Gravity
	if not is_on_floor():
		velocity.y = maxf(velocity.y - gravity * delta, -max_fall_speed)
	else:
		if velocity.y < 0.0:
			velocity.y = 0.0
	
	# Jump execution
	if _jump_requested and is_on_floor():
		velocity.y = jump_impulse
		_jump_requested = false
	elif is_on_floor():
		_jump_requested = false
	
	# Authoritative Move and Slide
	move_and_slide()
	
	# Smooth visual rotation towards movement heading
	if character_skin and desired_dir.length() > 0.1:
		var target_heading := atan2(desired_dir.x, desired_dir.z)
		character_skin.rotation.y = lerp_angle(character_skin.rotation.y, target_heading, rotation_speed * delta)


func _determine_locomotion_state() -> int:
	if not is_on_floor():
		return LocomotionState.JUMP if velocity.y > 0.5 else LocomotionState.FALL
	
	var horiz_speed := Vector2(velocity.x, velocity.z).length()
	if horiz_speed > 8.0:
		return LocomotionState.SPRINT
	elif horiz_speed > 4.5:
		return LocomotionState.RUN
	elif horiz_speed > 0.35:
		return LocomotionState.WALK
	else:
		return LocomotionState.IDLE


# ==============================================================================
# VISUAL INTERPOLATION & ANIMATIONS (CLIENT-SIDE)
# ==============================================================================
func _process(delta: float) -> void:
	_update_nickname_display()
	
	# Non-server clients interpolate positions from synchronized server state
	if not multiplayer.is_server():
		if is_local_player:
			# Local client smooth reconciliation towards authoritative server position
			var dist := global_position.distance_to(sync_position)
			if dist > 3.0:
				global_position = sync_position # Hard snap if severe desync
			else:
				global_position = global_position.lerp(sync_position, clampf(16.0 * delta, 0.0, 1.0))
		else:
			# Remote clients: Smooth interpolation eliminates packet jitter
			global_position = global_position.lerp(sync_position, clampf(18.0 * delta, 0.0, 1.0))
			if character_skin:
				character_skin.rotation.y = lerp_angle(character_skin.rotation.y, sync_rotation_y, clampf(18.0 * delta, 0.0, 1.0))
	
	# Animate character skin matching state
	_update_character_animation()
	
	# Update local third-person camera rig position & orientation
	if is_local_player and camera_rig:
		_update_local_camera(delta)


func _update_character_animation() -> void:
	if not character_skin:
		return
	
	var state_to_play: int = sync_locomotion_state if not multiplayer.is_server() else _determine_locomotion_state()
	
	match state_to_play:
		LocomotionState.IDLE:
			if character_skin.has_method("idle"): character_skin.idle()
		LocomotionState.WALK:
			if character_skin.has_method("walk"): character_skin.walk()
		LocomotionState.RUN:
			if character_skin.has_method("run"): character_skin.run()
		LocomotionState.SPRINT:
			if character_skin.has_method("sprint"): character_skin.sprint()
		LocomotionState.JUMP:
			if character_skin.has_method("jump"): character_skin.jump()
		LocomotionState.FALL:
			if character_skin.has_method("fall"): character_skin.fall()
		LocomotionState.LAND:
			if character_skin.has_method("land"): character_skin.land(false)


func _update_local_camera(delta: float) -> void:
	# Smooth follow target position at player head/chest height
	var target_pos := global_position + Vector3(0, 1.5, 0)
	_camera_follow_pos = _camera_follow_pos.lerp(target_pos, clampf(24.0 * delta, 0.0, 1.0))
	camera_rig.global_position = _camera_follow_pos
	camera_rig.rotation.y = _cam_yaw
	
	if spring_arm:
		spring_arm.rotation.x = _cam_pitch


# ==============================================================================
# RPC INPUT MESSAGING (UNRELIABLE ORDERED)
# ==============================================================================
@rpc("any_peer", "call_remote", "unreliable_ordered")
func c2s_send_input(input_vec: Vector2, sprint: bool, jump: bool, cam_yaw: float) -> void:
	if not multiplayer.is_server():
		return
	
	var sender_id := multiplayer.get_remote_sender_id()
	# Strict security check: reject spoofed input from non-owning peers!
	if sender_id != player_peer_id:
		return
	
	_receive_input_internal(input_vec, sprint, jump, cam_yaw)


func _receive_input_internal(input_vec: Vector2, sprint: bool, jump: bool, cam_yaw: float) -> void:
	# Sanitize and clamp input vector magnitude <= 1.0
	_input_dir = input_vec.limit_length(1.0)
	_is_sprinting = sprint
	if jump:
		_jump_requested = true
	_input_cam_yaw = cam_yaw
