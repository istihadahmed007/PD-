# ==============================================================================
# VEHICLE PHYSICS TEST CONTROLLER (TEST SUITE)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Comprehensive diagnostic harness for vehicle acceleration, braking,
#          suspension stability on bumps/slopes, gear shifts, damage, and camera.
# ==============================================================================
extends Node3D

@onready var sedan: BaseVehicle3D = $Sedan if has_node("Sedan") else null
@onready var player: Player = $Player if has_node("Player") else null

# Telemetry UI
var telemetry_label: Label = null


func _ready() -> void:
	_create_telemetry_ui()
	
	# Give starting money for testing
	GameManager.wallet_bdt = 1500


func _create_telemetry_ui() -> void:
	var canvas = CanvasLayer.new()
	canvas.name = "TelemetryCanvas"
	add_child(canvas)
	
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.position = Vector2(24, 24)
	canvas.add_child(panel)
	
	telemetry_label = Label.new()
	telemetry_label.text = "VEHICLE DIAGNOSTICS: INITIALIZING..."
	telemetry_label.add_theme_font_size_override("font_size", 14)
	telemetry_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95, 1))
	panel.add_child(telemetry_label)


func _process(_delta: float) -> void:
	if not telemetry_label:
		return
	
	var info := "=== DTA VEHICLE PHYSICS DIAGNOSTICS ===\n"
	if sedan:
		var speed_kmh := sedan.linear_velocity.length() * 3.6
		var driven_str := "ACTIVE (Player Driving)" if sedan.is_driven else "PARKED (Walk near & Press E)"
		info += "Status: " + driven_str + "\n"
		info += "Vehicle: " + sedan.vehicle_name + "\n"
		info += "Speed: %5.1f KM/H | RPM: %5.0f | Gear: %s\n" % [speed_kmh, sedan.current_rpm, sedan._get_gear_display_name()]
		info += "Steering: %4.1f deg | Health: %4.0f / %4.0f\n" % [rad_to_deg(sedan.steering), sedan.current_health, sedan.max_health]
		info += "Headlights: %s\n" % ["ON" if sedan.headlights_active else "OFF"]
		
		# Wheels suspension telemetry
		info += "Suspension State:\n"
		for idx in range(sedan.all_wheels.size()):
			var w = sedan.all_wheels[idx]
			var in_contact = "FLOOR" if w.is_in_contact() else "AIR"
			info += "  - Wheel %d: %s | Skidding: %s\n" % [idx + 1, in_contact, "YES" if w.get_skidinfo() < 0.5 else "NO"]
	
	info += "\n[ CONTROLS ]\n"
	info += "  [W] Throttle / Accelerate\n"
	info += "  [S] Brake / Reverse\n"
	info += "  [A / D] Steer Left / Right (Speed-Sensitive)\n"
	info += "  [SPACE] Handbrake Drift\n"
	info += "  [H] Vehicle Horn\n"
	info += "  [L] Toggle Headlights\n"
	info += "  [V] Cycle Camera View (Far -> Close -> Hood)\n"
	info += "  [B] Look-Behind Mirror\n"
	info += "  [E] Enter / Exit Vehicle (Safe Raycast Spawn)\n"
	info += "  [R] Reset Sedan Position\n"
	
	telemetry_label.text = info


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R and sedan:
			# Reset sedan to start line
			sedan.global_position = Vector3(0, 0.8, -15)
			sedan.global_rotation = Vector3.ZERO
			sedan.linear_velocity = Vector3.ZERO
			sedan.angular_velocity = Vector3.ZERO
			sedan.current_health = sedan.max_health
			if sedan.smoke_particles:
				sedan.smoke_particles.emitting = false
			if sedan.fire_particles:
				sedan.fire_particles.emitting = false
