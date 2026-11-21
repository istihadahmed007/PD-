# ==============================================================================
# MEGHNA EXPLORER 4x4 SUV (VEHICLE SYSTEM)
# ==============================================================================
class_name SuvVehicle
extends BaseVehicle3D

func _ready() -> void:
	vehicle_name = "Meghna Explorer 4x4 SUV"
	max_engine_force = 520.0
	max_brake_force = 58.0
	base_max_speed_kmh = 175.0
	max_steer_angle_rad = deg_to_rad(32.0)
	high_speed_steer_angle_rad = deg_to_rad(11.0)
	steer_speed = 5.5
	max_health = 160.0
	super._ready()
