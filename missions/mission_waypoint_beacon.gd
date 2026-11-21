# ==============================================================================
# MISSION WAYPOINT BEACON (MISSION SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Visual 3D world beacon with glowing vertical pillar, floating chevron,
#          real-time distance readout, and Area3D player/vehicle trigger detection.
# ==============================================================================
class_name MissionWaypointBeacon
extends Node3D

signal beacon_reached(body: Node)

@export var beacon_color: Color = Color(0.2, 0.85, 1.0, 0.8)
@export var prompt_description: String = "Objective Waypoint"
@export var trigger_radius: float = 4.5

var is_active: bool = false
var bob_time: float = 0.0

# Node References
@onready var beam_mesh: CSGCylinder3D = $BeamMesh if has_node("BeamMesh") else null
@onready var chevron_mesh: Node3D = $Chevron if has_node("Chevron") else null
@onready var ground_ring: CSGCylinder3D = $GroundRing if has_node("GroundRing") else null
@onready var distance_label: Label3D = $DistanceLabel if has_node("DistanceLabel") else null
@onready var trigger_area: Area3D = $TriggerArea if has_node("TriggerArea") else null


func _ready() -> void:
	if trigger_area:
		trigger_area.body_entered.connect(_on_trigger_body_entered)
	_apply_visual_styling()


func _physics_process(delta: float) -> void:
	if not is_active:
		return
	
	bob_time += delta
	if chevron_mesh:
		chevron_mesh.position.y = 2.4 + sin(bob_time * 3.5) * 0.25
		chevron_mesh.rotation.y += delta * 1.8
	
	if ground_ring:
		ground_ring.scale = Vector3.ONE * (1.0 + sin(bob_time * 2.0) * 0.1)
	
	_update_distance_label()


func _update_distance_label() -> void:
	if not distance_label:
		return
	
	var player_node: Node3D = null
	if GameManager.current_state == GameManager.GameState.IN_VEHICLE and is_instance_valid(GameManager.active_vehicle):
		player_node = GameManager.active_vehicle as Node3D
	elif is_instance_valid(GameManager.active_player):
		player_node = GameManager.active_player as Node3D
	
	if is_instance_valid(player_node):
		var dist = global_position.distance_to(player_node.global_position)
		distance_label.text = "[ %dm ] %s" % [int(dist), prompt_description]


func set_beacon_data(target_pos: Vector3, desc: String, radius: float = 4.5, color: Color = Color(0.2, 0.85, 1.0, 0.8)) -> void:
	global_position = target_pos
	prompt_description = desc
	trigger_radius = radius
	beacon_color = color
	is_active = true
	visible = true
	
	if trigger_area and trigger_area.has_node("CollisionShape3D"):
		var col_shape = trigger_area.get_node("CollisionShape3D") as CollisionShape3D
		if col_shape.shape is CylinderShape3D:
			(col_shape.shape as CylinderShape3D).radius = trigger_radius
	
	_apply_visual_styling()


func hide_beacon() -> void:
	is_active = false
	visible = false


func _apply_visual_styling() -> void:
	var mat_beam = StandardMaterial3D.new()
	mat_beam.albedo_color = beacon_color
	mat_beam.emission_enabled = true
	mat_beam.emission = beacon_color
	mat_beam.emission_energy_multiplier = 3.5
	mat_beam.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_beam.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	if beam_mesh:
		beam_mesh.material = mat_beam
	if ground_ring:
		ground_ring.material = mat_beam
	if distance_label:
		distance_label.modulate = beacon_color


func _on_trigger_body_entered(body: Node3D) -> void:
	if not is_active:
		return
	
	# Verify body is active player or player's vehicle
	var is_player = (body == GameManager.active_player)
	var is_vehicle = (GameManager.current_state == GameManager.GameState.IN_VEHICLE and body == GameManager.active_vehicle)
	
	if is_player or is_vehicle:
		beacon_reached.emit(body)
