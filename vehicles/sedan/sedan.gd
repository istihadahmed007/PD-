# ==============================================================================
# SHONAR TORON SEDAN (VEHICLE SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Private 4-door family sedan inspired by Toyota Allion / Premio.
# ==============================================================================
class_name SedanVehicle
extends BaseVehicle3D


func _ready() -> void:
	vehicle_name = "Shonar Toron Sedan"
	max_engine_force = 420.0
	max_brake_force = 50.0
	base_max_speed_kmh = 165.0
	max_steer_angle_rad = deg_to_rad(34.0)
	high_speed_steer_angle_rad = deg_to_rad(12.0)
	steer_speed = 6.5
	max_health = 100.0
	super._ready()
