# ==============================================================================
# BASE VEHICLE 3D (VEHICLE SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Master physics-driven vehicle controller inheriting VehicleBody3D.
#          Features realistic raycast suspension, speed-sensitive steering,
#          multi-gear automatic transmission, RPM curves, tire friction slip,
#          dynamic headlights/brake lights, contact damage, procedural audio,
#          animated door opening, and obstruction-free safe driver exit.
# ==============================================================================
class_name BaseVehicle3D
extends VehicleBody3D

signal driver_mounted(driver: Node)
signal driver_dismounted()

@export_category("Vehicle Identity")
@export var vehicle_name: String = "Private Sedan"
@export var max_engine_force: float = 380.0
@export var max_brake_force: float = 45.0
@export var base_max_speed_kmh: float = 160.0

@export_category("Steering Dynamics")
@export var max_steer_angle_rad: float = deg_to_rad(34.0)
@export var high_speed_steer_angle_rad: float = deg_to_rad(12.0)
@export var steer_speed: float = 6.0

@export_category("Transmission & Engine")
@export var gear_ratios: Array[float] = [-3.2, 0.0, 3.6, 2.2, 1.5, 1.0, 0.8]
@export var idle_rpm: float = 850.0
@export var max_rpm: float = 6800.0
@export var upshift_rpm: float = 5800.0
@export var downshift_rpm: float = 2400.0
@export var shift_delay: float = 0.18

@export_category("Health & Condition")
@export var max_health: float = 100.0
var current_health: float = 100.0

# Driving State
var is_driven: bool = false
var driver_ref: Node = null
var current_gear: int = 1 # 0 = Neutral, -1 = Reverse, 1..5 = Forward gears
var current_rpm: float = 850.0
var target_steer: float = 0.0
var is_shifting: bool = false
var shift_timer: float = 0.0
var headlights_active: bool = false

# Wheels Cache
var front_wheels: Array[VehicleWheel3D] = []
var rear_wheels: Array[VehicleWheel3D] = []
var all_wheels: Array[VehicleWheel3D] = []

# Node References
@onready var exit_point_left: Marker3D = $ExitPointLeft if has_node("ExitPointLeft") else null
@onready var exit_point_right: Marker3D = $ExitPointRight if has_node("ExitPointRight") else null
@onready var driver_door: Node3D = $DriverDoor if has_node("DriverDoor") else null
@onready var interactable_area: Interactable = $InteractableArea if has_node("InteractableArea") else null
@onready var vehicle_camera: VehicleCamera3D = $VehicleCamera3D if has_node("VehicleCamera3D") else null

# Lights
@onready var headlights: Node3D = $Lights/Headlights if has_node("Lights/Headlights") else null
@onready var brakelights: Node3D = $Lights/BrakeLights if has_node("Lights/BrakeLights") else null
@onready var reverselights: Node3D = $Lights/ReverseLights if has_node("Lights/ReverseLights") else null

# Audio
@onready var engine_audio: AudioStreamPlayer3D = $Audio/EngineAudio if has_node("Audio/EngineAudio") else null
@onready var horn_audio: AudioStreamPlayer3D = $Audio/HornAudio if has_node("Audio/HornAudio") else null
@onready var skid_audio: AudioStreamPlayer3D = $Audio/SkidAudio if has_node("Audio/SkidAudio") else null
@onready var impact_audio: AudioStreamPlayer3D = $Audio/ImpactAudio if has_node("Audio/ImpactAudio") else null
@onready var door_audio: AudioStreamPlayer3D = $Audio/DoorAudio if has_node("Audio/DoorAudio") else null

# Particles
@onready var smoke_particles: GPUParticles3D = $Particles/SmokeParticles if has_node("Particles/SmokeParticles") else null
@onready var fire_particles: GPUParticles3D = $Particles/FireParticles if has_node("Particles/FireParticles") else null


func _ready() -> void:
	current_health = max_health
	collision_layer = 1 << 2 # Layer 3: Vehicles
	collision_mask = 1 | (1 << 1) | (1 << 2) | (1 << 4) # Static, Player, Vehicles, Dynamic Props
	
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)
	
	_cache_wheels()
	
	if interactable_area:
		interactable_area.prompt_text = "Drive " + vehicle_name
		interactable_area.interacted.connect(_on_interaction_requested)
	
	if vehicle_camera:
		vehicle_camera.target_vehicle = self
		vehicle_camera.is_active = false
	
	_update_lights_visuals(false, false, false)


func _cache_wheels() -> void:
	front_wheels.clear()
	rear_wheels.clear()
	all_wheels.clear()
	
	for child in get_children():
		if child is VehicleWheel3D:
			all_wheels.append(child)
			if child.use_as_steering:
				front_wheels.append(child)
			if child.use_as_traction or not child.use_as_steering:
				rear_wheels.append(child)


func _physics_process(delta: float) -> void:
	var forward_dir := -global_transform.basis.z
	var current_velocity := linear_velocity
	var speed_ms := forward_dir.dot(current_velocity)
	var speed_kmh := abs(speed_ms) * 3.6
	
	if is_driven:
		_process_driver_input(delta, speed_kmh, speed_ms)
		EventBus.vehicle_speed_changed.emit(speed_kmh)
		EventBus.vehicle_gear_changed.emit(_get_gear_display_name(), current_rpm)
	else:
		_process_idle(delta)
	
	_update_audio(speed_kmh)


func _process_driver_input(delta: float, speed_kmh: float, speed_ms: float) -> void:
	var throttle_in := Input.get_action_strength("move_up")
	var brake_in := Input.get_action_strength("move_down")
	var steer_in := Input.get_axis("move_right", "move_left") # positive = turn left
	var handbrake_in := Input.is_action_pressed("jump")
	
	# Exit Vehicle
	if Input.is_action_just_pressed("interact"):
		GameManager.exit_vehicle()
		return
	
	# Horn
	if Input.is_action_just_pressed("vehicle_horn") or Input.is_key_pressed(KEY_H):
		honk_horn()
	
	# Headlights Toggle
	if Input.is_action_just_pressed("vehicle_headlights") or Input.is_key_pressed(KEY_L):
		headlights_active = not headlights_active
		EventBus.vehicle_lights_toggled.emit(headlights_active)
	
	# Speed-Sensitive Steering
	var speed_factor := clampf(speed_kmh / 120.0, 0.0, 1.0)
	var effective_max_steer := lerpf(max_steer_angle_rad, high_speed_steer_angle_rad, speed_factor)
	target_steer = steer_in * effective_max_steer
	steering = lerpf(steering, target_steer, steer_speed * delta)
	
	# Automatic Transmission & Gear Calculation
	_process_transmission(delta, throttle_in, brake_in, speed_ms, speed_kmh)
	
	# Apply Driving & Braking Forces to Wheels
	var is_braking_active := false
	var is_reversing_active := (current_gear == -1)
	
	if handbrake_in:
		# Lock rear wheels for handbrake drift
		for w in rear_wheels:
			w.brake = max_brake_force * 3.0
			w.engine_force = 0.0
		for w in front_wheels:
			w.brake = 0.0
		is_braking_active = true
		_check_drift_skid(true, speed_kmh)
	elif current_gear == -1:
		# Reverse drive
		var reverse_force = -max_engine_force * throttle_in * abs(gear_ratios[0]) * 0.45
		for w in rear_wheels:
			w.engine_force = reverse_force if not is_shifting else 0.0
			w.brake = brake_in * max_brake_force
		for w in front_wheels:
			w.brake = brake_in * max_brake_force
		is_braking_active = (brake_in > 0.1)
	else:
		# Forward drive
		if brake_in > 0.1 and speed_ms > 1.0:
			# Braking while in motion
			for w in all_wheels:
				w.brake = brake_in * max_brake_force
				w.engine_force = 0.0
			is_braking_active = true
		else:
			# Accelerating
			var gear_ratio_mult = abs(gear_ratios[current_gear + 1])
			var engine_output = max_engine_force * throttle_in * (gear_ratio_mult / 2.0)
			
			# Reduce torque if engine is badly damaged
			if current_health < 15.0:
				engine_output *= 0.45
			
			for w in rear_wheels:
				w.engine_force = engine_output if not is_shifting else 0.0
				w.brake = 0.0
			for w in front_wheels:
				w.brake = 0.0
		_check_drift_skid(false, speed_kmh)
	
	_update_lights_visuals(headlights_active, is_braking_active, is_reversing_active)


func _process_transmission(delta: float, throttle: float, brake: float, speed_ms: float, speed_kmh: float) -> void:
	if is_shifting:
		shift_timer -= delta
		if shift_timer <= 0.0:
			is_shifting = false
		return
	
	# Shift into Reverse when stationary and holding brake (S)
	if current_gear >= 0 and speed_kmh < 1.5 and brake > 0.6:
		current_gear = -1
		is_shifting = true
		shift_timer = shift_delay
		return
	# Shift back to Forward 1st gear when in reverse and pressing gas (W)
	elif current_gear == -1 and speed_kmh < 1.5 and throttle > 0.6:
		current_gear = 1
		is_shifting = true
		shift_timer = shift_delay
		return
	
	# Forward Gear Upshift/Downshift Logic
	if current_gear > 0:
		var gear_speed_band := speed_kmh / float(current_gear)
		current_rpm = clampf(idle_rpm + (gear_speed_band * 125.0) + (throttle * 800.0), idle_rpm, max_rpm)
		
		# Upshift
		if current_rpm >= upshift_rpm and current_gear < 5:
			current_gear += 1
			is_shifting = true
			shift_timer = shift_delay
			current_rpm = downshift_rpm + 600.0
		# Downshift
		elif current_rpm <= downshift_rpm and current_gear > 1:
			current_gear -= 1
			is_shifting = true
			shift_timer = shift_delay
			current_rpm = upshift_rpm - 800.0
	else:
		# Reverse RPM
		current_rpm = clampf(idle_rpm + (speed_kmh * 160.0) + (throttle * 700.0), idle_rpm, max_rpm * 0.7)


func _get_gear_display_name() -> String:
	if current_gear == -1:
		return "R"
	elif current_gear == 0:
		return "N"
	else:
		return "D (" + str(current_gear) + ")"


func _process_idle(delta: float) -> void:
	# Idle rolling friction
	for w in all_wheels:
		w.engine_force = 0.0
		w.brake = 8.0
	steering = lerpf(steering, 0.0, 4.0 * delta)
	current_rpm = move_toward(current_rpm, idle_rpm, 400.0 * delta)
	_update_lights_visuals(false, false, false)


func _update_lights_visuals(headlights_on: bool, braking_on: bool, reverse_on: bool) -> void:
	if headlights:
		headlights.visible = headlights_on
	if brakelights:
		brakelights.visible = braking_on or headlights_on
	if reverselights:
		reverselights.visible = reverse_on


func _check_drift_skid(handbrake_active: bool, speed_kmh: float) -> void:
	if not skid_audio:
		return
	
	var is_skidding := false
	if handbrake_active and speed_kmh > 15.0:
		is_skidding = true
	elif speed_kmh > 45.0 and abs(steering) > deg_to_rad(22.0):
		is_skidding = true
	
	if is_skidding:
		if not skid_audio.playing:
			skid_audio.play()
	else:
		if skid_audio.playing:
			skid_audio.stop()


func _update_audio(speed_kmh: float) -> void:
	if not engine_audio:
		return
	
	if is_driven:
		if not engine_audio.playing:
			engine_audio.play()
		# Modulate engine pitch smoothly with RPM
		var target_pitch := 0.75 + (current_rpm / max_rpm) * 1.35
		engine_audio.pitch_scale = lerpf(engine_audio.pitch_scale, target_pitch, 0.15)
	else:
		if speed_kmh < 1.0 and engine_audio.playing:
			engine_audio.stop()


func honk_horn() -> void:
	if horn_audio:
		horn_audio.pitch_scale = randfn(1.0, 0.04)
		horn_audio.play()
	EventBus.vehicle_horn_honked.emit(self)


func _on_body_entered(body: Node) -> void:
	# Physics collision damage calculation
	var impact_velocity := linear_velocity.length()
	if impact_velocity > 4.0:
		var damage_amount := (impact_velocity - 3.5) * 4.5
		take_damage(damage_amount)
		if impact_audio:
			impact_audio.pitch_scale = randfn(1.0, 0.08)
			impact_audio.play()
	
	# Crime Detection: Vehicular hit & run when player is driving
	if is_driven and impact_velocity > 5.0:
		if body is CharacterBody3D and (body.is_in_group("pedestrians") or body is BangladeshiPedestrian):
			if body.has_method("damage"):
				body.damage(global_position, linear_velocity * 2.0)
			EventBus.crime_committed.emit("VEHICLE_HIT_AND_RUN", 3, global_position)
		elif body.is_in_group("police_officers") or body.is_in_group("police_vehicles"):
			EventBus.crime_committed.emit("ASSAULT_POLICE", 3, global_position)


func take_damage(amount: float) -> void:
	current_health = maxf(0.0, current_health - amount)
	EventBus.vehicle_health_changed.emit(current_health, max_health)
	
	# Visual damage states
	if current_health < 40.0 and smoke_particles:
		smoke_particles.emitting = true
	if current_health < 15.0 and fire_particles:
		fire_particles.emitting = true


func mount_driver(driver: Node) -> void:
	is_driven = true
	driver_ref = driver
	
	if interactable_area:
		interactable_area.is_active = false
	
	# Animate driver door open then close
	_play_door_animation()
	
	if vehicle_camera:
		vehicle_camera.is_active = true
	
	driver_mounted.emit(driver)


func dismount_driver() -> void:
	is_driven = false
	driver_ref = null
	
	if interactable_area:
		interactable_area.is_active = true
	
	if vehicle_camera:
		vehicle_camera.is_active = false
	
	# Animate driver door open then close on exit
	_play_door_animation()
	
	driver_dismounted.emit()


func _play_door_animation() -> void:
	if door_audio:
		door_audio.play()
	
	if driver_door:
		# Quick tween to swing door open 45 degrees then latch back
		var tween = create_tween()
		tween.tween_property(driver_door, "rotation_degrees:y", 48.0, 0.18).set_trans(Tween.TRANS_QUAD)
		tween.tween_interval(0.12)
		tween.tween_property(driver_door, "rotation_degrees:y", 0.0, 0.18).set_trans(Tween.TRANS_BOUNCE)


func get_safe_exit_global_transform() -> Transform3D:
	# Safely determine spawn location outside vehicle using spatial raycast
	var space_state := get_world_3d().direct_space_state
	
	# Prefer Left (driver door) side
	var left_pos := global_position - (global_transform.basis.x * 2.1) + Vector3(0, 0.4, 0)
	var ray_query_left := PhysicsRayQueryParameters3D.create(global_position + Vector3(0, 0.4, 0), left_pos)
	ray_query_left.collision_mask = 1 # Static world
	var left_hit = space_state.intersect_ray(ray_query_left)
	
	if left_hit.is_empty():
		var t = global_transform
		t.origin = left_pos
		return t
	
	# Fall back to Right (passenger door) side if left is obstructed
	var right_pos := global_position + (global_transform.basis.x * 2.1) + Vector3(0, 0.4, 0)
	var ray_query_right := PhysicsRayQueryParameters3D.create(global_position + Vector3(0, 0.4, 0), right_pos)
	ray_query_right.collision_mask = 1
	var right_hit = space_state.intersect_ray(ray_query_right)
	
	if right_hit.is_empty():
		var t = global_transform
		t.origin = right_pos
		return t
	
	# Failsafe: roof spawn
	var t = global_transform
	t.origin = global_position + Vector3(0, 2.0, 0)
	return t


func _on_interaction_requested(_user: Node) -> void:
	if not is_driven:
		GameManager.enter_vehicle(self, "driver")


# ------------------------------------------------------------------------------
# GARAGE CUSTOMIZATION & REPAIR (PART 07 ECONOMY)
# ------------------------------------------------------------------------------
var engine_tune_stage: int = 0
var is_armor_plated: bool = false
var current_paint_color: Color = Color(0.9, 0.9, 0.9, 1.0)


func repair_vehicle() -> void:
	current_health = max_health
	if smoke_particles:
		smoke_particles.emitting = false
	if fire_particles:
		fire_particles.emitting = false
	EventBus.vehicle_health_changed.emit(current_health, max_health)
	AudioManager.play_sfx("res://audio/economy/wrench_ratchet.wav")


func set_custom_paint(color: Color) -> void:
	current_paint_color = color
	# Find and update body mesh material
	var target_mesh = get_node_or_null("VisualModel/BodyMesh")
	if not target_mesh:
		target_mesh = get_node_or_null("BodyMesh")
	if not target_mesh:
		# Search children for body or csg
		for child in get_children():
			if "Body" in child.name or "Cabin" in child.name or child is CSGPrimitive3D or child is MeshInstance3D:
				target_mesh = child
				break
				
	if target_mesh:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = color
		mat.roughness = 0.35
		mat.metallic = 0.2
		if "material" in target_mesh:
			target_mesh.material = mat
		elif "material_override" in target_mesh:
			target_mesh.material_override = mat


func apply_engine_tuning(level: int) -> void:
	engine_tune_stage = level
	var multiplier := 1.0 + float(level) * 0.25
	max_engine_force = 380.0 * multiplier
	base_max_speed_kmh = 160.0 * (1.0 + float(level) * 0.15)
	AudioManager.play_sfx("res://audio/economy/wrench_ratchet.wav")


func apply_armor_plating() -> void:
	is_armor_plated = true
	max_health = 180.0
	current_health = max_health
	EventBus.vehicle_health_changed.emit(current_health, max_health)
	AudioManager.play_sfx("res://audio/economy/wrench_ratchet.wav")
