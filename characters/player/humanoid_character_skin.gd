# ==============================================================================
# HUMANOID CHARACTER SKIN (BANGLADESH PROTAGONIST)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Realistic human proportions, contemporary urban Dhaka attire, and natural
#          animation state machine with cross-fading for all 10+ locomotion states.
# ==============================================================================
class_name HumanoidCharacterSkin
extends Node3D

signal stepped

enum LocomotionState {
	IDLE,
	WALK,
	RUN,
	SPRINT,
	CROUCH,
	JUMP_START,
	JUMP_AIR,
	FALL,
	LAND,
	HARD_LAND,
	TURN_LEFT,
	TURN_RIGHT,
	INTERACT,
	ENTER_VEHICLE,
	EXIT_VEHICLE
}

var current_state: LocomotionState = LocomotionState.IDLE
var is_locked_in_animation: bool = false

# Backward compatibility with GDQuest CharacterSkin interface
var walk_run_blending: float = 0.0:
	set(value):
		walk_run_blending = clampf(value, 0.0, 1.0)
		_update_blend_state()

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var visual_root: Node3D = $VisualRoot

# Procedural lean and tilt offsets
var current_turn_lean: float = 0.0
var target_turn_lean: float = 0.0


func _ready() -> void:
	if animation_player:
		animation_player.play("idle")
	# Apply current outfit from GameManager
	if Engine.has_singleton("GameManager") or get_node_or_null("/root/GameManager"):
		apply_clothing_outfit(GameManager.current_outfit)


func apply_clothing_outfit(outfit_id: String) -> void:
	var outfit_data = EconomySystem.get_outfit(outfit_id)
	if outfit_data.is_empty():
		return
	
	var colors: Dictionary = outfit_data.get("colors", {})
	var c_torso: Color = colors.get("torso", Color(0.16, 0.22, 0.32, 1.0))
	var c_legs: Color = colors.get("legs", Color(0.18, 0.2, 0.26, 1.0))
	var c_feet: Color = colors.get("feet", Color(0.88, 0.88, 0.9, 1.0))
	
	# Apply to Torso Mesh
	var torso_node = get_node_or_null("VisualRoot/Hips/Torso")
	if torso_node and "material" in torso_node:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = c_torso
		mat.roughness = 0.7
		torso_node.material = mat
		
	# Apply to Legs & Shins
	var leg_paths = [
		"VisualRoot/Hips/LeftLeg/ThighMesh",
		"VisualRoot/Hips/LeftLeg/LeftShin/ShinMesh",
		"VisualRoot/Hips/RightLeg/ThighMesh",
		"VisualRoot/Hips/RightLeg/RightShin/ShinMesh"
	]
	for p in leg_paths:
		var node = get_node_or_null(p)
		if node and "material" in node:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = c_legs
			mat.roughness = 0.85
			node.material = mat
			
	# Apply to Shoes / Sandals
	var shoe_paths = [
		"VisualRoot/Hips/LeftLeg/LeftShin/LeftSneaker",
		"VisualRoot/Hips/RightLeg/RightShin/RightSneaker"
	]
	for p in shoe_paths:
		var node = get_node_or_null(p)
		if node and "material" in node:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = c_feet
			mat.roughness = 0.5
			node.material = mat
			
	AudioManager.play_sfx("res://audio/economy/cloth_equip.wav")


func _process(delta: float) -> void:
	# Smoothly apply dynamic lean into turns
	current_turn_lean = lerp(current_turn_lean, target_turn_lean, 10.0 * delta)
	if visual_root:
		visual_root.rotation.z = current_turn_lean


func set_turn_lean(turn_amount: float) -> void:
	target_turn_lean = clampf(-turn_amount * 0.15, -0.2, 0.2)


func idle() -> void:
	if is_locked_in_animation:
		return
	if current_state != LocomotionState.IDLE:
		current_state = LocomotionState.IDLE
		_crossfade_to("idle", 0.2)


func walk() -> void:
	if is_locked_in_animation:
		return
	if current_state != LocomotionState.WALK:
		current_state = LocomotionState.WALK
		_crossfade_to("walk", 0.18)


func move() -> void:
	# Generic move caller from GDQuest player controller
	if is_locked_in_animation:
		return
	if walk_run_blending > 0.65:
		sprint()
	elif walk_run_blending > 0.25:
		run()
	else:
		walk()


func run() -> void:
	if is_locked_in_animation:
		return
	if current_state != LocomotionState.RUN:
		current_state = LocomotionState.RUN
		_crossfade_to("run", 0.18)


func sprint() -> void:
	if is_locked_in_animation:
		return
	if current_state != LocomotionState.SPRINT:
		current_state = LocomotionState.SPRINT
		_crossfade_to("sprint", 0.15)


func crouch() -> void:
	if is_locked_in_animation:
		return
	if current_state != LocomotionState.CROUCH:
		current_state = LocomotionState.CROUCH
		if animation_player and animation_player.has_animation("crouch"):
			_crossfade_to("crouch", 0.15)
		elif visual_root:
			var tween := create_tween()
			tween.tween_property(visual_root, "position:y", -0.4, 0.15)


func stand_up() -> void:
	if visual_root:
		var tween := create_tween()
		tween.tween_property(visual_root, "position:y", 0.0, 0.15)
	idle()


func jump() -> void:
	if is_locked_in_animation:
		return
	current_state = LocomotionState.JUMP_AIR
	_crossfade_to("jump_air", 0.1)


func fall() -> void:
	if is_locked_in_animation:
		return
	if current_state != LocomotionState.FALL:
		current_state = LocomotionState.FALL
		_crossfade_to("fall", 0.2)


func land(hard_impact: bool = false) -> void:
	if hard_impact:
		current_state = LocomotionState.HARD_LAND
		is_locked_in_animation = true
		_crossfade_to("hard_land", 0.1)
		await animation_player.animation_finished
		is_locked_in_animation = false
		idle()
	else:
		current_state = LocomotionState.LAND
		_crossfade_to("land", 0.08)


func turn(direction: float) -> void:
	if is_locked_in_animation:
		return
	if direction < 0:
		current_state = LocomotionState.TURN_LEFT
		_crossfade_to("turn_left", 0.15)
	else:
		current_state = LocomotionState.TURN_RIGHT
		_crossfade_to("turn_right", 0.15)


func play_interaction() -> void:
	current_state = LocomotionState.INTERACT
	is_locked_in_animation = true
	_crossfade_to("interact", 0.15)
	await animation_player.animation_finished
	is_locked_in_animation = false
	idle()


func play_enter_vehicle() -> void:
	current_state = LocomotionState.ENTER_VEHICLE
	is_locked_in_animation = true
	_crossfade_to("enter_vehicle", 0.15)
	await animation_player.animation_finished
	is_locked_in_animation = false


func play_exit_vehicle() -> void:
	current_state = LocomotionState.EXIT_VEHICLE
	is_locked_in_animation = true
	_crossfade_to("exit_vehicle", 0.15)
	await animation_player.animation_finished
	is_locked_in_animation = false
	idle()


func attack() -> void:
	# Compatible with melee punch attack
	_crossfade_to("interact", 0.08)


func set_face(_face_name: String) -> void:
	# Realistic human skin doesn't use 2D cartoon face textures, but preserves interface
	pass


func _update_blend_state() -> void:
	if current_state in [LocomotionState.WALK, LocomotionState.RUN, LocomotionState.SPRINT]:
		if walk_run_blending > 0.7:
			sprint()
		elif walk_run_blending > 0.3:
			run()
		else:
			walk()


func _crossfade_to(anim_name: String, blend_time: float) -> void:
	if not animation_player:
		return
	if animation_player.has_animation(anim_name):
		animation_player.play(anim_name, blend_time)


# Animation event trigger called via AnimationPlayer method track
func emit_footstep() -> void:
	stepped.emit()
