# ==============================================================================
# WORLD SYSTEM (MASTER OPEN-WORLD COORDINATOR)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Orchestrates 512m chunk-based streaming, background asset loading,
#          distance LODs, regional biome transitions, and world navigation map.
# ==============================================================================
class_name WorldSystem
extends Node3D

@export var cell_size_meters: float = 512.0
@export var stream_radius_cells: int = 1

var streamer: ChunkStreamer = null
var biome_manager: RegionalBiomeManager = null
var player_ref: Node3D = null
var world_environment: WorldEnvironment = null


func _ready() -> void:
	# Instantiate Chunk Streamer
	streamer = ChunkStreamer.new()
	streamer.name = "ChunkStreamer"
	streamer.cell_size_meters = cell_size_meters
	streamer.stream_radius_cells = stream_radius_cells
	add_child(streamer)
	
	# Instantiate Biome Transition Manager
	biome_manager = RegionalBiomeManager.new()
	biome_manager.name = "RegionalBiomeManager"
	add_child(biome_manager)
	
	_register_all_world_chunks()


func _process(_delta: float) -> void:
	if not player_ref and GameManager.active_player:
		player_ref = GameManager.active_player
		
	if not world_environment:
		world_environment = get_node_or_null("WorldEnvironment") as WorldEnvironment
		if not world_environment and get_tree().current_scene:
			world_environment = get_tree().current_scene.get_node_or_null("WorldEnvironment") as WorldEnvironment
	
	if player_ref:
		var p_pos = player_ref.global_position
		streamer.update_streaming(p_pos)
		biome_manager.update_player_region(p_pos, world_environment)


func _register_all_world_chunks() -> void:
	# Continuous geographical grid across Bangladesh
	# 1. Dhaka Region (Cell 0, 0)
	streamer.register_chunk(Vector2i(0, 0), "res://world/regions/region_01_dhaka.tscn")
	# 2. Rajshahi & Padma Region (Cell -2, 0)
	streamer.register_chunk(Vector2i(-2, 0), "res://world/regions/region_02_rajshahi_padma.tscn")
	# 3. Sylhet Tea Gardens & Wetlands (Cell 1, 1)
	streamer.register_chunk(Vector2i(1, 1), "res://world/regions/region_03_sylhet_hills.tscn")
	# 4. Chattogram Maritime Port (Cell 1, -1)
	streamer.register_chunk(Vector2i(1, -1), "res://world/regions/region_04_chattogram_port.tscn")
	# 5. Cox's Bazar Coastal Strip (Cell 1, -2)
	streamer.register_chunk(Vector2i(1, -2), "res://world/regions/region_05_cox_coastal.tscn")
	# 6. Sundarbans Mangrove Delta (Cell -1, -1)
	streamer.register_chunk(Vector2i(-1, -1), "res://world/regions/region_06_sundarbans_mangrove.tscn")
	# 7. Rural Agricultural Plains (Cell -1, 0)
	streamer.register_chunk(Vector2i(-1, 0), "res://world/regions/region_07_rural_agriculture.tscn")
