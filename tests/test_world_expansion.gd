# ==============================================================================
# TEST WORLD EXPANSION (PLAYABLE OPEN-WORLD HARNESS)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Diagnostic harness for Part 08 verifying:
#          - 7 distinct interconnected regions of Bangladesh
#          - 512m chunk-based background asset streaming
#          - Distance-based LOD transitions (LOD0, LOD1, LOD2)
#          - Highway connectivity (NH-1, NH-2, NH-3) and river waterways
#          - Regional biome environment & ambient audio transitions
#          - Interactive World Navigation Map with fast travel
# ==============================================================================
extends Node3D

@onready var player: Player = $Player if has_node("Player") else null
@onready var world_system: WorldSystem = $WorldSystem if has_node("WorldSystem") else null
@onready var world_map_ui: WorldMapUI = $WorldMapUI if has_node("WorldMapUI") else null
@onready var test_sedan: BaseVehicle3D = $Sedan if has_node("Sedan") else null

var telemetry_label: Label = null


func _ready() -> void:
	_create_telemetry_ui()


func _create_telemetry_ui() -> void:
	var canvas = CanvasLayer.new()
	canvas.name = "TelemetryCanvas"
	canvas.layer = 15
	add_child(canvas)
	
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.position = Vector2(24, 24)
	canvas.add_child(panel)
	
	telemetry_label = Label.new()
	telemetry_label.text = "BANGLADESH WORLD SYSTEM: INITIALIZING..."
	telemetry_label.add_theme_font_size_override("font_size", 13)
	telemetry_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95, 1))
	panel.add_child(telemetry_label)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
		
	match event.keycode:
		KEY_1:
			_teleport_player(Vector3(0.0, 0.5, 0.0), "Metropolitan Dhaka")
		KEY_2:
			_teleport_player(Vector3(-1024.0, 0.5, 0.0), "Rajshahi & Padma Delta")
		KEY_3:
			_teleport_player(Vector3(512.0, 0.5, 512.0), "Sylhet Tea Gardens & Wetlands")
		KEY_4:
			_teleport_player(Vector3(512.0, 0.5, -512.0), "Chattogram Maritime Port")
		KEY_5:
			_teleport_player(Vector3(512.0, 0.5, -1024.0), "Cox's Bazar Coastal Strip")
		KEY_6:
			_teleport_player(Vector3(-512.0, 0.5, -768.0), "Sundarbans Mangrove Delta")
		KEY_7:
			_teleport_player(Vector3(-512.0, 0.5, 0.0), "Rural Agricultural Plains")
		KEY_C:
			# Bring test sedan to player
			if player and test_sedan:
				test_sedan.global_position = player.global_position + (player.global_transform.basis.x * 4.0)
				test_sedan.linear_velocity = Vector3.ZERO
		KEY_K:
			var p_pos = player.global_position if player else Vector3.ZERO
			SaveSystem.save_game(p_pos)
			EventBus.mission_objective_updated.emit(1, "World coordinates saved to savegame.json")
		KEY_L:
			SaveSystem.load_game()
			EventBus.mission_objective_updated.emit(1, "World state and coordinates loaded")


func _teleport_player(target_pos: Vector3, region_title: String) -> void:
	if player:
		player.global_position = target_pos
		if GameManager.active_vehicle:
			GameManager.active_vehicle.global_position = target_pos + Vector3(4, 0, 0)
			GameManager.active_vehicle.linear_velocity = Vector3.ZERO
	EventBus.mission_objective_updated.emit(1, "Fast Traveled to: %s" % region_title)


func _process(_delta: float) -> void:
	if not telemetry_label:
		return
		
	var p_pos = player.global_position if player else Vector3.ZERO
	var current_region := "Unknown"
	var current_bangla := ""
	if world_system and world_system.biome_manager:
		var reg_id = world_system.biome_manager.current_region
		var info: Dictionary = RegionalBiomeManager.BIOMES.get(reg_id, {})
		current_region = info.get("title", reg_id.capitalize())
		current_bangla = info.get("bangla", "")
		
	var cell_x := int(floor(p_pos.x / 512.0))
	var cell_z := int(floor(p_pos.z / 512.0))
	
	var loaded_count := 0
	var lod0_count := 0
	var lod1_count := 0
	var lod2_count := 0
	if world_system and world_system.streamer:
		loaded_count = world_system.streamer.active_tiles.size()
		for cell in world_system.streamer.active_tiles:
			var tile: WorldTile = world_system.streamer.active_tiles[cell]
			if is_instance_valid(tile):
				match tile.current_lod:
					WorldTile.LODLevel.LOD_0_FULL: lod0_count += 1
					WorldTile.LODLevel.LOD_1_MEDIUM: lod1_count += 1
					WorldTile.LODLevel.LOD_2_LOW: lod2_count += 1
	
	var text := "=== DTA BANGLADESH OPEN WORLD SYSTEM ===\n"
	text += "Active Sector        : %s (%s)\n" % [current_region, current_bangla]
	text += "Player World GPS     : X: %d | Y: %.1f | Z: %d\n" % [int(p_pos.x), p_pos.y, int(p_pos.z)]
	text += "Streaming Cell Grid  : Cell [%d, %d] (512m Scale)\n" % [cell_x, cell_z]
	text += "Active Chunks Loaded : %d tiles in memory\n" % loaded_count
	text += "Distance LOD Status  : LOD0: %d | LOD1: %d | LOD2: %d\n" % [lod0_count, lod1_count, lod2_count]
	text += "Highway Connections  : NH-1 (Padma), NH-2 (Sylhet), NH-3 (Coastal)\n"
	text += "--------------------------------------------------\n"
	text += "WORLD NAVIGATION SHORTCUTS:\n"
	text += "[M]       : Open/Close Fullscreen World Navigation Map\n"
	text += "[1]       : Fast Travel to Metropolitan Dhaka Core (0, 0)\n"
	text += "[2]       : Fast Travel to Rajshahi & Padma Bridge (-1024, 0)\n"
	text += "[3]       : Fast Travel to Sylhet Tea Hills (512, 512)\n"
	text += "[4]       : Fast Travel to Chattogram Maritime Port (512, -512)\n"
	text += "[5]       : Fast Travel to Cox's Bazar Marine Drive (512, -1024)\n"
	text += "[6]       : Fast Travel to Sundarbans Mangrove (-512, -768)\n"
	text += "[7]       : Fast Travel to Rural Agricultural Plains (-512, 0)\n"
	text += "[C]       : Teleport Drivable Sedan to Player\n"
	text += "[K] Save  |  [L] Load World Coordinates\n"
	
	telemetry_label.text = text
