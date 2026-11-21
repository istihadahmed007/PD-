# ==============================================================================
# INTERACTABLE COMPONENT
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Reusable trigger volume and raycast target for in-game interactions.
# ==============================================================================
class_name Interactable
extends Area3D

signal interacted(user: Node)

@export var prompt_text: String = "Interact"
@export var action_input: String = "interact"
@export var is_active: bool = true
@export var one_shot: bool = false

var _user_inside: Node = null


func _ready() -> void:
	# Interaction layer is Layer 7
	collision_layer = 1 << 6 # Layer 7
	collision_mask = 1 << 1  # Detect Player (Layer 2)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if not is_active or not _user_inside:
		return
	
	if event.is_action_pressed(action_input):
		execute_interaction(_user_inside)
		get_viewport().set_input_as_handled()


func execute_interaction(user: Node) -> void:
	if not is_active:
		return
	
	interacted.emit(user)
	EventBus.interaction_triggered.emit(self)
	
	if one_shot:
		is_active = false
		EventBus.interaction_cleared.emit()


func _on_body_entered(body: Node) -> void:
	if not is_active:
		return
	if body is CharacterBody3D or body.is_in_group("player"):
		_user_inside = body
		EventBus.interaction_available.emit(prompt_text, action_input)


func _on_body_exited(body: Node) -> void:
	if body == _user_inside:
		_user_inside = null
		EventBus.interaction_cleared.emit()
