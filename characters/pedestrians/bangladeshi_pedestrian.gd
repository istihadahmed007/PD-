# ==============================================================================
# BANGLADESHI PEDESTRIAN NPC (PEDESTRIAN SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Culturally authentic Bangladeshi street pedestrians with 5 distinct
#          archetypes (Chacha, Youth, Hawker, Office Babu, Salwar Kameez),
#          sidewalk navigation, zebra street crossings, shop browsing,
#          tea stall seating, vehicle avoidance reactions, and panic flee states.
# ==============================================================================
class_name BangladeshiPedestrian
extends CharacterBody3D

enum Archetype {
	CHACHA_PANJABI,
	STUDENT_YOUTH,
	HAWKER_LUNGI,
	OFFICE_BABU,
	FEMALE_SALWAR
}

enum State {
	WANDER_PATH,
	STAND_CHATTING,
	SHOP_BROWSE,
	TEA_STALL_SEATED,
	STREET_CROSSING,
	AVOID_VEHICLE,
	PANIC_FLEE
}

@export var archetype: Archetype = Archetype.STUDENT_YOUTH
@export var walk_speed: float = 2.2
@export var run_speed: float = 6.2
@export var gravity: float = 16.0

var current_state: State = State.WANDER_PATH
var target_destination: Vector3 = Vector3.ZERO
var state_timer: float = 0.0
var panic_source: Vector3 = Vector3.ZERO
var panic_duration: float = 0.0

# Path Following
var waypoint_path: Array[Vector3] = []
var path_index: int = 0

# References
@onready var visual_root: Node3D = $VisualRoot if has_node("VisualRoot") else null
@onready var animation_player: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null
@onready var vehicle_detector: RayCast3D = $VehicleDetector if has_node("VehicleDetector") else null
@onready var shout_audio: AudioStreamPlayer3D = $ShoutAudio if has_node("ShoutAudio") else null

# Clothing Meshes / Visual Variants
@onready var tupi_hat: Node3D = $VisualRoot/Head/TupiHat if has_node("VisualRoot/Head/TupiHat") else null
@onready var torso_mesh: CSGBox3D = $VisualRoot/Torso if has_node("VisualRoot/Torso") else null
@onready var legs_mesh: CSGBox3D = $VisualRoot/Legs if has_node("VisualRoot/Legs") else null
@onready var dupatta_mesh: CSGBox3D = $VisualRoot/Dupatta if has_node("VisualRoot/Dupatta") else null

var witness_component: WitnessComponent = null


func _ready() -> void:
	collision_layer = 1 << 3 # Layer 4: Pedestrians
	collision_mask = 1 | (1 << 1) | (1 << 2) # World, Player, Vehicles
	
	EventBus.pedestrian_panicked.connect(_on_global_panic_signal)
	EventBus.vehicle_horn_honked.connect(_on_vehicle_horn_heard)
	
	# Attach WitnessComponent for 999 crime reporting
	witness_component = WitnessComponent.new()
	witness_component.name = "WitnessComponent"
	witness_component.add_to_group("witnesses")
	add_child(witness_component)
	
	_apply_archetype_visuals()
	
	# Start with random wander timer or destination
	state_timer = randf_range(5.0, 15.0)


func _apply_archetype_visuals() -> void:
	if not visual_root:
		return
	
	# Hide all optional accessory meshes first
	if tupi_hat: tupi_hat.visible = false
	if dupatta_mesh: dupatta_mesh.visible = false
	
	var mat_torso = StandardMaterial3D.new()
	var mat_legs = StandardMaterial3D.new()
	
	match archetype:
		Archetype.CHACHA_PANJABI:
			if tupi_hat: tupi_hat.visible = true
			mat_torso.albedo_color = Color(0.92, 0.92, 0.88, 1) # White Panjabi
			mat_legs.albedo_color = Color(0.25, 0.45, 0.65, 1)  # Checked blue Lungi
			walk_speed = 1.8
		Archetype.STUDENT_YOUTH:
			mat_torso.albedo_color = Color(0.85, 0.22, 0.2, 1)  # Red graphic t-shirt
			mat_legs.albedo_color = Color(0.15, 0.2, 0.35, 1)   # Dark denim jeans
			walk_speed = 2.4
		Archetype.HAWKER_LUNGI:
			mat_torso.albedo_color = Color(0.88, 0.88, 0.85, 1) # Cotton vest (Ganji)
			mat_legs.albedo_color = Color(0.65, 0.25, 0.18, 1)  # Red checked Lungi
			walk_speed = 2.6
		Archetype.OFFICE_BABU:
			mat_torso.albedo_color = Color(0.65, 0.78, 0.92, 1) # Light blue formal shirt
			mat_legs.albedo_color = Color(0.2, 0.22, 0.25, 1)   # Charcoal slacks
			walk_speed = 2.2
		Archetype.FEMALE_SALWAR:
			if dupatta_mesh: dupatta_mesh.visible = true
			mat_torso.albedo_color = Color(0.88, 0.2, 0.55, 1)  # Magenta Salwar
			mat_legs.albedo_color = Color(0.92, 0.85, 0.3, 1)   # Yellow Pajama
			walk_speed = 2.1
	
	if torso_mesh: torso_mesh.material = mat_torso
	if legs_mesh: legs_mesh.material = mat_legs


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = -0.1
	
	# Check vehicle threat in front
	_check_vehicle_threat()
	
	match current_state:
		State.WANDER_PATH:
			_process_wander_path(delta)
		State.STREET_CROSSING:
			_process_street_crossing(delta)
		State.STAND_CHATTING, State.SHOP_BROWSE, State.TEA_STALL_SEATED:
			_process_idle_state(delta)
		State.AVOID_VEHICLE:
			_process_avoid_vehicle(delta)
		State.PANIC_FLEE:
			_process_panic(delta)
	
	move_and_slide()


func _check_vehicle_threat() -> void:
	if current_state == State.PANIC_FLEE or current_state == State.AVOID_VEHICLE:
		return
	
	if vehicle_detector and vehicle_detector.is_colliding():
		var col = vehicle_detector.get_collider()
		if col is VehicleBody3D or col is BaseVehicle:
			# Vehicle approaching in close proximity! Dodge!
			trigger_vehicle_avoidance(col.global_position)


func trigger_vehicle_avoidance(vehicle_pos: Vector3) -> void:
	current_state = State.AVOID_VEHICLE
	state_timer = 1.4
	
	# Sidestep perpendicular to vehicle
	var away_dir := (global_position - vehicle_pos)
	away_dir.y = 0
	if away_dir.length() < 0.2:
		away_dir = transform.basis.x
	var dodge_dir := away_dir.normalized()
	
	velocity.x = dodge_dir.x * 4.8
	velocity.z = dodge_dir.z * 4.8
	
	# Vocal shout reaction
	if shout_audio and not shout_audio.playing:
		shout_audio.pitch_scale = randfn(1.0, 0.08)
		shout_audio.play()


func _process_avoid_vehicle(delta: float) -> void:
	state_timer -= delta
	if state_timer <= 0.0:
		current_state = State.WANDER_PATH


func _process_wander_path(delta: float) -> void:
	if waypoint_path.is_empty():
		return
	
	var target := waypoint_path[path_index]
	var to_target := target - global_position
	to_target.y = 0
	
	if to_target.length() < 1.4:
		path_index = (path_index + 1) % waypoint_path.size()
		# Chance to pause and browse shop or chat
		if randf() < 0.2:
			current_state = State.STAND_CHATTING if randf() < 0.5 else State.SHOP_BROWSE
			state_timer = randf_range(4.0, 10.0)
		return
	
	var move_dir := to_target.normalized()
	velocity.x = move_dir.x * walk_speed
	velocity.z = move_dir.z * walk_speed
	
	# Smooth rotation toward motion
	var target_basis := Basis.looking_at(move_dir, Vector3.UP)
	transform.basis = transform.basis.slerp(target_basis, 8.0 * delta)
	
	if animation_player and not animation_player.current_animation == "walk":
		animation_player.play("walk")


func _process_street_crossing(delta: float) -> void:
	# Cross street briskly to target destination
	var to_dest := target_destination - global_position
	to_dest.y = 0
	
	if to_dest.length() < 1.2:
		current_state = State.WANDER_PATH
		return
	
	var move_dir := to_dest.normalized()
	velocity.x = move_dir.x * (walk_speed * 1.35)
	velocity.z = move_dir.z * (walk_speed * 1.35)
	
	var target_basis := Basis.looking_at(move_dir, Vector3.UP)
	transform.basis = transform.basis.slerp(target_basis, 10.0 * delta)


func _process_idle_state(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 8.0 * delta)
	velocity.z = move_toward(velocity.z, 0.0, 8.0 * delta)
	
	if animation_player and not animation_player.current_animation == "idle":
		animation_player.play("idle")
	
	state_timer -= delta
	if state_timer <= 0.0:
		current_state = State.WANDER_PATH


func _process_panic(delta: float) -> void:
	panic_duration -= delta
	if panic_duration <= 0.0:
		current_state = State.WANDER_PATH
		return
	
	var flee_dir := (global_position - panic_source)
	flee_dir.y = 0
	if flee_dir.length() < 0.1:
		flee_dir = -transform.basis.z
	flee_dir = flee_dir.normalized()
	
	velocity.x = flee_dir.x * run_speed
	velocity.z = flee_dir.z * run_speed
	
	var target_basis := Basis.looking_at(flee_dir, Vector3.UP)
	transform.basis = transform.basis.slerp(target_basis, 12.0 * delta)
	
	if animation_player and not animation_player.current_animation == "run":
		animation_player.play("run")


func trigger_panic(threat_origin: Vector3) -> void:
	panic_source = threat_origin
	panic_duration = randf_range(7.0, 14.0)
	current_state = State.PANIC_FLEE
	if shout_audio and not shout_audio.playing:
		shout_audio.play()


func _on_global_panic_signal(threat_pos: Vector3) -> void:
	if global_position.distance_to(threat_pos) < 40.0:
		trigger_panic(threat_pos)


func _on_vehicle_horn_heard(vehicle: Node) -> void:
	if not is_instance_valid(vehicle):
		return
	if global_position.distance_to(vehicle.global_position) < 8.0:
		trigger_vehicle_avoidance(vehicle.global_position)


func damage(hit_pos: Vector3, force: Vector3) -> void:
	velocity = force.limit_length(10.0)
	trigger_panic(hit_pos)
	# Notify crime detector / witnesses
	var crime_type = "ASSAULT_CIVILIAN"
	var detector = get_tree().get_first_node_in_group("crime_detector")
	if detector and detector.has_method("register_crime"):
		detector.register_crime(crime_type, global_position)
	else:
		EventBus.crime_committed.emit(crime_type, 1, global_position)
