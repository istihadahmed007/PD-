# ==============================================================================
# TACTICAL MINIMAP & RADAR HUD COMPONENT
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Real-time 360-degree radar showing player heading, mission waypoints,
#          police pursuit/search perimeters, nearby vehicles, and city POIs.
# ==============================================================================
class_name MiniMap
extends Control

@export var radar_radius: float = 75.0 # pixels on screen
@export var world_range: float = 120.0 # world meters covered by radar
@export var is_circular: bool = true

@onready var radar_canvas: Control = $RadarCanvas
@onready var cardinal_label: Label = $CardinalLabel
@onready var zone_label: Label = $ZoneLabel

var _player_node: Node3D = null
var _mission_target: Vector3 = Vector3.ZERO
var _has_mission_target: bool = false
var _police_search_center: Vector3 = Vector3.ZERO
var _police_search_radius: float = 0.0
var _is_police_searching: bool = false


func _ready() -> void:
	EventBus.mission_checkpoint_reached.connect(_on_waypoint_updated)
	EventBus.mission_objective_updated.connect(func(_s, _d): _check_mission_beacon())
	EventBus.mission_started.connect(func(_id, _t): _check_mission_beacon())
	EventBus.mission_completed.connect(func(_id, _r): _has_mission_target = false)
	EventBus.police_search_area_updated.connect(_on_police_search_updated)
	EventBus.police_pursuit_evaded.connect(func(): _is_police_searching = false)
	
	if radar_canvas:
		radar_canvas.draw.connect(_on_draw_radar)


func _process(_delta: float) -> void:
	if not visible:
		return
		
	if not _player_node:
		_player_node = GameManager.active_player
		
	if radar_canvas:
		radar_canvas.queue_redraw()
		
	if _player_node and cardinal_label:
		var heading = -_player_node.rotation.y
		var deg = fposmod(rad_to_deg(heading), 360.0)
		var card = "N"
		if deg >= 337.5 or deg < 22.5: card = "N"
		elif deg >= 22.5 and deg < 67.5: card = "NE"
		elif deg >= 67.5 and deg < 112.5: card = "E"
		elif deg >= 112.5 and deg < 157.5: card = "SE"
		elif deg >= 157.5 and deg < 202.5: card = "S"
		elif deg >= 202.5 and deg < 247.5: card = "SW"
		elif deg >= 247.5 and deg < 292.5: card = "W"
		elif deg >= 292.5 and deg < 337.5: card = "NW"
		cardinal_label.text = "%s  %d°" % [card, int(deg)]


func _check_mission_beacon() -> void:
	var root = get_tree().root
	var beacon = root.find_child("MissionWaypointBeacon", true, false)
	if beacon and beacon.is_inside_tree() and beacon.visible:
		_mission_target = beacon.global_position
		_has_mission_target = true
	else:
		_has_mission_target = false


func _on_waypoint_updated(_idx: int, loc: Vector3) -> void:
	_mission_target = loc
	_has_mission_target = true


func _on_police_search_updated(center: Vector3, radius: float, is_active: bool) -> void:
	_police_search_center = center
	_police_search_radius = radius
	_is_police_searching = is_active


func _on_draw_radar() -> void:
	if not _player_node:
		return
		
	var center = Vector2(radar_radius, radar_radius)
	var player_pos = _player_node.global_position
	var player_rot = _player_node.rotation.y
	
	# 1. Background radar disc
	radar_canvas.draw_circle(center, radar_radius, Color(0.08, 0.10, 0.14, 0.88))
	radar_canvas.draw_arc(center, radar_radius, 0.0, TAU, 32, Color(0.3, 0.7, 0.9, 0.8), 2.0)
	radar_canvas.draw_arc(center, radar_radius * 0.5, 0.0, TAU, 24, Color(0.3, 0.5, 0.7, 0.25), 1.0)
	
	# Crosshairs
	radar_canvas.draw_line(center - Vector2(radar_radius * 0.85, 0), center + Vector2(radar_radius * 0.85, 0), Color(0.4, 0.6, 0.8, 0.2), 1.0)
	radar_canvas.draw_line(center - Vector2(0, radar_radius * 0.85), center + Vector2(0, radar_radius * 0.85), Color(0.4, 0.6, 0.8, 0.2), 1.0)
	
	# 2. Draw Police Search Area
	if _is_police_searching:
		var delta_pos = _police_search_center - player_pos
		var search_radar_pos = _world_to_radar_coord(delta_pos, player_rot, center)
		var radar_search_r = (_police_search_radius / world_range) * radar_radius
		radar_canvas.draw_circle(search_radar_pos, minf(radar_search_r, radar_radius * 1.5), Color(0.9, 0.15, 0.15, 0.22))
		radar_canvas.draw_arc(search_radar_pos, minf(radar_search_r, radar_radius * 1.5), 0.0, TAU, 24, Color(1.0, 0.2, 0.2, 0.85), 1.5)
	
	# 3. Draw Nearby Vehicles
	var vehicles = get_tree().get_nodes_in_group("vehicles")
	for v in vehicles:
		if v == GameManager.active_vehicle:
			continue
		if v is Node3D:
			var d_pos = v.global_position - player_pos
			if d_pos.length() <= world_range:
				var v_radar_pos = _world_to_radar_coord(d_pos, player_rot, center)
				if v_radar_pos.distance_to(center) <= radar_radius - 2.0:
					radar_canvas.draw_circle(v_radar_pos, 2.5, Color(0.4, 0.8, 1.0, 0.9))
					
	# 4. Draw Police Officers
	var officers = get_tree().get_nodes_in_group("police_officers")
	for off in officers:
		if off is Node3D:
			var d_pos = off.global_position - player_pos
			if d_pos.length() <= world_range:
				var p_radar_pos = _world_to_radar_coord(d_pos, player_rot, center)
				if p_radar_pos.distance_to(center) <= radar_radius - 2.0:
					radar_canvas.draw_circle(p_radar_pos, 3.5, Color(1.0, 0.2, 0.2, 0.95))
					
	# 5. Draw Mission Waypoint Beacon
	if _has_mission_target:
		var d_pos = _mission_target - player_pos
		var beacon_pos = _world_to_radar_coord(d_pos, player_rot, center)
		# Clamp to radar perimeter if beyond range
		var dist = beacon_pos.distance_to(center)
		if dist > radar_radius - 6.0:
			var dir = (beacon_pos - center).normalized()
			beacon_pos = center + dir * (radar_radius - 6.0)
		radar_canvas.draw_circle(beacon_pos, 5.0, Color(1.0, 0.85, 0.1, 1.0))
		radar_canvas.draw_arc(beacon_pos, 6.5, 0.0, TAU, 12, Color(1.0, 0.95, 0.4, 0.9), 1.5)
		
	# 6. Player icon in center (triangle arrow pointing UP)
	var arrow_points: PackedVector2Array = [
		center + Vector2(0, -6.5),
		center + Vector2(4.5, 5.0),
		center + Vector2(0, 3.0),
		center + Vector2(-4.5, 5.0)
	]
	radar_canvas.draw_colored_polygon(arrow_points, Color(1.0, 1.0, 1.0, 1.0))
	radar_canvas.draw_polyline(arrow_points, Color(0.1, 0.1, 0.1, 0.9), 1.2)


func _world_to_radar_coord(world_offset: Vector3, player_rot_y: float, center: Vector2) -> Vector2:
	# Rotate world offset by player heading so radar is oriented forward
	var rotated_x = world_offset.x * cos(player_rot_y) - world_offset.z * sin(player_rot_y)
	var rotated_z = world_offset.x * sin(player_rot_y) + world_offset.z * cos(player_rot_y)
	
	var scale_factor = radar_radius / world_range
	var radar_x = center.x + (rotated_x * scale_factor)
	var radar_y = center.y + (rotated_z * scale_factor)
	return Vector2(radar_x, radar_y)
