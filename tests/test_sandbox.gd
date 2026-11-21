# ==============================================================================
# TEST SANDBOX CONTROLLER
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Orchestrates the Phase 00 test sandbox, connecting all 14 systems.
# ==============================================================================
extends Node3D

@onready var tong_interactable: Interactable = %TongInteractable if has_node("%TongInteractable") else null
@onready var test_rickshaw: RickshawVehicle = %Rickshaw if has_node("%Rickshaw") else null
@onready var test_pedestrian: PedestrianAgent = %TestPedestrian if has_node("%TestPedestrian") else null
@onready var player: CharacterBody3D = %Player if has_node("%Player") else null


func _ready() -> void:
	if tong_interactable:
		tong_interactable.interacted.connect(_on_tong_interacted)
	
	# Set starting mission toast to guide testing
	var mission := MissionResource.new()
	mission.title = "Explore Dhaka Sandbox Block"
	mission.objectives = [
		"Walk/Sprint along the sidewalk [WASD + Shift]",
		"Order hot tea at the Roadside Tong [Press E]",
		"Ride the Cycle Rickshaw [Press E to Mount, W/S to Pedal, Space for Brake, H for Bell, E to Dismount]",
		"Smash the supply crates with attack [Left Click] or shot [Right Click to Aim]",
		"Observe the sidewalk pedestrian reacting to nearby action"
	]
	
	# Small delay to let HUD initialize
	await get_tree().create_timer(0.5).timeout
	var mission_system := MissionSystem.new()
	add_child(mission_system)
	mission_system.start_mission(mission)


func _on_tong_interacted(_user: Node) -> void:
	if GameManager.spend_money(10):
		if player and player.get("current_stamina") != null:
			player.current_stamina = 100.0
			EventBus.player_stamina_changed.emit(100.0, 100.0)
		EventBus.mission_objective_updated.emit(1, "Hot spiced Cha consumed! Stamina restored.")
	else:
		EventBus.mission_objective_updated.emit(1, "Not enough money for Cha! Need ৳ 10.")
