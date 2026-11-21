# ==============================================================================
# MULTIPLAYER MENU CONTROLLER
# Project: Bangladesh Online Multiplayer Game (DTA: Dhaka Theft Auto)
# Purpose: Functional multiplayer lobby allowing users to host sessions, join
#          remote/LAN/localhost games, configure IP/Port/Nickname, monitor
#          connection status, view connected peers, and disconnect.
# ==============================================================================
class_name MultiplayerMenu
extends Control

const WORLD_SCENE_PATH := "res://multiplayer/multiplayer_world.tscn"
const MAIN_MENU_PATH := "res://ui/menu/main_menu.tscn"

# Input Controls
@onready var input_nickname: LineEdit = %InputNickname
@onready var input_ip: LineEdit = %InputServerIP
@onready var input_port: LineEdit = %InputServerPort
@onready var spin_max_players: SpinBox = %SpinMaxPlayers

# Action Buttons
@onready var btn_host: Button = %BtnHost
@onready var btn_connect: Button = %BtnConnect
@onready var btn_dedicated: Button = %BtnDedicated
@onready var btn_disconnect: Button = %BtnDisconnect
@onready var btn_back: Button = %BtnBack

# Status & Roster
@onready var label_status: Label = %LabelConnectionStatus
@onready var roster_container: VBoxContainer = %RosterListVBox
@onready var panel_roster: PanelContainer = %PanelRoster


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_init_default_values()
	_connect_ui_signals()
	_connect_network_signals()
	_update_ui_state()


func _init_default_values() -> void:
	if input_nickname and input_nickname.text.is_empty():
		input_nickname.text = NetworkManager.local_nickname
	if input_ip and input_ip.text.is_empty():
		input_ip.text = NetworkManager.DEFAULT_IP
	if input_port and input_port.text.is_empty():
		input_port.text = str(NetworkManager.DEFAULT_PORT)
	if spin_max_players:
		spin_max_players.value = NetworkManager.DEFAULT_MAX_PLAYERS


func _connect_ui_signals() -> void:
	if btn_host: btn_host.pressed.connect(_on_host_pressed)
	if btn_connect: btn_connect.pressed.connect(_on_connect_pressed)
	if btn_dedicated: btn_dedicated.pressed.connect(_on_dedicated_pressed)
	if btn_disconnect: btn_disconnect.pressed.connect(_on_disconnect_pressed)
	if btn_back: btn_back.pressed.connect(_on_back_pressed)


func _connect_network_signals() -> void:
	NetworkManager.status_changed.connect(_on_status_changed)
	NetworkManager.connected_to_server.connect(_on_connected_to_server)
	NetworkManager.connection_failed.connect(_on_connection_failed)
	NetworkManager.server_disconnected.connect(_on_server_disconnected)
	NetworkManager.player_list_updated.connect(_on_player_list_updated)


# ==============================================================================
# UI ACTIONS
# ==============================================================================
func _on_host_pressed() -> void:
	var port := int(input_port.text) if input_port else NetworkManager.DEFAULT_PORT
	var max_clients := int(spin_max_players.value) if spin_max_players else NetworkManager.DEFAULT_MAX_PLAYERS
	var nick := input_nickname.text.strip_edges() if input_nickname else "Host"
	if nick.is_empty(): nick = "Host"
	
	_set_status("Starting Listen Server on UDP port %d..." % port, Color(1, 0.85, 0.2))
	var err := NetworkManager.start_server(port, max_clients, false, nick)
	if err == OK:
		get_tree().change_scene_to_file(WORLD_SCENE_PATH)
	else:
		_set_status("Failed to start server (Error %d)" % err, Color(1, 0.35, 0.3))


func _on_dedicated_pressed() -> void:
	var port := int(input_port.text) if input_port else NetworkManager.DEFAULT_PORT
	var max_clients := int(spin_max_players.value) if spin_max_players else NetworkManager.DEFAULT_MAX_PLAYERS
	
	_set_status("Starting Dedicated Server on UDP port %d..." % port, Color(0.3, 0.85, 0.95))
	var err := NetworkManager.start_server(port, max_clients, true, "DedicatedServer")
	if err == OK:
		get_tree().change_scene_to_file(WORLD_SCENE_PATH)
	else:
		_set_status("Failed to start dedicated server (Error %d)" % err, Color(1, 0.35, 0.3))


func _on_connect_pressed() -> void:
	var ip := input_ip.text.strip_edges() if input_ip else NetworkManager.DEFAULT_IP
	var port := int(input_port.text) if input_port else NetworkManager.DEFAULT_PORT
	var nick := input_nickname.text.strip_edges() if input_nickname else "Player"
	if nick.is_empty(): nick = "Player_%d" % (randi() % 900 + 100)
	
	_set_status("Connecting to %s:%d as '%s'..." % [ip, port, nick], Color(1, 0.85, 0.2))
	_set_buttons_enabled(false)
	
	var err := NetworkManager.start_client(ip, port, nick)
	if err != OK:
		_set_status("Could not initiate client socket (Error %d)" % err, Color(1, 0.35, 0.3))
		_set_buttons_enabled(true)


func _on_disconnect_pressed() -> void:
	NetworkManager.disconnect_peer()
	_set_status("Disconnected.", Color(0.8, 0.8, 0.85))
	_update_ui_state()


func _on_back_pressed() -> void:
	NetworkManager.disconnect_peer()
	get_tree().change_scene_to_file(MAIN_MENU_PATH)


# ==============================================================================
# NETWORK CALLBACKS
# ==============================================================================
func _on_status_changed(new_status: String) -> void:
	if label_status:
		label_status.text = new_status


func _on_connected_to_server() -> void:
	_set_status("Connected! Entering neighbourhood...", Color(0.3, 0.9, 0.4))
	get_tree().change_scene_to_file(WORLD_SCENE_PATH)


func _on_connection_failed(reason: String) -> void:
	_set_status("Connection Failed: %s" % reason, Color(1, 0.35, 0.3))
	_set_buttons_enabled(true)
	_update_ui_state()


func _on_server_disconnected() -> void:
	_set_status("Server disconnected.", Color(1, 0.5, 0.3))
	_set_buttons_enabled(true)
	_update_ui_state()


func _on_player_list_updated(_players_dict: Dictionary) -> void:
	_rebuild_roster_table()


# ==============================================================================
# UI HELPERS
# ==============================================================================
func _set_status(msg: String, color: Color) -> void:
	if label_status:
		label_status.text = msg
		label_status.add_theme_color_override("font_color", color)


func _set_buttons_enabled(enabled: bool) -> void:
	if btn_host: btn_host.disabled = not enabled
	if btn_connect: btn_connect.disabled = not enabled
	if btn_dedicated: btn_dedicated.disabled = not enabled


func _update_ui_state() -> void:
	var is_active := NetworkManager.current_role != NetworkManager.NetworkRole.NONE
	if btn_disconnect:
		btn_disconnect.visible = is_active
	if panel_roster:
		panel_roster.visible = is_active and not NetworkManager.players.is_empty()
	_rebuild_roster_table()


func _rebuild_roster_table() -> void:
	if not roster_container:
		return
	
	for child in roster_container.get_children():
		child.queue_free()
	
	var my_id := 0
	if multiplayer and multiplayer.has_multiplayer_peer() and multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED:
		my_id = multiplayer.get_unique_id()
	
	for peer_id in NetworkManager.players:
		var data: Dictionary = NetworkManager.players[peer_id]
		var nick: String = data.get("nickname", str(peer_id))
		var role: String = data.get("role", "Client")
		
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 16)
		
		var l_id := Label.new()
		l_id.custom_minimum_size = Vector2(90, 0)
		l_id.text = "ID: %d" % peer_id
		l_id.add_theme_color_override("font_color", Color(0.65, 0.7, 0.75, 1))
		row.add_child(l_id)
		
		var l_name := Label.new()
		l_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var tag := " (You)" if peer_id == my_id else ""
		l_name.text = "%s%s" % [nick, tag]
		l_name.add_theme_color_override("font_color", Color(1, 0.9, 0.3, 1) if peer_id == my_id else Color.WHITE)
		row.add_child(l_name)
		
		var l_role := Label.new()
		l_role.custom_minimum_size = Vector2(100, 0)
		l_role.text = "[%s]" % role
		l_role.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		l_role.add_theme_color_override("font_color", Color(0.3, 0.85, 0.95, 1) if role == "Host" else Color(0.7, 0.85, 0.7, 1))
		row.add_child(l_role)
		
		roster_container.add_child(row)
