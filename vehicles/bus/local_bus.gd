# ==============================================================================
# DHAKA LOCAL BUS (VEHICLE SYSTEM)
# ==============================================================================
class_name LocalBusVehicle
extends BaseVehicle3D

func _ready() -> void:
	vehicle_name = "Dhaka City Local Bus"
	max_engine_force = 1250.0
	max_brake_force = 140.0
	base_max_speed_kmh = 95.0
	max_steer_angle_rad = deg_to_rad(28.0)
	high_speed_steer_angle_rad = deg_to_rad(9.0)
	steer_speed = 3.8
	max_health = 350.0
	super._ready()
