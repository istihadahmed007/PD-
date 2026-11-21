# ==============================================================================
# BIKROM 150R COMMUTER MOTORCYCLE (VEHICLE SYSTEM)
# ==============================================================================
class_name MotorcycleVehicle
extends BaseVehicle3D

@export var max_lean_deg: float = 24.0

func _ready() -> void:
	vehicle_name = "Bikrom 150R Motorcycle"
	max_engine_force = 185.0
	max_brake_force = 32.0
	base_max_speed_kmh = 138.0
	max_steer_angle_rad = deg_to_rad(36.0)
	high_speed_steer_angle_rad = deg_to_rad(14.0)
	steer_speed = 7.5
	max_health = 55.0
	super._ready()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	# Dynamic motorcycle roll / lean into turns
	if is_driven and has_node("VisualModel"):
		var speed_kmh = linear_velocity.length() * 3.6
		var target_lean = -steering * clampf(speed_kmh / 45.0, 0.0, 1.0) * deg_to_rad(max_lean_deg)
		$VisualModel.rotation.z = lerp_angle($VisualModel.rotation.z, target_lean, 12.0 * delta)
