# ==============================================================================
# MISSION TRIGGER (MISSION SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Interactive spatial trigger placed at questgiver NPCs or locations,
#          prompting player to accept and start story missions.
# ==============================================================================
class_name MissionTrigger
extends Node3D

signal mission_triggered(mission: MissionResource)

@export var mission_data: MissionResource = null
@export var prompt_speaker: String = "Quest Giver"
@export var trigger_color: Color = Color(1.0, 0.8, 0.2, 0.8)

var is_player_nearby: bool = false

# References
@onready var interactable_area: Interactable = $InteractableArea if has_node("InteractableArea") else null
@onready var marker_mesh: CSGCylinder3D = $MarkerMesh if has_node("MarkerMesh") else null
@onready var marker_label: Label3D = $MarkerLabel if has_node("MarkerLabel") else null


func _ready() -> void:
	if interactable_area and mission_data:
		interactable_area.prompt_text = "Talk to %s — %s" % [prompt_speaker, mission_data.title]
		interactable_area.interacted.connect(_on_interacted)
	
	if marker_label and mission_data:
		marker_label.text = "[!] %s" % mission_data.title
		marker_label.modulate = trigger_color
	
	_apply_visuals()


func _physics_process(delta: float) -> void:
	if marker_mesh:
		marker_mesh.rotation.y += delta * 1.5


func _on_interacted(_user: Node) -> void:
	if not mission_data:
		return
	
	mission_triggered.emit(mission_data)
	
	# If global MissionSystem exists
	var mission_sys = get_tree().get_first_node_in_group("mission_system") as MissionSystem
	if mission_sys:
		mission_sys.start_mission(mission_data)


func _apply_visuals() -> void:
	if marker_mesh:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = trigger_color
		mat.emission_enabled = true
		mat.emission = trigger_color
		mat.emission_energy_multiplier = 3.0
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		marker_mesh.material = mat
