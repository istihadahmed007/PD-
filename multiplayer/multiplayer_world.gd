# ==============================================================================
# MULTIPLAYER WORLD CONTROLLER
# Project: Bangladesh Online Multiplayer Game (DTA: Dhaka Theft Auto)
# Responsibilities:
#   - Orchestrates MultiplayerSpawner for deterministic client/server replication
#   - Assigns unique spawn positions from the neighbourhood map
#   - Manages player joining, clean despawn on disconnect, and reconnection
#   - Provides in-game HUD (player list, ping, connection status, disconnect button)
# ==============================================================================
class_name MultiplayerWorld
extends Node3D

const PLAYER_SCENE_PATH: String = "res://multiplayer/network_player.tscn"
const MENU_SCENE_PATH: String = "res://multiplayer/multiplayer_menu.tscn"
const NetworkPlayerScript = preload("res://multiplayer/network_player.gd")

@onready var map_instance: Node3D = $District01 if has_node("District01") else get_node_or_null("NeighbourhoodMap")
@onready var players_container: Node3D = $SpawnedPlayers
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner

# HUD UI References
@onready var hud_root: CanvasLayer = $WorldHUD
@onready var label_status: Label = %LabelNetworkStatus
@onready var label_player_count: Label = %LabelPlayerCount
@onready var player_list_panel: PanelContainer = %PlayerListPanel
@onready var player_list_container: VBoxContainer = %PlayerListVBox
@onready var btn_disconnect: Button = %BtnDisconnect
@onready var session_overlay: PanelContainer = %SessionOverlay

var player_packed_scene: PackedScene = preload(PLAYER_SCENE_PATH)
var _spawn_index: int = 0


func _ready() -> void:
	_setup_spawner()
	_connect_hud_signals()
	_connect_network_signals()
	
	_update_hud_display()
	
	# If running as server, spawn characters for any peers already registered
	if multiplayer.is_server():
		for peer_id in NetworkManager.players:
			var p_data: Dictionary = NetworkManager.players[peer_id]
			_spawn_network_player(peer_id, p_data.get("nickname", "Player_%d" % peer_id))


func _setup_spawner() -> void:
	if not multiplayer_spawner:
		return
	
	multiplayer_spawner.spawn_path = NodePath("../SpawnedPlayers")
	multiplayer_spawner.clear_spawnable_scenes()
	multiplayer_spawner.add_spawnable_scene(PLAYER_SCENE_PATH)


func _connect_hud_signals() -> void:
	if btn_disconnect:
		btn_disconnect.pressed.connect(_on_disconnect_pressed)
	
	if session_overlay:
		session_overlay.visible = false


func _connect_network_signals() -> void:
	NetworkManager.player_joined.connect(_on_player_joined)
	NetworkManager.player_left.connect(_on_player_left)
	NetworkManager.player_list_updated.connect(_on_player_list_updated)
	NetworkManager.status_changed.connect(func(_s): _update_hud_display())
	NetworkManager.server_disconnected.connect(_on_server_disconnected)


func _unhandled_input(event: InputEvent) -> void:
	# Toggle player roster overlay with TAB
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_TAB:
			if player_list_panel:
				player_list_panel.visible = not player_list_panel.visible
		elif event.keycode == KEY_ESCAPE:
			if session_overlay:
				session_overlay.visible = not session_overlay.visible
				if session_overlay.visible:
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				else:
					Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# ==============================================================================
# AUTHORITATIVE SERVER SPAWN & DESPAWN LOGIC
# ==============================================================================
func _on_player_joined(peer_id: int, player_data: Dictionary) -> void:
	if not multiplayer.is_server():
		return
	
	var nickname: String = player_data.get("nickname", "Player_%d" % peer_id)
	_spawn_network_player(peer_id, nickname)


func _spawn_network_player(peer_id: int, nickname: String) -> void:
	if not multiplayer.is_server():
		return
	
	var node_name := str(peer_id)
	# Check if player node already exists
	if players_container.has_node(node_name):
		var existing: Node = players_container.get_node(node_name)
		if existing and "player_nickname" in existing:
			existing.player_nickname = nickname
		return
	
	var spawn_pos := _get_next_spawn_position()
	
	var player_instance: CharacterBody3D = player_packed_scene.instantiate() as CharacterBody3D
	player_instance.name = node_name
	player_instance.position = spawn_pos
	player_instance.set("player_peer_id", peer_id)
	player_instance.set("player_nickname", nickname)
	player_instance.set("sync_position", spawn_pos)
	
	# add_child(..., true) ensures the node name is preserved across network replication
	players_container.add_child(player_instance, true)
	
	print("[SERVER] Spawned player character for peer %d ('%s') at %s" % [peer_id, nickname, str(spawn_pos)])


func _on_player_left(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	
	_despawn_network_player(peer_id)


func _despawn_network_player(peer_id: int) -> void:
	var node_name := str(peer_id)
	if players_container.has_node(node_name):
		var p_node := players_container.get_node(node_name)
		if p_node:
			print("[SERVER] Despawning player character for disconnected peer %d..." % peer_id)
			p_node.queue_free()


func _get_next_spawn_position() -> Vector3:
	var markers: Array[Node] = get_tree().get_nodes_in_group("spawn_points")
	if markers.is_empty():
		return Vector3(0.0, 0.2, 0.0)
	
	var marker := markers[_spawn_index % markers.size()] as Marker3D
	_spawn_index += 1
	if marker:
		return marker.global_position + Vector3(randf_range(-0.5, 0.5), 0.0, randf_range(-0.5, 0.5))
	
	return Vector3(0.0, 0.2, 0.0)


# ==============================================================================
# HUD & ROSTER UI REFRESH
# ==============================================================================
func _on_player_list_updated(_players_dict: Dictionary) -> void:
	_update_hud_display()


func _update_hud_display() -> void:
	var count := NetworkManager.players.size()
	if label_player_count:
		label_player_count.text = "PLAYERS ONLINE: %d" % count
	
	if label_status:
		var role_str := ""
		match NetworkManager.current_role:
			NetworkManager.NetworkRole.DEDICATED_SERVER: role_str = "DEDICATED SERVER"
			NetworkManager.NetworkRole.LISTEN_HOST: role_str = "HOST"
			NetworkManager.NetworkRole.CLIENT: role_str = "CLIENT"
			_: role_str = "STANDALONE"
		
		label_status.text = "MODE: %s | UDP PORT: %d | STATUS: %s" % [
			role_str,
			NetworkManager.current_port,
			NetworkManager.connection_status
		]
	
	_rebuild_roster_list()


func _rebuild_roster_list() -> void:
	if not player_list_container:
		return
	
	for child in player_list_container.get_children():
		child.queue_free()
	
	var my_id := 0
	if multiplayer and multiplayer.has_multiplayer_peer() and multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED:
		my_id = multiplayer.get_unique_id()
	
	for peer_id in NetworkManager.players:
		var p_data: Dictionary = NetworkManager.players[peer_id]
		var nick: String = p_data.get("nickname", "Player_%d" % peer_id)
		var role: String = p_data.get("role", "Client")
		
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		
		var lbl_id := Label.new()
		lbl_id.custom_minimum_size = Vector2(80, 0)
		lbl_id.text = "ID: %d" % peer_id
		lbl_id.add_theme_color_override("font_color", Color(0.65, 0.7, 0.75, 1.0))
		row.add_child(lbl_id)
		
		var lbl_name := Label.new()
		lbl_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var tag := " (You)" if peer_id == my_id else ""
		lbl_name.text = "%s%s" % [nick, tag]
		lbl_name.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3, 1.0) if peer_id == my_id else Color.WHITE)
		row.add_child(lbl_name)
		
		var lbl_role := Label.new()
		lbl_role.custom_minimum_size = Vector2(90, 0)
		lbl_role.text = "[%s]" % role
		lbl_role.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		lbl_role.add_theme_color_override("font_color", Color(0.3, 0.85, 0.95, 1.0) if role == "Host" else Color(0.7, 0.85, 0.7, 1.0))
		row.add_child(lbl_role)
		
		player_list_container.add_child(row)


func _on_disconnect_pressed() -> void:
	print("[NET] Disconnect requested from HUD.")
	NetworkManager.disconnect_peer()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file(MENU_SCENE_PATH)


func _on_server_disconnected() -> void:
	print("[NET] Received server disconnect notification in world.")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file(MENU_SCENE_PATH)
