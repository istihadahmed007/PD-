# ==============================================================================
# CRIME DETECTOR (POLICE SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Detects and classifies player crimes (Theft, Brandishing, Gunfire,
#          Assault, Hit & Run, Trespassing). Determines direct police observation
#          versus civilian witness reporting with 999 dispatch delay.
# ==============================================================================
class_name CrimeDetector
extends Node

enum CrimeType {
	BRANDISHING_WEAPON,
	FIREARM_DISCHARGE,
	ASSAULT_CIVILIAN,
	VEHICLE_THEFT,
	VEHICLE_HIT_AND_RUN,
	ASSAULT_POLICE,
	POLICE_FACILITY_TRESPASS
}

const CRIME_SEVERITY := {
	"BRANDISHING_WEAPON": 1,
	"FIREARM_DISCHARGE": 2,
	"ASSAULT_CIVILIAN": 1,
	"VEHICLE_THEFT": 2,
	"VEHICLE_HIT_AND_RUN": 3,
	"ASSAULT_POLICE": 3,
	"POLICE_FACILITY_TRESPASS": 2
}

@export var brandish_check_interval: float = 1.0
var _brandish_timer: float = 0.0


func _ready() -> void:
	# Listen to global events
	EventBus.vehicle_entered.connect(_on_vehicle_entered)


func _physics_process(delta: float) -> void:
	_brandish_timer -= delta
	if _brandish_timer <= 0.0:
		_brandish_timer = brandish_check_interval
		_check_weapon_brandishing()


func _check_weapon_brandishing() -> void:
	if not is_instance_valid(GameManager.active_player):
		return
	
	# Only brandishing if aiming weapon in public
	if Input.is_action_pressed("aim"):
		var player_pos = GameManager.active_player.global_position
		register_crime("BRANDISHING_WEAPON", player_pos)


func register_crime(crime_name: String, location: Vector3) -> void:
	var severity: int = CRIME_SEVERITY.get(crime_name, 1)
	
	# 1. Check if any active Police Officer has direct Line of Sight
	var police_saw_it := _check_direct_police_observation(location)
	
	if police_saw_it:
		# Immediate pursuit! No witness delay needed
		EventBus.crime_committed.emit(crime_name, severity, location)
		return
	
	# 2. Check if any Civilian NPC witnesses the crime
	var witnesses := _get_nearby_witnesses(location)
	var any_witness_started := false
	
	for witness in witnesses:
		if witness.observe_crime(crime_name, severity, location):
			any_witness_started = true
	
	# 3. If violent crime (e.g. Gunfire / Hit and run) with no direct witness in immediate cone,
	# sound still travels and reports after slight delay
	if not any_witness_started and (crime_name == "FIREARM_DISCHARGE" or crime_name == "VEHICLE_HIT_AND_RUN"):
		# Gunfire in an urban city gets reported via sound
		get_tree().create_timer(randf_range(2.0, 4.0)).timeout.connect(func():
			EventBus.crime_committed.emit(crime_name, severity, location)
		)


func _check_direct_police_observation(location: Vector3) -> bool:
	var police_officers = get_tree().get_nodes_in_group("police_officers")
	for officer in police_officers:
		if is_instance_valid(officer) and officer.has_node("VisionSensor"):
			var sensor: PoliceVisionSensor = officer.get_node("VisionSensor") as PoliceVisionSensor
			if sensor and sensor.can_see_player:
				return true
	
	var police_vehicles = get_tree().get_nodes_in_group("police_vehicles")
	for p_veh in police_vehicles:
		if is_instance_valid(p_veh) and p_veh.has_node("VisionSensor"):
			var sensor: PoliceVisionSensor = p_veh.get_node("VisionSensor") as PoliceVisionSensor
			if sensor and sensor.can_see_player:
				return true
	
	return false


func _get_nearby_witnesses(location: Vector3) -> Array[WitnessComponent]:
	var result: Array[WitnessComponent] = []
	var witnesses = get_tree().get_nodes_in_group("witnesses")
	for w in witnesses:
		if is_instance_valid(w) and w is WitnessComponent:
			var dist = (w as WitnessComponent).global_position.distance_to(location)
			if dist <= 45.0:
				result.append(w as WitnessComponent)
	return result


func _on_vehicle_entered(vehicle: Node, _seat: String) -> void:
	# If player steals a vehicle that does not belong to them
	if is_instance_valid(vehicle) and not vehicle.get_meta("player_owned", false):
		register_crime("VEHICLE_THEFT", vehicle.global_position)
