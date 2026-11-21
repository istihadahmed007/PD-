# ==============================================================================
# ROAD NETWORK 3D (TRAFFIC SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Waypoint graph & lane routing coordinate manager for open-world traffic.
# ==============================================================================
class_name RoadNetwork3D
extends Node3D

# Waypoint Structure: {id: int, pos: Vector3, next: Array[int], speed_limit: float, lane: int, is_stop: bool}
var waypoints: Dictionary = {}
var active_stops: Dictionary = {} # wp_id -> bool


func _ready() -> void:
	_build_district_01_grid()


func _build_district_01_grid() -> void:
	waypoints.clear()
	var wp_id := 0
	
	# --------------------------------------------------------------------------
	# LANE 1: MAIN ROAD SOUTHBOUND (X = -2.2m, Z: -180m -> +180m)
	# --------------------------------------------------------------------------
	var sb_points = [
		Vector3(-2.2, 0.1, -180.0),
		Vector3(-2.2, 0.1, -120.0),
		Vector3(-2.2, 0.1, -70.0),
		Vector3(-2.2, 0.1, -45.0), # North Stop Line (Intersection)
		Vector3(-2.2, 0.1, -38.0), # Central Intersection
		Vector3(-2.2, 0.1, -10.0),
		Vector3(-2.2, 0.1, 25.0),  # Bridge North Approach
		Vector3(-2.2, 0.1, 50.0),  # Bridge Midpoint
		Vector3(-2.2, 0.1, 75.0),  # Bridge South Exit
		Vector3(-2.2, 0.1, 120.0),
		Vector3(-2.2, 0.1, 180.0)
	]
	var sb_start = wp_id
	for i in range(sb_points.size()):
		var next_ids: Array[int] = []
		if i < sb_points.size() - 1:
			next_ids.append(wp_id + 1)
		else:
			# Loop back for endless traffic flow
			next_ids.append(sb_start)
		
		waypoints[wp_id] = {
			"pos": sb_points[i],
			"next": next_ids,
			"speed_limit": 55.0,
			"lane": 1,
			"is_stop": (i == 3) # Southbound stop line before intersection
		}
		wp_id += 1
	
	# --------------------------------------------------------------------------
	# LANE 2: MAIN ROAD NORTHBOUND (X = +2.2m, Z: +180m -> -180m)
	# --------------------------------------------------------------------------
	var nb_points = [
		Vector3(2.2, 0.1, 180.0),
		Vector3(2.2, 0.1, 120.0),
		Vector3(2.2, 0.1, 75.0),
		Vector3(2.2, 0.1, 50.0),  # Bridge
		Vector3(2.2, 0.1, 25.0),
		Vector3(2.2, 0.1, -10.0),
		Vector3(2.2, 0.1, -30.0), # South Stop Line (Intersection)
		Vector3(2.2, 0.1, -38.0), # Central Intersection
		Vector3(2.2, 0.1, -70.0),
		Vector3(2.2, 0.1, -120.0),
		Vector3(2.2, 0.1, -180.0)
	]
	var nb_start = wp_id
	for i in range(nb_points.size()):
		var next_ids: Array[int] = []
		if i < nb_points.size() - 1:
			next_ids.append(wp_id + 1)
		else:
			next_ids.append(nb_start)
		
		waypoints[wp_id] = {
			"pos": nb_points[i],
			"next": next_ids,
			"speed_limit": 55.0,
			"lane": 2,
			"is_stop": (i == 6) # Northbound stop line
		}
		wp_id += 1
	
	# --------------------------------------------------------------------------
	# LANE 3: BAZAAR AVENUE EASTBOUND (Z = -39.5m, X: -120m -> +100m)
	# --------------------------------------------------------------------------
	var eb_points = [
		Vector3(-120.0, 0.1, -39.5),
		Vector3(-75.0, 0.1, -39.5),
		Vector3(-35.0, 0.1, -39.5),
		Vector3(-8.0, 0.1, -39.5), # West Stop Line
		Vector3(0.0, 0.1, -39.5),  # Intersection Center
		Vector3(35.0, 0.1, -39.5),
		Vector3(75.0, 0.1, -39.5),
		Vector3(100.0, 0.1, -39.5)
	]
	var eb_start = wp_id
	for i in range(eb_points.size()):
		var next_ids: Array[int] = []
		if i < eb_points.size() - 1:
			next_ids.append(wp_id + 1)
		else:
			next_ids.append(eb_start)
		
		waypoints[wp_id] = {
			"pos": eb_points[i],
			"next": next_ids,
			"speed_limit": 40.0,
			"lane": 3,
			"is_stop": (i == 3) # Eastbound stop line
		}
		wp_id += 1
	
	# --------------------------------------------------------------------------
	# LANE 4: BAZAAR AVENUE WESTBOUND (Z = -36.5m, X: +100m -> -120m)
	# --------------------------------------------------------------------------
	var wb_points = [
		Vector3(100.0, 0.1, -36.5),
		Vector3(75.0, 0.1, -36.5),
		Vector3(35.0, 0.1, -36.5),
		Vector3(8.0, 0.1, -36.5), # East Stop Line
		Vector3(0.0, 0.1, -36.5), # Intersection Center
		Vector3(-35.0, 0.1, -36.5),
		Vector3(-75.0, 0.1, -36.5),
		Vector3(-120.0, 0.1, -36.5)
	]
	var wb_start = wp_id
	for i in range(wb_points.size()):
		var next_ids: Array[int] = []
		if i < wb_points.size() - 1:
			next_ids.append(wp_id + 1)
		else:
			next_ids.append(wb_start)
		
		waypoints[wp_id] = {
			"pos": wb_points[i],
			"next": next_ids,
			"speed_limit": 40.0,
			"lane": 4,
			"is_stop": (i == 3) # Westbound stop line
		}
		wp_id += 1


func get_nearest_waypoint(pos: Vector3, preferred_lane: int = 0) -> int:
	var closest_id := 0
	var min_dist := INF
	
	for id in waypoints:
		var wp = waypoints[id]
		if preferred_lane > 0 and wp["lane"] != preferred_lane:
			continue
		var dist = pos.distance_to(wp["pos"])
		if dist < min_dist:
			min_dist = dist
			closest_id = id
	return closest_id


func get_waypoint_pos(id: int) -> Vector3:
	if id in waypoints:
		return waypoints[id]["pos"]
	return Vector3.ZERO


func get_next_waypoint(current_id: int) -> int:
	if current_id in waypoints:
		var nexts: Array = waypoints[current_id]["next"]
		if not nexts.is_empty():
			return nexts[randi() % nexts.size()]
	return 0


func is_stop_active(wp_id: int) -> bool:
	return active_stops.get(wp_id, false)


func set_stop_state(wp_id: int, stop_active: bool) -> void:
	active_stops[wp_id] = stop_active
