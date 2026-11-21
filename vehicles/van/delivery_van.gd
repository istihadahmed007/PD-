# ==============================================================================
# CHANDER GARI DELIVERY VAN (VEHICLE SYSTEM)
# ==============================================================================
class_name DeliveryVanVehicle
extends BaseVehicle3D

func _ready() -> void:
	vehicle_name = "Chander Gari Delivery Van"
	max_engine_force = 450.0
	max_brake_force = 52.0
	base_max_speed_kmh = 145.0
	max_steer_angle_rad = deg_to_rad(32.0)
	high_speed_steer_angle_rad = deg_to_rad(11.0)
	steer_speed = 5.8
	max_health = 130.0
	super._ready()
