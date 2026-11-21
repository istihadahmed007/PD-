# ==============================================================================
# DHAKA GREEN CNG AUTO-RICKSHAW (VEHICLE SYSTEM)
# ==============================================================================
class_name CngAutoRickshawVehicle
extends BaseVehicle3D

func _ready() -> void:
	vehicle_name = "Dhaka Green CNG Auto-Rickshaw"
	max_engine_force = 220.0
	max_brake_force = 36.0
	base_max_speed_kmh = 75.0
	max_steer_angle_rad = deg_to_rad(42.0)
	high_speed_steer_angle_rad = deg_to_rad(18.0)
	steer_speed = 7.0
	max_health = 75.0
	super._ready()
