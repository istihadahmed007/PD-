# ==============================================================================
# DHAKA CYCLE RICKSHAW (VEHICLE SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Authentic human-powered 3-wheel cycle rickshaw mechanics and bell.
# ==============================================================================
class_name RickshawVehicle
extends BaseVehicle

@onready var front_wheel: Node3D = $VisualModel/FrontWheel if has_node("VisualModel/FrontWheel") else null
@onready var bell_sound: AudioStreamPlayer3D = $BellSound if has_node("BellSound") else null


func _ready() -> void:
	vehicle_name = "Dhaka Cycle Rickshaw"
	max_speed_kmh = 24.0
	acceleration_rate = 6.5
	braking_rate = 12.0
	reverse_max_speed_kmh = 6.0
	steering_speed = 4.0
	max_steer_angle_rad = deg_to_rad(45.0) # Rickshaws have wide turning angles
	super._ready()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	# Visual steering of front fork/wheel
	if front_wheel:
		front_wheel.rotation.y = current_steer_angle


func honk_horn() -> void:
	if bell_sound:
		bell_sound.pitch_scale = randfn(1.1, 0.05)
		bell_sound.play()
	super.honk_horn()
