# ==============================================================================
# CHUNK STREAMER (BACKGROUND ASSET STREAMING)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Asynchronously streams 512m modular tiles around player viewing radius
#          using ResourceLoader.load_threaded_request to prevent frame drops.
# ==============================================================================
class_name ChunkStreamer
extends Node

signal chunk_loaded(coord: Vector2i, tile: WorldTile)
signal chunk_unloaded(coord: Vector2i)

@export var cell_size_meters: float = 512.0
@export var stream_radius_cells: int = 1 # 3x3 active grid cells

# Registry: Vector2i -> scene_path String
var chunk_registry: Dictionary = {}

# Active instances: Vector2i -> WorldTile
var active_tiles: Dictionary = {}

# In-flight threaded loading: Vector2i -> scene_path
var pending_loads: Dictionary = {}


func register_chunk(coord: Vector2i, scene_path: String) -> void:
	chunk_registry[coord] = scene_path


func update_streaming(player_position: Vector3) -> void:
	var current_cell = Vector2i(
		int(floor(player_position.x / cell_size_meters)),
		int(floor(player_position.z / cell_size_meters))
	)
	
	# 1. Determine cells within streaming radius
	var required_cells: Array[Vector2i] = []
	for x in range(current_cell.x - stream_radius_cells, current_cell.x + stream_radius_cells + 1):
		for z in range(current_cell.y - stream_radius_cells, current_cell.y + stream_radius_cells + 1):
			var cell = Vector2i(x, z)
			if chunk_registry.has(cell):
				required_cells.append(cell)
	
	# 2. Unload cells outside streaming radius
	var to_unload: Array[Vector2i] = []
	for cell in active_tiles:
		if not cell in required_cells:
			to_unload.append(cell)
			
	for cell in to_unload:
		_unload_tile(cell)
		
	# 3. Request threaded load for missing cells
	for cell in required_cells:
		if not active_tiles.has(cell) and not pending_loads.has(cell):
			var path: String = chunk_registry[cell]
			ResourceLoader.load_threaded_request(path)
			pending_loads[cell] = path
			
	# 4. Check status of pending threaded loads
	_poll_pending_loads()
	
	# 5. Update distance-based LOD on active tiles
	for cell in active_tiles:
		var tile: WorldTile = active_tiles[cell]
		if is_instance_valid(tile):
			tile.update_distance_lod(player_position)


func _poll_pending_loads() -> void:
	var completed: Array[Vector2i] = []
	
	for cell in pending_loads:
		var path: String = pending_loads[cell]
		var status = ResourceLoader.load_threaded_get_status(path)
		
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var scene = ResourceLoader.load_threaded_get(path) as PackedScene
			if scene:
				var tile_inst = scene.instantiate() as WorldTile
				tile_inst.name = "Tile_%d_%d" % [cell.x, cell.y]
				tile_inst.position = Vector3(
					float(cell.x) * cell_size_meters,
					0.0,
					float(cell.y) * cell_size_meters
				)
				add_child(tile_inst)
				active_tiles[cell] = tile_inst
				chunk_loaded.emit(cell, tile_inst)
			completed.append(cell)
		elif status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("Failed to load chunk scene: " + path)
			completed.append(cell)
			
	for cell in completed:
		pending_loads.erase(cell)


func _unload_tile(cell: Vector2i) -> void:
	if active_tiles.has(cell):
		var tile = active_tiles[cell]
		active_tiles.erase(cell)
		if is_instance_valid(tile):
			tile.queue_free()
		chunk_unloaded.emit(cell)
