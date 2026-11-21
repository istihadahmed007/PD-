# ==============================================================================
# 3D ITEM PICKUP ENTITY (ECONOMY & INTERACTION)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Interactive physical 3D ground item pickup with bobbing motion,
#          proximity detection, prompt cues, and inventory integration.
# ==============================================================================
class_name ItemPickup3D
extends Node3D

@export var item_id: String = "singara"
@export var quantity: int = 1
@export var auto_pickup: bool = false

@onready var visual_node: Node3D = $VisualNode if has_node("VisualNode") else self
@onready var interactable: Interactable = $Interactable if has_node("Interactable") else null

var _time_elapsed: float = 0.0
var _initial_y: float = 0.0


func _ready() -> void:
	_initial_y = position.y
	_update_appearance()
	
	if interactable:
		var item_info = EconomySystem.get_item(item_id)
		var item_name = item_info.get("name", item_id.capitalize())
		interactable.prompt_text = "Pick up %s (x%d)" % [item_name, quantity]
		interactable.interacted.connect(_on_pickup_triggered)


func _process(delta: float) -> void:
	_time_elapsed += delta
	# Bobbing and rotating animation
	if visual_node:
		visual_node.rotate_y(1.5 * delta)
		visual_node.position.y = _initial_y + sin(_time_elapsed * 3.0) * 0.12


func _update_appearance() -> void:
	var item_info = EconomySystem.get_item(item_id)
	var cat = item_info.get("category", EconomySystem.ItemCategory.FOOD_DRINK)
	
	var col := Color(1.0, 0.75, 0.2) # Default amber
	match cat:
		EconomySystem.ItemCategory.FOOD_DRINK:
			col = Color(1.0, 0.65, 0.15)
		EconomySystem.ItemCategory.UTILITY:
			col = Color(0.2, 0.8, 1.0)
		EconomySystem.ItemCategory.VALUABLE:
			col = Color(0.15, 0.9, 0.35)
		EconomySystem.ItemCategory.CLOTHING:
			col = Color(0.85, 0.35, 0.85)
			
	if has_node("VisualNode/MeshInstance3D"):
		var mesh_inst: MeshInstance3D = $VisualNode/MeshInstance3D
		var mat = StandardMaterial3D.new()
		mat.albedo_color = col
		mat.emission_enabled = true
		mat.emission = col * 0.4
		mesh_inst.material_override = mat


func _on_pickup_triggered(_user: Node) -> void:
	pickup()


func pickup() -> void:
	var success = GameManager.inventory.add_item(item_id, quantity)
	if success:
		AudioManager.play_sfx("res://audio/economy/item_pickup.wav")
		EventBus.interaction_cleared.emit()
		queue_free()
