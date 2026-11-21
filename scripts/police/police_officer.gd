# ==============================================================================
# POLICE OFFICER AGENT (POLICE SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Dhaka Metropolitan Police (DMP) on-foot law enforcement AI agent.
#          Features vision sensor, patrol waypoints, Bengali shout audio,
#          baton melee arrest attempts (1-2 stars), and sidearm/rifle firearm
#          engagement (3-5 stars).
# ==============================================================================
class_name PoliceOfficer
extends CharacterBody3D

signal officer_died(officer: Node)
signal arrest_triggered(officer: Node)

enum OfficerState {
	PATROL,
	INVESTIGATE,
	PURSUE_FOOT,
	ARREST_ATTEMPT,
	ATTACK_MELEE,
	SHOOT_FIREARM,
	GUARD_CHECKPOINT
}

@export_category("Officer Attributes")
@export var officer_name: String = "DMP Constable"
@export var walk_speed: float = 2.4
@export var run_speed: float = 6.8
@export var max_health: float = 100.0
@export var gravity: float = 16.0
@export var waypoints: Array[Node3D] = []

@export_category("Combat & Arrest")
@export var arrest_distance: float = 2.2
@export var melee_range: float = 2.0
@export var firearm_range: float = 24.0
@export var shoot_interval: float = 0.85
@export var melee_damage: float = 18.0

var current_health: float = 100.0
var current_state: OfficerState = OfficerState.PATROL
var target_destination: Vector3 = Vector3.ZERO
var current_waypoint_idx: int = 0
var shoot_timer: float = 0.0
var arrest_timer: float = 0.0
var whistle_cooldown: float = 0.0
var is_active_pursuit: bool = false

# References
@onready var vision_sensor: PoliceVisionSensor = $VisionSensor if has_node("VisionSensor") else null
@onready var animation_player: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null
@onready var audio_whistle: AudioStreamPlayer3D = $AudioWhistle if has_node("AudioWhistle") else null
@onready var audio_radio: AudioStreamPlayer3D = $AudioRadio if has_node("AudioRadio") else null
@onready var audio_shoot: AudioStreamPlayer3D = $AudioShoot if has_node("AudioShoot") else null
@onready var visual_root: Node3D = $VisualRoot if has_node("VisualRoot") else null
@onready var baton_mesh: Node3D = $VisualRoot/RightHand/Baton if has_node("VisualRoot/RightHand/Baton") else null
@onready var gun_mesh: Node3D = $VisualRoot/RightHand/Gun if has_node("VisualRoot/RightHand/Gun") else null
@onready var muzzle_flash: OmniLight3D = $VisualRoot/RightHand/Gun/MuzzleFlash if has_node("VisualRoot/RightHand/Gun/MuzzleFlash") else null


func _ready() -> void:
	current_health = max_health
	add_to_group("police_officers")
	
	collision_layer = 1 << 3 # Layer 4: Pedestrians / NPCs
	collision_mask = 1 | (1 << 1) | (1 << 2) # World, Player, Vehicles
	
	if not vision_sensor:
		vision_sensor = PoliceVisionSensor.new()
		vision_sensor.name = "VisionSensor"
		vision_sensor.fov_degrees = 120.0
		vision_sensor.base_view_distance = 38.0
		add_child(vision_sensor)
	
	vision_sensor.player_spotted.connect(_on_player_spotted)
	vision_sensor.player_lost.connect(_on_player_lost)
	
	EventBus.wanted_level_changed.connect(_on_wanted_level_changed)
	EventBus.crime_committed.connect(_on_crime_committed)
	
	_update_weapon_visuals()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = -0.1
	
	whistle_cooldown -= delta
	shoot_timer -= delta
	
	match current_state:
		OfficerState.PATROL:
			_process_patrol(delta)
		OfficerState.INVESTIGATE:
			_process_investigate(delta)
		OfficerState.PURSUE_FOOT:
			_process_pursue(delta)
		OfficerState.ARREST_ATTEMPT:
			_process_arrest(delta)
		OfficerState.ATTACK_MELEE:
			_process_melee(delta)
		OfficerState.SHOOT_FIREARM:
			_process_shoot(delta)
		OfficerState.GUARD_CHECKPOINT:
			_process_guard(delta)
	
	move_and_slide()


func _process_patrol(delta: float) -> void:
	if waypoints.is_empty():
		velocity.x = 0
		velocity.z = 0
		return
	
	var target = waypoints[current_waypoint_idx]
	if not is_instance_valid(target):
		return
	
	var to_target = target.global_position - global_position
	to_target.y = 0
	
	if to_target.length() < 1.5:
		current_waypoint_idx = (current_waypoint_idx + 1) % waypoints.size()
		return
	
	var move_dir = to_target.normalized()
	velocity.x = move_dir.x * walk_speed
	velocity.z = move_dir.z * walk_speed
	_face_direction(move_dir, delta, 5.0)


func _process_investigate(delta: float) -> void:
	var to_dest = target_destination - global_position
	to_dest.y = 0
	
	if to_dest.length() < 2.0:
		# Arrived at scene, return to patrol if nothing found
		current_state = OfficerState.PATROL
		velocity.x = 0
		velocity.z = 0
		return
	
	var move_dir = to_dest.normalized()
	velocity.x = move_dir.x * walk_speed * 1.3
	velocity.z = move_dir.z * walk_speed * 1.3
	_face_direction(move_dir, delta, 6.0)


func _process_pursue(delta: float) -> void:
	var target_entity = _get_target_entity()
	if not is_instance_valid(target_entity):
		current_state = OfficerState.INVESTIGATE
		return
	
	var to_target = target_entity.global_position - global_position
	var dist = to_target.length()
	to_target.y = 0
	
	# Whistle when pursuing
	if whistle_cooldown <= 0.0 and audio_whistle and randf() < 0.25:
		audio_whistle.pitch_scale = randf_range(0.95, 1.1)
		audio_whistle.play()
		whistle_cooldown = randf_range(4.5, 9.0)
	
	# Check distance thresholds based on wanted level
	var stars = GameManager.wanted_stars
	if stars <= 2 and dist <= arrest_distance:
		current_state = OfficerState.ARREST_ATTEMPT
		arrest_timer = 2.0
		velocity.x = 0
		velocity.z = 0
		return
	elif stars >= 3 and dist <= firearm_range and vision_sensor.can_see_player:
		current_state = OfficerState.SHOOT_FIREARM
		velocity.x = 0
		velocity.z = 0
		return
	elif dist <= melee_range:
		current_state = OfficerState.ATTACK_MELEE
		return
	
	# Sprint towards target
	var move_dir = to_target.normalized()
	velocity.x = move_dir.x * run_speed
	velocity.z = move_dir.z * run_speed
	_face_direction(move_dir, delta, 9.0)


func _process_arrest(delta: float) -> void:
	var target_entity = _get_target_entity()
	if not is_instance_valid(target_entity):
		current_state = OfficerState.PATROL
		return
	
	var dist = global_position.distance_to(target_entity.global_position)
	if dist > arrest_distance * 1.8:
		# Player resisted/ran away!
		current_state = OfficerState.PURSUE_FOOT
		return
	
	var to_target = (target_entity.global_position - global_position).normalized()
	to_target.y = 0
	_face_direction(to_target, delta, 12.0)
	
	arrest_timer -= delta
	if arrest_timer <= 0.0:
		# Arrest successful!
		_execute_arrest()


func _process_melee(delta: float) -> void:
	var target_entity = _get_target_entity()
	if not is_instance_valid(target_entity):
		current_state = OfficerState.PATROL
		return
	
	var dist = global_position.distance_to(target_entity.global_position)
	if dist > melee_range * 1.5:
		current_state = OfficerState.PURSUE_FOOT
		return
	
	# Strike with baton
	if shoot_timer <= 0.0:
		shoot_timer = 0.9
		if target_entity.has_method("damage"):
			var impact_dir = (target_entity.global_position - global_position).normalized()
			target_entity.damage(target_entity.global_position, impact_dir * melee_damage)


func _process_shoot(delta: float) -> void:
	var target_entity = _get_target_entity()
	if not is_instance_valid(target_entity) or not vision_sensor.can_see_player:
		current_state = OfficerState.PURSUE_FOOT
		return
	
	var to_target = target_entity.global_position - global_position
	var dist = to_target.length()
	to_target.y = 0
	_face_direction(to_target.normalized(), delta, 12.0)
	
	if dist > firearm_range * 1.2:
		current_state = OfficerState.PURSUE_FOOT
		return
	
	velocity.x = 0
	velocity.z = 0
	
	if shoot_timer <= 0.0:
		shoot_timer = shoot_interval
		_fire_at_player()


func _process_guard(delta: float) -> void:
	velocity.x = 0
	velocity.z = 0
	if GameManager.wanted_stars > 0 and vision_sensor.can_see_player:
		current_state = OfficerState.PURSUE_FOOT


func _fire_at_player() -> void:
	if audio_shoot:
		audio_shoot.pitch_scale = randf_range(0.9, 1.15)
		audio_shoot.play()
	
	if muzzle_flash:
		muzzle_flash.visible = true
		get_tree().create_timer(0.06).timeout.connect(func(): if is_instance_valid(muzzle_flash): muzzle_flash.visible = false)
	
	# Spawn bullet or apply hitscan raycast damage
	var target_entity = _get_target_entity()
	if is_instance_valid(target_entity):
		# Slight accuracy jitter
		var aim_pos = target_entity.global_position + Vector3(randf_range(-0.4, 0.4), 1.2, randf_range(-0.4, 0.4))
		var shoot_dir = (aim_pos - global_position).normalized()
		
		# Bullet impact on player or vehicle
		if target_entity.has_method("damage"):
			target_entity.damage(aim_pos, shoot_dir * 12.0)
		elif target_entity is BaseVehicle3D:
			(target_entity as BaseVehicle3D).apply_central_impulse(shoot_dir * 25.0)


func _execute_arrest() -> void:
	arrest_triggered.emit(self)
	EventBus.police_arrest_triggered.emit(self)
	
	# Play handcuff click audio
	if audio_radio and ResourceLoader.exists("res://audio/police/handcuff_click.wav"):
		audio_radio.stream = load("res://audio/police/handcuff_click.wav")
		audio_radio.play()
	
	# Clear wanted level and penalize cash
	GameManager.spend_money(500)
	GameManager.set_wanted_level(0)
	current_state = OfficerState.PATROL


func _on_player_spotted(p: Node, _dist: float) -> void:
	if GameManager.wanted_stars > 0:
		is_active_pursuit = true
		current_state = OfficerState.PURSUE_FOOT
		EventBus.police_spotted_player.emit(self, p.global_position)


func _on_player_lost() -> void:
	if is_active_pursuit and current_state == OfficerState.PURSUE_FOOT:
		target_destination = global_position
		current_state = OfficerState.INVESTIGATE


func _on_wanted_level_changed(stars: int) -> void:
	_update_weapon_visuals()
	if stars <= 0:
		is_active_pursuit = false
		current_state = OfficerState.PATROL
	elif vision_sensor and vision_sensor.can_see_player:
		current_state = OfficerState.PURSUE_FOOT


func _on_crime_committed(_type: String, _sev: int, loc: Vector3) -> void:
	if current_state == OfficerState.PATROL:
		target_destination = loc
		current_state = OfficerState.INVESTIGATE


func _update_weapon_visuals() -> void:
	var stars = GameManager.wanted_stars
	if baton_mesh:
		baton_mesh.visible = (stars <= 2)
	if gun_mesh:
		gun_mesh.visible = (stars >= 3)


func _get_target_entity() -> Node3D:
	if GameManager.current_state == GameManager.GameState.IN_VEHICLE and is_instance_valid(GameManager.active_vehicle):
		return GameManager.active_vehicle as Node3D
	return GameManager.active_player


func _face_direction(dir: Vector3, delta: float, turn_speed: float) -> void:
	if dir.length_squared() < 0.001:
		return
	var target_basis = Basis.looking_at(dir, Vector3.UP)
	transform.basis = transform.basis.slerp(target_basis, turn_speed * delta)


func damage(hit_pos: Vector3, force: Vector3) -> void:
	current_health -= force.length() * 1.5
	if current_health <= 0.0:
		# Officer down: escalates heat!
		EventBus.crime_committed.emit("ASSAULT_POLICE", 3, global_position)
		officer_died.emit(self)
		queue_free()
	else:
		# Aggro
		current_state = OfficerState.PURSUE_FOOT
