# ==============================================================================
# TRAFFIC SIMULATION SYSTEM (TRAFFIC SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Autonomous mixed-traffic coordinator managing traffic density,
#          diverse vehicle spawning (Sedans, CNGs, Buses, Bikes, Pickups, Vans, Rickshaws),
#          streaming rings, and congestion tracking.
# ==============================================================================
class_name TrafficSystem
extends Node3D

@export var traffic_density: float = 0.70 # 0.0 = empty, 1.0 = Dhaka gridlock
@export var max_traffic_vehicles: int = 14
@export var spawn_radius_min: float = 30.0
@export var spawn_radius_max: float = 75.0
@export var despawn_radius: float = 95.0

@export var road_network: RoadNetwork3D = null

const VEHICLE_SCENES := {
	"sedan": preload("res://vehicles/sedan/sedan.tscn"),
	"cng": preload("res://vehicles/cng/cng_autorickshaw.tscn"),
	"bus": preload("res://vehicles/bus/local_bus.tscn"),
	"suv": preload("res://vehicles/suv/suv.tscn"),
	"bike": preload("res://vehicles/motorcycle/motorcycle.tscn"),
	"pickup": preload("res://vehicles/pickup/pickup_truck.tscn"),
	"van": preload("res://vehicles/van/delivery_van.tscn"),
	"rickshaw": preload("res://vehicles/rickshaw/rickshaw.tscn")
}

var active_vehicles: Array[Node] = []
var player_ref: Node3D = null
var spawn_timer: float = 0.0


func _ready() -> void:
	if not road_network:
		road_network = get_tree().get_first_node_in_group("road_network")


func _process(delta: float) -> void:
	if not player_ref and GameManager.active_player:
		player_ref = GameManager.active_player
	
	if not player_ref or not road_network:
		return
	
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_timer = randf_range(2.0, 4.0)
		_manage_traffic_population()


func _manage_traffic_population() -> void:
	var target_count = int(max_traffic_vehicles * traffic_density)
	
	# Despawn distant traffic
	var i = active_vehicles.size() - 1
	while i >= 0:
		var v = active_vehicles[i]
		if not is_instance_valid(v):
			active_vehicles.remove_at(i)
		else:
			# Do not despawn if player is currently driving it!
			if v.get("is_driven") == true:
				i -= 1
				continue
			
			var dist = v.global_position.distance_to(player_ref.global_position)
			if dist > despawn_radius:
				v.queue_free()
				active_vehicles.remove_at(i)
		i -= 1
	
	# Spawn new vehicle if under target count
	if active_vehicles.size() < target_count:
		_spawn_traffic_vehicle()


func _spawn_traffic_vehicle() -> void:
	if road_network.waypoints.is_empty():
		return
	
	# Pick random lane (1 = Southbound, 2 = Northbound, 3 = Eastbound, 4 = Westbound)
	var lane_id = randi_range(1, 4)
	
	# Find a waypoint in this lane within spawn distance ring
	var candidate_ids: Array[int] = []
	for id in road_network.waypoints:
		var wp = road_network.waypoints[id]
		if wp["lane"] == lane_id:
			var dist = wp["pos"].distance_to(player_ref.global_position)
			if dist >= spawn_radius_min and dist <= spawn_radius_max:
				candidate_ids.append(id)
	
	if candidate_ids.is_empty():
		return
	
	var chosen_wp_id = candidate_ids[randi() % candidate_ids.size()]
	var spawn_pos = road_network.get_waypoint_pos(chosen_wp_id)
	
	# Select vehicle type reflecting authentic Dhaka road mix:
	# 35% CNG, 25% Sedan, 15% Bike, 10% Bus, 10% Rickshaw, 5% Pickup/SUV/Van
	var roll = randf()
	var vehicle_key := "cng"
	if roll < 0.35:
		vehicle_key = "cng"
	elif roll < 0.60:
		vehicle_key = "sedan"
	elif roll < 0.75:
		vehicle_key = "bike"
	elif roll < 0.85:
		vehicle_key = "bus"
	elif roll < 0.93:
		vehicle_key = "rickshaw"
	else:
		var heavy_pool = ["suv", "pickup", "van"]
		vehicle_key = heavy_pool[randi() % heavy_pool.size()]
	
	var scene = VEHICLE_SCENES[vehicle_key]
	var v_instance: Node = scene.instantiate()
	v_instance.position = spawn_pos + Vector3(0, 0.4, 0)
	
	# Face next waypoint
	var next_wp_id = road_network.get_next_waypoint(chosen_wp_id)
	var next_pos = road_network.get_waypoint_pos(next_wp_id)
	var dir = (next_pos - spawn_pos).normalized()
	if dir.length() > 0.1:
		v_instance.look_at(v_instance.position + dir, Vector3.UP)
	
	# Attach AI driver agent if BaseVehicle3D
	if v_instance is BaseVehicle3D:
		var agent = TrafficVehicleAgent.new()
		agent.name = "TrafficAgent"
		agent.vehicle = v_instance
		agent.road_network = road_network
		agent.target_lane = lane_id
		agent.current_waypoint_id = chosen_wp_id
		agent.target_waypoint_id = next_wp_id
		v_instance.add_child(agent)
	
	add_child(v_instance)
	active_vehicles.append(v_instance)
