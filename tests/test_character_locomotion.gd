# ==============================================================================
# CHARACTER LOCOMOTION & CAMERA TEST SUITE
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Dedicated verification environment for player locomotion, stairs,
#          slopes, fall recovery, camera collision, and animation blending.
# ==============================================================================
extends Node3D

@onready var player: Player = %Player
@onready var state_label: Label = %DebugStateLabel
@onready var speed_label: Label = %DebugSpeedLabel
@onready var camera_label: Label = %DebugCameraLabel
@onready var slope_label: Label = %DebugSlopeLabel
@onready var stamina_label: Label = %DebugStaminaLabel


func _ready() -> void:
	# Guide test objectives via MissionSystem
	var mission := MissionResource.new()
	mission.title = "Locomotion & Camera Verification"
	mission.objectives = [
		"1. Flat Ground: Test Walk (gentle stick/WASD), Jog (WASD), Sprint (Shift)",
		"2. Stairs Course: Climb 0.15m, 0.22m, and 0.30m risers without snagging",
		"3. Slope Course: Climb 15°, 30°, and 45° ramps; test idle slope-holding",
		"4. High Drop Ledge: Jump from 5m ledge to verify Hard Landing impact recovery",
		"5. Narrow Alley: Walk through 1.8m corridor to test camera obstruction clearance",
		"6. Over-Shoulder Aim: Hold Right Click to verify smooth camera transition and aiming FOV"
	]
	
	await get_tree().create_timer(0.4).timeout
	var ms := MissionSystem.new()
	add_child(ms)
	ms.start_mission(mission)


func _process(_delta: float) -> void:
	if not player:
		return
	
	# Horizontal and vertical velocity readout
	var horiz_speed = Vector3(player.velocity.x, 0, player.velocity.z).length()
	var vert_speed = player.velocity.y
	
	if speed_label:
		speed_label.text = "Speed: %.2f m/s (%.1f km/h) | Vert: %.2f m/s" % [
			horiz_speed,
			horiz_speed * 3.6,
			vert_speed
		]
	
	# Locomotion state determination
	var state_name = "IDLE"
	if player.is_hard_landing_recovering:
		state_name = "HARD LANDING (Impact Recovery)"
	elif not player.is_on_floor():
		state_name = "FALLING" if vert_speed < 0 else "JUMPING"
	elif player.is_sprinting:
		state_name = "SPRINTING (12.5 m/s)"
	elif horiz_speed > 3.6:
		state_name = "JOGGING (7.0 m/s)"
	elif horiz_speed > 0.3:
		state_name = "WALKING (3.2 m/s)"
	
	if state_label:
		state_label.text = "Locomotion State: " + state_name
	
	if stamina_label:
		stamina_label.text = "Stamina: %d / %d" % [int(player.current_stamina), int(player.max_stamina)]
	
	if slope_label:
		var floor_normal = player.get_floor_normal()
		var slope_angle_deg = rad_to_deg(floor_normal.angle_to(Vector3.UP))
		slope_label.text = "Floor Angle: %.1f° | On Floor: %s" % [slope_angle_deg, str(player.is_on_floor())]
	
	if camera_label and player.has_node("CameraController"):
		var cam_ctrl = player.get_node("CameraController")
		var is_aiming = Input.is_action_pressed("aim")
		var fov = cam_ctrl.get_node("PlayerCamera").fov if cam_ctrl.has_node("PlayerCamera") else 70.0
		camera_label.text = "Camera: %s | FOV: %.1f°" % [
			"OVER-SHOULDER AIM" if is_aiming else "THIRD-PERSON ORBIT",
			fov
		]
