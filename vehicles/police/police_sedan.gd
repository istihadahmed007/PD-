# ==============================================================================
# POLICE PATROL SEDAN (VEHICLE SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Dhaka Metropolitan Police (DMP) Patrol Cruiser based on BaseVehicle3D.
#          Features interceptor engine tuning, siren audio, flashing lightbar,
#          and integrated PoliceVehicleAgent AI.
# ==============================================================================
class_name PolicePatrolSedan
extends BaseVehicle3D


func _init() -> void:
	vehicle_name = "DMP Police Patrol Cruiser"
	max_engine_force = 480.0 # High-speed police interceptor
	max_brake_force = 55.0
	base_max_speed_kmh = 175.0
	max_health = 140.0 # Reinforced police chassis


func _ready() -> void:
	super._ready()
	add_to_group("police_vehicles")
