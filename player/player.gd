# ==============================================================================
# THIRD-PERSON PLAYER CONTROLLER (PLAYER SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Master CharacterBody3D controller providing natural human locomotion,
#          walking/jogging/sprinting, stair stepping, slope handling, jump/landing
#          recovery, camera-relative movement, stamina, and combat.
# ==============================================================================
class_name Player
extends CharacterBody3D

signal weapon_switched(weapon_name: String)

const BULLET_SCENE := preload("bullet.tscn")
const COIN_SCENE := preload("coin/coin.tscn")

enum LocomotionState {
	IDLE,
	WALK,
	JOG,
	SPRINT,
	JUMP,
	FALL,
	LAND,
	HARD_LAND,
	INTERACT
}

enum WEAPON_TYPE {
	DEFAULT,
	GRENADE,
}

@export_category("Locomotion Speeds")
## Natural street walking speed (m/s)
@export var walk_speed: float = 3.2
## Standard exploring/jogging speed (m/s)
@export var jog_speed: float = 7.0
## High-intensity sprint speed (m/s)
@export var sprint_speed: float = 12.5
## Acceleration rate towards target velocity
@export var acceleration: float = 9.0
## Deceleration rate when releasing input
@export var deceleration: float = 11.0
## Character model rotation speed towards heading
@export var rotation_speed: float = 14.0
## Minimum speed threshold before stopping completely
@export var stopping_speed: float = 0.8

@export_category("Stairs & Slopes")
## Maximum vertical step riser height character can step up smoothly (meters)
@export var max_step_height: float = 0.35

@export_category("Jumping & Gravity")
## Initial upward impulse upon leaving ground
@export var jump_initial_impulse: float = 11.5
## Additional upward thrust while holding jump button
@export var jump_additional_force: float = 4.0
## Downward gravity acceleration
@export var gravity: float = 24.0
## Maximum vertical descent speed
@export var max_fall_speed: float = 40.0
## Fall velocity threshold that triggers a hard landing impact recovery
@export var hard_landing_velocity: float = -14.0

@export_category("Attributes & Vitals")
@export var max_health: float = 100.0
@export var max_stamina: float = 100.0
@export var stamina_drain_rate: float = 22.0
@export var stamina_recovery_rate: float = 16.0

@export_category("Combat & Attack")
@export var bullet_speed: float = 14.0
@export var attack_impulse: float = 10.0
@export var max_throwback_force: float = 15.0
@export var shoot_cooldown: float = 0.45
@export var grenade_cooldown: float = 0.5

# Public Runtime Attributes
var current_health: float = 100.0
var current_stamina: float = 100.0
var is_sprinting: bool = false
var is_hard_landing_recovering: bool = false

# Internal State Tracking
var _locomotion_state: LocomotionState = LocomotionState.IDLE
var _equipped_weapon: WEAPON_TYPE = WEAPON_TYPE.DEFAULT
var _move_direction := Vector3.ZERO
var _last_strong_direction := Vector3.FORWARD
var _ground_height: float = 0.0
var _coins: int = 0
var _footstep_distance: float = 0.0
const FOOTSTEP_STRIDE: float = 1.85

# Timers & Jump Buffering
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _time_in_air: float = 0.0
var _landing_recovery_timer: float = 0.0
var _previous_vertical_velocity: float = 0.0
var _is_on_floor_buffer: bool = false

var _shoot_cooldown_tick: float = 0.0
var _grenade_cooldown_tick: float = 0.0

# Node References
@onready var _camera_controller: CameraController = $CameraController
@onready var _ground_shapecast: ShapeCast3D = $GroundShapeCast
@onready var _grenade_aim_controller: GrenadeLauncher = $GrenadeLauncher
@onready var _character_skin: Node3D = $CharacterSkin
@onready var _character_melee_area: Area3D = $CharacterSkin/MeleeAttackArea if has_node("CharacterSkin/MeleeAttackArea") else null
@onready var _ui_aim_reticle: ColorRect = %AimReticle if has_node("%AimReticle") else null
@onready var _ui_coins_container: HBoxContainer = %CoinsContainer if has_node("%CoinsContainer") else null
@onready var _weapons_ui: PanelContainer = %WeaponsUI if has_node("%WeaponsUI") else null
@onready var _step_sound: AudioStreamPlayer3D = $StepSound if has_node("StepSound") else null
@onready var _landing_sound: AudioStreamPlayer3D = $LandingSound if has_node("LandingSound") else null
@onready var _start_position := global_transform.origin


func _ready() -> void:
	current_health = max_health
	current_stamina = max_stamina
	
	# Configure floor snapping and slope climbing parameters
	floor_stop_on_slope = true
	floor_constant_speed = true
	floor_max_angle = deg_to_rad(48.0)
	floor_snap_length = 0.4
	
	if _character_skin and _character_skin.has_signal("stepped"):
		_character_skin.stepped.connect(play_foot_step_sound)
	if _weapons_ui:
		weapon_switched.connect(_weapons_ui.switch_to)
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if _camera_controller:
		_camera_controller.setup(self)
	if _grenade_aim_controller:
		_grenade_aim_controller.visible = false
	
	weapon_switched.emit(WEAPON_TYPE.keys()[0])
	
	# Register with global open-world singletons
	if Engine.has_singleton("GameManager") or get_node_or_null("/root/GameManager"):
		GameManager.register_player(self)
	if Engine.has_singleton("EventBus") or get_node_or_null("/root/EventBus"):
		EventBus.player_health_changed.emit(current_health, max_health)
		EventBus.player_stamina_changed.emit(current_stamina, max_stamina)
	
	if not InputMap.has_action("move_left"):
		_register_input_actions()
	
	# Attach CrimeDetector
	var crime_detector = CrimeDetector.new()
	crime_detector.name = "CrimeDetector"
	crime_detector.add_to_group("crime_detector")
	add_child(crime_detector)


func _physics_process(delta: float) -> void:
	_update_ground_elevation()
	_update_timers(delta)
	_handle_weapon_swapping()
	
	var is_aiming := Input.is_action_pressed("aim") and is_on_floor()
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	_move_direction = _get_camera_oriented_input(raw_input)
	
	# Rotate towards heading or aim crosshair
	if _move_direction.length() > 0.15:
		_last_strong_direction = _move_direction.normalized()
	if is_aiming and _camera_controller:
		_last_strong_direction = (_camera_controller.global_transform.basis * Vector3.MODEL_FRONT).normalized()
	
	_orient_character_to_direction(_last_strong_direction, delta)
	
	# Process Stamina & Speed selection
	var active_target_speed := _calculate_target_speed(raw_input, is_aiming, delta)
	
	# Apply Horizontal Velocity Lerping
	_apply_horizontal_movement(active_target_speed, delta)
	
	# Handle Stair Climbing (Step-Up)
	_handle_stair_step_up(delta)
	
	# Handle Jump Buffering, Coyote Time, and Gravity
	_handle_vertical_physics(delta)
	
	# Aiming Camera & Trajectory Reticle
	_update_aim_camera_state(is_aiming)
	
	# Combat Execution (Shoot / Melee / Grenade)
	_handle_combat_actions(is_aiming, delta)
	
	# Detect Landings & Impact Recovery
	var just_hit_floor := is_on_floor() and not _is_on_floor_buffer
	if just_hit_floor:
		_on_landed()
	_is_on_floor_buffer = is_on_floor()
	_previous_vertical_velocity = velocity.y
	
	# Sync animations with character skin
	_update_animation_state(is_aiming)
	
	# Move character with floor snap
	move_and_slide()
	_resolve_anti_stuck()
	
	# Footstep audio triggering
	if is_on_floor():
		var h_speed = Vector2(velocity.x, velocity.z).length()
		if h_speed > 0.4:
			_footstep_distance += h_speed * delta
			var stride = FOOTSTEP_STRIDE * (0.75 if is_sprinting else 1.0)
			if _footstep_distance >= stride:
				_footstep_distance = 0.0
				var is_wet = false
				var ws = get_tree().root.find_child("WeatherSystem", true, false)
				if ws and ws.get("wetness_intensity") != null:
					is_wet = ws.wetness_intensity > 0.35
				AudioManager.play_footstep(is_wet)
		else:
			_footstep_distance = 0.0


func _update_ground_elevation() -> void:
	if _ground_shapecast and _ground_shapecast.get_collision_count() > 0:
		for result in _ground_shapecast.collision_result:
			_ground_height = max(_ground_height, result.point.y)
	elif _ground_shapecast:
		_ground_height = global_position.y + _ground_shapecast.target_position.y
	if global_position.y < _ground_height:
		_ground_height = global_position.y


func _update_timers(delta: float) -> void:
	if is_on_floor():
		_coyote_timer = 0.12
		_time_in_air = 0.0
	else:
		_coyote_timer = maxf(0.0, _coyote_timer - delta)
		_time_in_air += delta
	
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = 0.15
	else:
		_jump_buffer_timer = maxf(0.0, _jump_buffer_timer - delta)
	
	if _landing_recovery_timer > 0.0:
		_landing_recovery_timer -= delta
		if _landing_recovery_timer <= 0.0:
			is_hard_landing_recovering = false


func _calculate_target_speed(raw_input: Vector2, is_aiming: bool, delta: float) -> float:
	if is_hard_landing_recovering:
		return walk_speed * 0.4
	
	var wants_sprint := Input.is_action_pressed("sprint") or Input.is_key_pressed(KEY_SHIFT)
	var has_input := raw_input.length() > 0.1
	
	if wants_sprint and has_input and is_on_floor() and not is_aiming and current_stamina > 5.0:
		is_sprinting = true
		current_stamina = maxf(0.0, current_stamina - stamina_drain_rate * delta)
	else:
		is_sprinting = false
		if is_on_floor():
			current_stamina = minf(max_stamina, current_stamina + stamina_recovery_rate * delta)
	
	if Engine.has_singleton("EventBus") or get_node_or_null("/root/EventBus"):
		EventBus.player_stamina_changed.emit(current_stamina, max_stamina)
	
	if not has_input:
		return 0.0
	elif is_aiming:
		return walk_speed * 0.85
	elif is_sprinting:
		return sprint_speed
	elif raw_input.length() < 0.6:
		return walk_speed
	else:
		return jog_speed


func _apply_horizontal_movement(target_speed: float, delta: float) -> void:
	var target_horizontal_velocity := _move_direction * target_speed
	var current_horizontal := Vector3(velocity.x, 0.0, velocity.z)
	
	var rate := acceleration if _move_direction.length() > 0.1 else deceleration
	current_horizontal = current_horizontal.lerp(target_horizontal_velocity, rate * delta)
	
	if _move_direction.length() == 0 and current_horizontal.length() < stopping_speed:
		current_horizontal = Vector3.ZERO
	
	velocity.x = current_horizontal.x
	velocity.z = current_horizontal.z


func _handle_stair_step_up(delta: float) -> void:
	if not is_on_floor() or _move_direction.length() < 0.1:
		return
	
	var horizontal_motion := Vector3(velocity.x, 0.0, velocity.z) * delta
	if horizontal_motion.length() < 0.001:
		return
	
	# Test if horizontal motion encounters a step riser
	var collision := KinematicCollision3D.new()
	if test_move(global_transform, horizontal_motion, collision):
		# Clearance test: probe upwards by max_step_height
		var step_up_transform := global_transform.translated(Vector3(0, max_step_height, 0))
		if not test_move(step_up_transform, horizontal_motion):
			# Downward probe to land cleanly on the stair tread
			var down_collision := KinematicCollision3D.new()
			if test_move(step_up_transform.translated(horizontal_motion), Vector3(0, -max_step_height, 0), down_collision):
				var step_lift := max_step_height + down_collision.get_travel().y
				if step_lift > 0.02 and step_lift <= max_step_height:
					global_position.y += step_lift
					apply_floor_snap()


func _handle_vertical_physics(delta: float) -> void:
	var can_jump := (is_on_floor() or _coyote_timer > 0.0) and not is_hard_landing_recovering
	var wants_jump := _jump_buffer_timer > 0.0
	
	if wants_jump and can_jump:
		velocity.y = jump_initial_impulse
		_coyote_timer = 0.0
		_jump_buffer_timer = 0.0
		AudioManager.play_jump()
		if _character_skin and _character_skin.has_method("jump"):
			_character_skin.jump()
	elif Input.is_action_pressed("jump") and not is_on_floor() and velocity.y > 0.0:
		# Additional jump height when holding button
		velocity.y += jump_additional_force * delta
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
		velocity.y = clampf(velocity.y, -max_fall_speed, 100.0)


func _on_landed() -> void:
	AudioManager.play_land()
	if _landing_sound:
		_landing_sound.pitch_scale = randfn(1.0, 0.08)
		_landing_sound.play()
	
	# Check for hard landing impact
	if _previous_vertical_velocity < hard_landing_velocity or _time_in_air > 0.85:
		is_hard_landing_recovering = true
		_landing_recovery_timer = 0.45
		if _character_skin and _character_skin.has_method("land"):
			_character_skin.land(true)
	else:
		if _character_skin and _character_skin.has_method("land"):
			_character_skin.land(false)


func _update_animation_state(is_aiming: bool) -> void:
	if not _character_skin:
		return
	
	if is_hard_landing_recovering:
		return
	
	if not is_on_floor():
		if velocity.y < -1.5:
			if _character_skin.has_method("fall"):
				_character_skin.fall()
		return
	
	var horizontal_speed := Vector3(velocity.x, 0.0, velocity.z).length()
	if horizontal_speed < stopping_speed:
		if _character_skin.has_method("idle"):
			_character_skin.idle()
	elif is_sprinting:
		if _character_skin.has_method("sprint"):
			_character_skin.sprint()
	elif horizontal_speed > walk_speed + 1.2:
		if _character_skin.has_method("run"):
			_character_skin.run()
	else:
		if _character_skin.has_method("walk"):
			_character_skin.walk()


func _get_camera_oriented_input(raw_input: Vector2) -> Vector3:
	if _character_melee_area and _character_melee_area.is_active():
		return Vector3.ZERO
	if is_hard_landing_recovering:
		return Vector3.ZERO
	
	var input := Vector3.ZERO
	input.x = -raw_input.x * sqrt(1.0 - raw_input.y * raw_input.y / 2.0)
	input.z = -raw_input.y * sqrt(1.0 - raw_input.x * raw_input.x / 2.0)
	
	if _camera_controller:
		input = _camera_controller.global_transform.basis * input
	input.y = 0.0
	return input


func _orient_character_to_direction(direction: Vector3, delta: float) -> void:
	if direction.length_squared() < 0.01:
		return
	
	var left_axis := Vector3.UP.cross(direction).normalized()
	var rotation_basis := Basis(left_axis, Vector3.UP, direction).get_rotation_quaternion()
	var current_quat := _character_skin.transform.basis.get_rotation_quaternion()
	
	# Compute turn angle delta for procedural lean
	var angle_diff := current_quat.angle_to(rotation_basis)
	if _character_skin.has_method("set_turn_lean"):
		_character_skin.set_turn_lean(angle_diff if left_axis.y > 0 else -angle_diff)
	
	var model_scale := _character_skin.transform.basis.get_scale()
	_character_skin.transform.basis = Basis(
		current_quat.slerp(rotation_basis, delta * rotation_speed)
	).scaled(model_scale)


func _update_aim_camera_state(is_aiming: bool) -> void:
	if not _camera_controller:
		return
	
	if is_aiming:
		_camera_controller.set_pivot(CameraController.CAMERA_PIVOT.OVER_SHOULDER)
		if _grenade_aim_controller:
			_grenade_aim_controller.throw_direction = _camera_controller.camera.quaternion * Vector3.FORWARD
			_grenade_aim_controller.from_look_position = _camera_controller.camera.global_position
		if _ui_aim_reticle:
			_ui_aim_reticle.visible = true
	else:
		_camera_controller.set_pivot(CameraController.CAMERA_PIVOT.THIRD_PERSON)
		if _grenade_aim_controller:
			_grenade_aim_controller.throw_direction = _last_strong_direction
			_grenade_aim_controller.from_look_position = global_position
		if _ui_aim_reticle:
			_ui_aim_reticle.visible = false


func _handle_weapon_swapping() -> void:
	if Input.is_action_just_pressed("swap_weapons"):
		_equipped_weapon = WEAPON_TYPE.DEFAULT if _equipped_weapon == WEAPON_TYPE.GRENADE else WEAPON_TYPE.GRENADE
		if _grenade_aim_controller:
			_grenade_aim_controller.visible = _equipped_weapon == WEAPON_TYPE.GRENADE
		weapon_switched.emit(WEAPON_TYPE.keys()[_equipped_weapon])


func _handle_combat_actions(is_aiming: bool, delta: float) -> void:
	_shoot_cooldown_tick += delta
	_grenade_cooldown_tick += delta
	
	var is_attacking := Input.is_action_pressed("attack")
	var is_just_attacking := Input.is_action_just_pressed("attack")
	
	if is_attacking:
		match _equipped_weapon:
			WEAPON_TYPE.DEFAULT:
				if is_aiming and is_on_floor():
					if _shoot_cooldown_tick > shoot_cooldown:
						_shoot_cooldown_tick = 0.0
						shoot()
				elif is_just_attacking:
					attack()
			WEAPON_TYPE.GRENADE:
				if _grenade_cooldown_tick > grenade_cooldown and _grenade_aim_controller:
					_grenade_cooldown_tick = 0.0
					_grenade_aim_controller.throw_grenade()


func attack() -> void:
	velocity = _character_skin.transform.basis * Vector3.MODEL_FRONT * attack_impulse
	if _character_skin and _character_skin.has_method("attack"):
		_character_skin.attack()
	if _character_melee_area:
		_character_melee_area.activate()
		await get_tree().create_timer(0.35).timeout
		_character_melee_area.deactivate()


func shoot() -> void:
	var bullet := BULLET_SCENE.instantiate()
	bullet.shooter = self
	var origin := global_position + Vector3.UP * 1.4
	var aim_target := _camera_controller.get_aim_target()
	var aim_direction := (aim_target - origin).normalized()
	bullet.velocity = aim_direction * bullet_speed
	bullet.distance_limit = 35.0
	get_parent().add_child(bullet)
	bullet.global_position = origin
	
	# Register firearm discharge crime
	var detector = get_tree().get_first_node_in_group("crime_detector")
	if detector and detector.has_method("register_crime"):
		detector.register_crime("FIREARM_DISCHARGE", global_position)
	elif Engine.has_singleton("EventBus") or get_node_or_null("/root/EventBus"):
		EventBus.crime_committed.emit("FIREARM_DISCHARGE", 2, global_position)


func play_foot_step_sound() -> void:
	if _step_sound:
		_step_sound.pitch_scale = randfn(1.15, 0.12)
		_step_sound.play()


func collect_coin() -> void:
	_coins += 1
	if _ui_coins_container:
		_ui_coins_container.update_coins_amount(_coins)
	if Engine.has_singleton("GameManager") or get_node_or_null("/root/GameManager"):
		GameManager.add_money(50)


func lose_coins() -> void:
	var lost_coins: int = min(_coins, 5)
	_coins -= lost_coins
	for i in lost_coins:
		var coin := COIN_SCENE.instantiate()
		get_parent().add_child(coin)
		coin.global_position = global_position
		coin.spawn(1.5)
	if _ui_coins_container:
		_ui_coins_container.update_coins_amount(_coins)
	if Engine.has_singleton("GameManager") or get_node_or_null("/root/GameManager"):
		GameManager.spend_money(lost_coins * 50)


func damage(_impact_point: Vector3, force: Vector3) -> void:
	force.y = abs(force.y)
	velocity = force.limit_length(max_throwback_force)
	lose_coins()
	
	var damage_amount := force.length() * 2.5
	current_health = maxf(0.0, current_health - damage_amount)
	if Engine.has_singleton("EventBus") or get_node_or_null("/root/EventBus"):
		EventBus.player_health_changed.emit(current_health, max_health)
	
	if current_health <= 0.0:
		if Engine.has_singleton("EventBus") or get_node_or_null("/root/EventBus"):
			EventBus.player_died.emit()
		current_health = max_health
		reset_position()
		if Engine.has_singleton("EventBus") or get_node_or_null("/root/EventBus"):
			EventBus.player_health_changed.emit(current_health, max_health)


func reset_position() -> void:
	transform.origin = _start_position


func _resolve_anti_stuck() -> void:
	var delta_pos := get_real_velocity()
	if delta_pos.length() < 0.001 and velocity.length() > 0.5:
		global_position += get_wall_normal() * 0.05


func _register_input_actions() -> void:
	const INPUT_ACTIONS := {
		"move_left": KEY_A,
		"move_right": KEY_D,
		"move_up": KEY_W,
		"move_down": KEY_S,
		"sprint": KEY_SHIFT,
		"interact": KEY_E,
		"jump": KEY_SPACE,
		"attack": MOUSE_BUTTON_LEFT,
		"aim": MOUSE_BUTTON_RIGHT,
		"swap_weapons": KEY_TAB,
		"pause": KEY_ESCAPE,
		"camera_left": KEY_LEFT,
		"camera_right": KEY_RIGHT,
		"camera_up": KEY_UP,
		"camera_down": KEY_DOWN,
		"vehicle_horn": KEY_H,
	}
	for action in INPUT_ACTIONS:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		var input_key = InputEventKey.new()
		input_key.keycode = INPUT_ACTIONS[action]
		InputMap.action_add_event(action, input_key)
