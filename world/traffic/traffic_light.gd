# ==============================================================================
# TRAFFIC LIGHT INTERSECTION CONTROLLER (TRAFFIC SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: 4-phase traffic signal cycle coordinating right-of-way, stop-lines,
#          and visual red/yellow/green illumination.
# ==============================================================================
class_name TrafficLightController
extends Node3D

enum TrafficPhase {
	NORTH_SOUTH_GREEN,
	NORTH_SOUTH_YELLOW,
	EAST_WEST_GREEN,
	EAST_WEST_YELLOW
}

@export var phase_durations := {
	TrafficPhase.NORTH_SOUTH_GREEN: 12.0,
	TrafficPhase.NORTH_SOUTH_YELLOW: 3.0,
	TrafficPhase.EAST_WEST_GREEN: 10.0,
	TrafficPhase.EAST_WEST_YELLOW: 3.0
}

@export var road_network: RoadNetwork3D = null

var current_phase: TrafficPhase = TrafficPhase.NORTH_SOUTH_GREEN
var phase_timer: float = 0.0

# Node references for lights
@onready var ns_red_light: SpotLight3D = $VisualGantry/NorthSouth/RedLight if has_node("VisualGantry/NorthSouth/RedLight") else null
@onready var ns_yellow_light: SpotLight3D = $VisualGantry/NorthSouth/YellowLight if has_node("VisualGantry/NorthSouth/YellowLight") else null
@onready var ns_green_light: SpotLight3D = $VisualGantry/NorthSouth/GreenLight if has_node("VisualGantry/NorthSouth/GreenLight") else null

@onready var ew_red_light: SpotLight3D = $VisualGantry/EastWest/RedLight if has_node("VisualGantry/EastWest/RedLight") else null
@onready var ew_yellow_light: SpotLight3D = $VisualGantry/EastWest/YellowLight if has_node("VisualGantry/EastWest/YellowLight") else null
@onready var ew_green_light: SpotLight3D = $VisualGantry/EastWest/GreenLight if has_node("VisualGantry/EastWest/GreenLight") else null


func _ready() -> void:
	phase_timer = phase_durations[current_phase]
	_apply_phase_to_network()
	_update_visual_signals()


func _process(delta: float) -> void:
	phase_timer -= delta
	if phase_timer <= 0.0:
		_advance_phase()


func _advance_phase() -> void:
	var next_idx = (int(current_phase) + 1) % TrafficPhase.size()
	current_phase = next_idx as TrafficPhase
	phase_timer = phase_durations[current_phase]
	
	_apply_phase_to_network()
	_update_visual_signals()
	
	var axis_str := "NORTH_SOUTH" if (current_phase == TrafficPhase.NORTH_SOUTH_GREEN or current_phase == TrafficPhase.NORTH_SOUTH_YELLOW) else "EAST_WEST"
	EventBus.traffic_light_state_changed.emit("intersection_main_bazaar", axis_str)


func _apply_phase_to_network() -> void:
	if not road_network:
		return
	
	match current_phase:
		TrafficPhase.NORTH_SOUTH_GREEN:
			# NS can go, EW must stop
			road_network.set_stop_state(3, false)  # Southbound
			road_network.set_stop_state(17, false) # Northbound
			road_network.set_stop_state(25, true)  # Eastbound
			road_network.set_stop_state(33, true)  # Westbound
		TrafficPhase.NORTH_SOUTH_YELLOW:
			# NS prepares to stop, EW still stops
			road_network.set_stop_state(3, true)
			road_network.set_stop_state(17, true)
			road_network.set_stop_state(25, true)
			road_network.set_stop_state(33, true)
		TrafficPhase.EAST_WEST_GREEN:
			# EW can go, NS must stop
			road_network.set_stop_state(3, true)
			road_network.set_stop_state(17, true)
			road_network.set_stop_state(25, false)
			road_network.set_stop_state(33, false)
		TrafficPhase.EAST_WEST_YELLOW:
			# All prepare to stop
			road_network.set_stop_state(3, true)
			road_network.set_stop_state(17, true)
			road_network.set_stop_state(25, true)
			road_network.set_stop_state(33, true)


func _update_visual_signals() -> void:
	var ns_is_green = (current_phase == TrafficPhase.NORTH_SOUTH_GREEN)
	var ns_is_yellow = (current_phase == TrafficPhase.NORTH_SOUTH_YELLOW)
	var ns_is_red = not (ns_is_green or ns_is_yellow)
	
	var ew_is_green = (current_phase == TrafficPhase.EAST_WEST_GREEN)
	var ew_is_yellow = (current_phase == TrafficPhase.EAST_WEST_YELLOW)
	var ew_is_red = not (ew_is_green or ew_is_yellow)
	
	if ns_green_light: ns_green_light.visible = ns_is_green
	if ns_yellow_light: ns_yellow_light.visible = ns_is_yellow
	if ns_red_light: ns_red_light.visible = ns_is_red
	
	if ew_green_light: ew_green_light.visible = ew_is_green
	if ew_yellow_light: ew_yellow_light.visible = ew_is_yellow
	if ew_red_light: ew_red_light.visible = ew_is_red
