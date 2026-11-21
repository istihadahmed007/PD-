# ==============================================================================
# MODULAR WORLD TILE (WORLD SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Base class for 512m streaming world chunks with 3-tier distance-based LOD,
#          road/river connector ports, occlusion culling, and regional metadata.
# ==============================================================================
class_name WorldTile
extends Node3D

enum LODLevel {
	LOD_0_FULL,    # < 250m: Full collisions, fine props, active lights, audio emitters
	LOD_1_MEDIUM,  # 250m - 600m: Hidden particles and small props, collision active
	LOD_2_LOW      # > 600m: Silhouette terrain mesh only, collisions disabled
}

@export_category("Chunk Coordinates & Region")
@export var chunk_coord: Vector2i = Vector2i.ZERO
@export var chunk_size_meters: float = 512.0
@export var region_id: String = "dhaka"
@export var region_name: String = "Metropolitan Dhaka"
@export var region_bangla: String = "মেট্রোপলিটন ঢাকা"

@export_category("Road & River Connector Ports")
@export var has_north_road: bool = false
@export var has_south_road: bool = false
@export var has_east_road: bool = false
@export var has_west_road: bool = false
@export var has_river_channel: bool = false

var current_lod: LODLevel = LODLevel.LOD_0_FULL

# Cached node groupings for LOD optimization
@onready var lod0_nodes: Node3D = $LOD0_Detailed if has_node("LOD0_Detailed") else null
@onready var lod1_nodes: Node3D = $LOD1_Medium if has_node("LOD1_Medium") else null
@onready var terrain_node: Node3D = $Terrain if has_node("Terrain") else null
@onready var collision_root: Node3D = $Collisions if has_node("Collisions") else null


func _ready() -> void:
	add_to_group("world_tiles")
	_apply_lod(LODLevel.LOD_0_FULL)


func get_chunk_center_world() -> Vector3:
	return Vector3(
		float(chunk_coord.x) * chunk_size_meters + (chunk_size_meters * 0.5),
		0.0,
		float(chunk_coord.y) * chunk_size_meters + (chunk_size_meters * 0.5)
	)


func update_distance_lod(player_position: Vector3) -> void:
	var center := get_chunk_center_world()
	var dist := player_position.distance_to(center)
	
	if dist < 260.0:
		set_lod(LODLevel.LOD_0_FULL)
	elif dist < 650.0:
		set_lod(LODLevel.LOD_1_MEDIUM)
	else:
		set_lod(LODLevel.LOD_2_LOW)


func set_lod(new_lod: LODLevel) -> void:
	if current_lod == new_lod:
		return
	current_lod = new_lod
	_apply_lod(new_lod)


func _apply_lod(level: LODLevel) -> void:
	match level:
		LODLevel.LOD_0_FULL:
			if lod0_nodes: lod0_nodes.show()
			if lod1_nodes: lod1_nodes.show()
			if terrain_node: terrain_node.show()
			_set_collisions_enabled(true)
		LODLevel.LOD_1_MEDIUM:
			if lod0_nodes: lod0_nodes.hide()
			if lod1_nodes: lod1_nodes.show()
			if terrain_node: terrain_node.show()
			_set_collisions_enabled(true)
		LODLevel.LOD_2_LOW:
			if lod0_nodes: lod0_nodes.hide()
			if lod1_nodes: lod1_nodes.hide()
			if terrain_node: terrain_node.show()
			_set_collisions_enabled(false)


func _set_collisions_enabled(enable: bool) -> void:
	if not collision_root:
		return
	for child in collision_root.get_children():
		if child is CollisionShape3D:
			child.disabled = not enable
		elif child is StaticBody3D:
			child.process_mode = Node.PROCESS_MODE_INHERIT if enable else Node.PROCESS_MODE_DISABLED
