# ==============================================================================
# PADMA UTILITY PICKUP TRUCK (VEHICLE SYSTEM)
# ==============================================================================
class_name PickupTruckVehicle
extends BaseVehicle3D

func _ready() -> void:
	vehicle_name = "Padma Utility Pickup"
	max_engine_force = 480.0
	max_brake_force = 55.0
	base_max_speed_kmh = 160.0
	max_steer_angle_rad = deg_to_rad(33.0)
	high_speed_steer_angle_rad = deg_to_rad(12.0)
	steer_speed = 6.0
	max_health = 140.0
	super._ready()
