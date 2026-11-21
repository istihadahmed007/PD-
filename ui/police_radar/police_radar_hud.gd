# ==============================================================================
# POLICE RADAR & WANTED HUD INTERFACE (UI SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Dynamic tactical wanted HUD featuring animated 5-star heat level,
#          status banners, evasion cooldown gauge, and real-time 360° radar
#          displaying police officers, cruisers, and search radius boundaries.
# ==============================================================================
class_name PoliceRadarHUD
extends Control

@export var radar_range_meters: float = 90.0
@export var radar_screen_radius: float = 75.0

# Colors
const COLOR_RADAR_BG := Color(0.06, 0.08, 0.12, 0.78)
const COLOR_RADAR_RING := Color(0.2, 0.45, 0.65, 0.4)
const COLOR_PLAYER := Color(0.2, 0.9, 0.4, 1.0)
const COLOR_COP_CAR := Color(0.15, 0.45, 1.0, 1.0)
const COLOR_COP_FOOT := Color(0.25, 0.65, 1.0, 1.0)
const COLOR_SEARCH_ZONE := Color(1.0, 0.75, 0.15, 0.45)
const COLOR_WITNESS := Color(1.0, 0.35, 0.2, 1.0)

var current_stars: int = 0
var is_pursuing: bool = false
var is_searching: bool = false
var search_center: Vector3 = Vector3.ZERO
var search_radius: float = 0.0

var flash_timer: float = 0.0
var flash_visible: bool = true
var status_text: String = "STATUS: PEACEFUL CITIZEN"
var status_color: Color = Color(0.6, 0.8, 0.6, 1.0)
var cooldown_ratio: float = 0.0

# UI Controls
@onready var panel_container: PanelContainer = $TopPanel
@onready var stars_label: Label = $TopPanel/VBox/StarsLabel
@onready var status_label: Label = $TopPanel/VBox/StatusLabel
@onready var cooldown_bar: ProgressBar = $TopPanel/VBox/CooldownBar
@onready var radar_control: Control = $RadarControl


func _ready() -> void:
	EventBus.wanted_level_changed.connect(_on_wanted_level_changed)
	EventBus.police_pursuit_started.connect(_on_pursuit_started)
	EventBus.police_pursuit_evaded.connect(_on_pursuit_evaded)
	EventBus.police_search_area_updated.connect(_on_search_area_updated)
	EventBus.witness_reported_crime.connect(_on_witness_reported)
	
	if radar_control:
		radar_control.draw.connect(func(): _draw_radar_content(radar_control))
	
	_on_wanted_level_changed(GameManager.wanted_stars)


func _process(delta: float) -> void:
	flash_timer += delta
	if flash_timer >= 0.25:
		flash_timer = 0.0
		flash_visible = not flash_visible
	
	_update_hud_display()
	if radar_control:
		radar_control.queue_redraw()


func _update_hud_display() -> void:
	if not stars_label or not status_label:
		return
	
	if current_stars <= 0:
		stars_label.text = ""
		status_label.text = "STATUS: NORMAL / NO ACTIVE WARRANTS"
		status_label.add_theme_color_override("font_color", Color(0.6, 0.8, 0.6, 0.9))
		if cooldown_bar:
			cooldown_bar.visible = false
		return
	
	# Build Stars Text (★ and ☆)
	var star_str := ""
	for i in range(5):
		if i < current_stars:
			star_str += "★ "
		else:
			star_str += "☆ "
	
	# If in searching/evasion mode, flash the stars!
	if is_searching and not flash_visible:
		stars_label.modulate = Color(1.0, 1.0, 1.0, 0.25)
	else:
		stars_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	stars_label.text = star_str.strip_edges()
	
	# Determine status message and color
	var police_system = get_tree().get_first_node_in_group("police_system") as PoliceSystem
	if police_system:
		if police_system.is_player_spotted:
			is_searching = false
			match current_stars:
				1:
					status_label.text = "★ PATROL INVESTIGATING (NON-LETHAL ARREST)"
					status_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
				2:
					status_label.text = "★★ DMP PURSUIT ACTIVE: CRUIRSER ENGAGED"
					status_label.add_theme_color_override("font_color", Color(1.0, 0.65, 0.1, 1.0))
				3:
					status_label.text = "★★★ ARMED ENGAGEMENT: LETHAL FORCE AUTHORIZED"
					status_label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.2, 1.0))
				4:
					status_label.text = "★★★★ CRT SWAT UNITS ACTIVE: ROADBLOCKS DEPLOYED"
					status_label.add_theme_color_override("font_color", Color(1.0, 0.15, 0.15, 1.0))
				5:
					status_label.text = "★★★★★ MAXIMUM TACTICAL LOCKDOWN: FULL MOBILIZATION"
					status_label.add_theme_color_override("font_color", Color(1.0, 0.05, 0.05, 1.0))
			if cooldown_bar:
				cooldown_bar.visible = false
		else:
			# Evading out of sight
			is_searching = true
			var remaining_time = maxf(0.0, police_system.required_evade_time - police_system.time_out_of_sight)
			status_label.text = "EVADING DMP PATROL: %2.1fs (LOS LOST)" % remaining_time
			status_label.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0, 1.0) if flash_visible else Color(1.0, 0.9, 0.2, 1.0))
			
			if cooldown_bar:
				cooldown_bar.visible = true
				cooldown_bar.max_value = police_system.required_evade_time
				cooldown_bar.value = police_system.time_out_of_sight


func _draw_radar_content(radar: Control) -> void:
	var center = Vector2(radar_screen_radius, radar_screen_radius)
	
	# 1. Background disc & concentric range rings
	radar.draw_circle(center, radar_screen_radius, COLOR_RADAR_BG)
	radar.draw_arc(center, radar_screen_radius, 0, TAU, 32, Color(0.3, 0.6, 0.9, 0.8), 2.0)
	radar.draw_arc(center, radar_screen_radius * 0.66, 0, TAU, 24, COLOR_RADAR_RING, 1.0)
	radar.draw_arc(center, radar_screen_radius * 0.33, 0, TAU, 24, COLOR_RADAR_RING, 1.0)
	
	# Crosshairs
	radar.draw_line(center - Vector2(radar_screen_radius, 0), center + Vector2(radar_screen_radius, 0), COLOR_RADAR_RING, 1.0)
	radar.draw_line(center - Vector2(0, radar_screen_radius), center + Vector2(0, radar_screen_radius), COLOR_RADAR_RING, 1.0)
	
	var player_node: Node3D = null
	if GameManager.current_state == GameManager.GameState.IN_VEHICLE and is_instance_valid(GameManager.active_vehicle):
		player_node = GameManager.active_vehicle as Node3D
	elif is_instance_valid(GameManager.active_player):
		player_node = GameManager.active_player as Node3D
	
	if not is_instance_valid(player_node):
		return
	
	var player_pos = player_node.global_position
	var player_heading = -player_node.global_transform.basis.z
	var player_angle = atan2(player_heading.x, player_heading.z)
	
	# 2. Draw Search Zone Area (if active)
	if is_searching and search_radius > 0.0:
		var rel_search = search_center - player_pos
		var search_radar_pos = _world_to_radar(rel_search, player_angle, center)
		var search_radar_radius = (search_radius / radar_range_meters) * radar_screen_radius
		
		# Draw pulsing search circle
		var pulse_color = COLOR_SEARCH_ZONE
		pulse_color.a = 0.25 + (0.2 if flash_visible else 0.0)
		radar.draw_circle(search_radar_pos, search_radar_radius, pulse_color)
		radar.draw_arc(search_radar_pos, search_radar_radius, 0, TAU, 24, Color(1.0, 0.8, 0.2, 0.8), 1.5)
	
	# 3. Draw Police Officers
	var officers = get_tree().get_nodes_in_group("police_officers")
	for officer in officers:
		if is_instance_valid(officer):
			var rel = officer.global_position - player_pos
			if rel.length() <= radar_range_meters:
				var r_pos = _world_to_radar(rel, player_angle, center)
				radar.draw_circle(r_pos, 3.5, COLOR_COP_FOOT)
	
	# 4. Draw Police Cruisers
	var cruisers = get_tree().get_nodes_in_group("police_vehicles")
	for cruiser in cruisers:
		if is_instance_valid(cruiser):
			var rel = cruiser.global_position - player_pos
			if rel.length() <= radar_range_meters:
				var r_pos = _world_to_radar(rel, player_angle, center)
				# Draw car diamond blip
				var points = PackedVector2Array([
					r_pos + Vector2(0, -5),
					r_pos + Vector2(4, 0),
					r_pos + Vector2(0, 5),
					r_pos + Vector2(-4, 0)
				])
				var car_color = Color(1.0, 0.2, 0.2, 1.0) if flash_visible else COLOR_COP_CAR
				radar.draw_colored_polygon(points, car_color)
	
	# 5. Draw Player Arrow at Center
	var arrow_pts = PackedVector2Array([
		center + Vector2(0, -6),
		center + Vector2(4, 5),
		center + Vector2(0, 3),
		center + Vector2(-4, 5)
	])
	radar.draw_colored_polygon(arrow_pts, COLOR_PLAYER)


func _world_to_radar(rel_world: Vector3, player_yaw: float, radar_center: Vector2) -> Vector2:
	# Rotate world relative vector so North on radar is player's forward view
	var rotated_x = rel_world.x * cos(player_yaw) - rel_world.z * sin(player_yaw)
	var rotated_z = rel_world.x * sin(player_yaw) + rel_world.z * cos(player_yaw)
	
	var scale = radar_screen_radius / radar_range_meters
	var screen_offset = Vector2(rotated_x, rotated_z) * scale
	
	# Clamp to radar edge
	if screen_offset.length() > radar_screen_radius:
		screen_offset = screen_offset.normalized() * (radar_screen_radius - 2.0)
	
	return radar_center + screen_offset


func _on_wanted_level_changed(stars: int) -> void:
	current_stars = stars
	visible = (current_stars > 0 or is_searching)
	if stars <= 0:
		is_pursuing = false
		is_searching = false


func _on_pursuit_started() -> void:
	is_pursuing = true
	is_searching = false
	visible = true


func _on_pursuit_evaded() -> void:
	is_pursuing = false
	is_searching = false
	_show_evaded_toast()


func _on_search_area_updated(center: Vector3, radius: float, is_active: bool) -> void:
	search_center = center
	search_radius = radius
	is_searching = is_active


func _on_witness_reported(witness_name: String, crime_type: String, _loc: Vector3) -> void:
	if status_label:
		status_label.text = "999 DISPATCH: %s reported %s!" % [witness_name, crime_type]


func _show_evaded_toast() -> void:
	if status_label:
		status_label.text = "✓ PURSUIT EVADED — HEAT CLEARED!"
		status_label.add_theme_color_override("font_color", Color(0.2, 0.95, 0.35, 1.0))
	get_tree().create_timer(3.0).timeout.connect(func():
		if current_stars <= 0:
			visible = false
	)
