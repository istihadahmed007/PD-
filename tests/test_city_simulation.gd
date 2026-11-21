# ==============================================================================
# CITY SIMULATION TEST CONTROLLER (TEST SUITE)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Comprehensive diagnostic harness for pedestrian crowd behavior,
#          autonomous traffic flow, traffic lights, honk cascades, and density settings.
# ==============================================================================
extends Node3D

@onready var traffic_system: TrafficSystem = $TrafficSystem if has_node("TrafficSystem") else null
@onready var pedestrian_system: PedestrianSystem = $PedestrianSystem if has_node("PedestrianSystem") else null
@onready var traffic_light: TrafficLightController = $TrafficLightIntersection if has_node("TrafficLightIntersection") else null
@onready var player: Player = $Player if has_node("Player") else null

var telemetry_label: Label = null
var recent_honk_log: String = "None"


func _ready() -> void:
	_create_telemetry_ui()
	EventBus.vehicle_horn_honked.connect(_on_vehicle_horn)
	EventBus.traffic_jam_detected.connect(_on_traffic_jam)


func _create_telemetry_ui() -> void:
	var canvas = CanvasLayer.new()
	canvas.name = "TelemetryCanvas"
	add_child(canvas)
	
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.position = Vector2(24, 24)
	canvas.add_child(panel)
	
	telemetry_label = Label.new()
	telemetry_label.text = "CITY SIMULATION: INITIALIZING..."
	telemetry_label.add_theme_font_size_override("font_size", 13)
	telemetry_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95, 1))
	panel.add_child(telemetry_label)


func _process(_delta: float) -> void:
	if not telemetry_label:
		return
	
	var ped_count := pedestrian_system.active_pedestrians.size() if pedestrian_system else 0
	var ped_dens := pedestrian_system.pedestrian_density if pedestrian_system else 0.0
	
	var traf_count := traffic_system.active_vehicles.size() if traffic_system else 0
	var traf_dens := traffic_system.traffic_density if traffic_system else 0.0
	
	var phase_str := "N/A"
	if traffic_light:
		phase_str = TrafficLightController.TrafficPhase.keys()[traffic_light.current_phase]
	
	var info := "=== DTA LIVING BANGLADESH CITY SIMULATION ===\n"
	info += "Pedestrians: %d active | Density: %3.0f%%\n" % [ped_count, ped_dens * 100.0]
	info += "Traffic Flow: %d vehicles | Density: %3.0f%%\n" % [traf_count, traf_dens * 100.0]
	info += "Intersection Phase: %s (%2.1fs remain)\n" % [phase_str, traffic_light.phase_timer if traffic_light else 0.0]
	info += "Recent Traffic Honk: %s\n" % recent_honk_log
	
	info += "\n[ SIMULATION CONTROLS ]\n"
	info += "  [1 / 2] Increase / Decrease Pedestrian Crowd Density\n"
	info += "  [3 / 4] Increase / Decrease Mixed Traffic Density\n"
	info += "  [T] Force Cycle Traffic Light Phase\n"
	info += "  [P] Trigger Panic Signal (Test Crowd Flee Reaction)\n"
	info += "  [W, A, S, D, E] Player Movement & Vehicle Boarding\n"
	
	telemetry_label.text = info


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				if pedestrian_system:
					pedestrian_system.pedestrian_density = clampf(pedestrian_system.pedestrian_density + 0.15, 0.1, 1.0)
			KEY_2:
				if pedestrian_system:
					pedestrian_system.pedestrian_density = clampf(pedestrian_system.pedestrian_density - 0.15, 0.1, 1.0)
			KEY_3:
				if traffic_system:
					traffic_system.traffic_density = clampf(traffic_system.traffic_density + 0.15, 0.1, 1.0)
			KEY_4:
				if traffic_system:
					traffic_system.traffic_density = clampf(traffic_system.traffic_density - 0.15, 0.1, 1.0)
			KEY_T:
				if traffic_light:
					traffic_light._advance_phase()
			KEY_P:
				if player:
					EventBus.pedestrian_panicked.emit(player.global_position)


func _on_vehicle_horn(v: Node) -> void:
	if is_instance_valid(v) and v.get("vehicle_name"):
		recent_honk_log = str(v.vehicle_name) + " honked!"


func _on_traffic_jam(loc: String) -> void:
	recent_honk_log = "Congestion detected at " + loc
