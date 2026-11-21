# ==============================================================================
# NETWORK MANAGER (AUTOLOAD SINGLETON)
# Project: Bangladesh Online Multiplayer Game (DTA: Dhaka Theft Auto)
# Architecture: Godot 4 ENet Native Multiplayer, Server-Authoritative
# Responsibilities:
#   - Connection lifecycle (Dedicated Server, Listen Server / Host, Client)
#   - Peer registration and authority validation
#   - Global player list replication via reliable RPCs
#   - Command-line argument parsing for headless server & automated testing
#   - Clean error handling, timeout recovery, and graceful disconnection
# ==============================================================================
class_name NetworkManagerClass
extends Node

signal status_changed(new_status: String)
signal server_started(port: int)
signal server_stopped()
signal connected_to_server()
signal connection_failed(reason: String)
signal server_disconnected()
signal player_joined(peer_id: int, player_data: Dictionary)
signal player_left(peer_id: int)
signal player_list_updated(players_dict: Dictionary)

const DEFAULT_PORT: int = 7777
const DEFAULT_MAX_PLAYERS: int = 16
const DEFAULT_IP: String = "127.0.0.1"
const DEFAULT_PRODUCTION_DOMAIN: String = "bc.vartualtutor.com"
const DEFAULT_WSS_URL: String = "wss://bc.vartualtutor.com/game"
const WORLD_SCENE_PATH: String = "res://multiplayer/multiplayer_world.tscn"
const MENU_SCENE_PATH: String = "res://multiplayer/multiplayer_menu.tscn"

enum NetworkRole {
	NONE,
	DEDICATED_SERVER,
	LISTEN_HOST,
	CLIENT
}

var current_role: NetworkRole = NetworkRole.NONE
var server_peer: MultiplayerPeer = null
var is_websocket_mode: bool = false
var connection_status: String = "Disconnected"
var local_nickname: String = "Joy"
var current_port: int = DEFAULT_PORT
var current_ip: String = DEFAULT_IP
var max_players: int = DEFAULT_MAX_PLAYERS

## Dictionary mapping peer_id (int) -> Dictionary:
## {
##   "peer_id": int,
##   "nickname": String,
##   "role": String,
##   "joined_at": int
## }
var players: Dictionary = {}


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	_bind_multiplayer_signals()
	# Check for command line automation arguments
	call_deferred("_parse_cmdline_arguments")


func _bind_multiplayer_signals() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


# ==============================================================================
# SERVER INITIALIZATION (DEDICATED OR LISTEN)
# ==============================================================================
func start_server(port: int = DEFAULT_PORT, max_clients: int = DEFAULT_MAX_PLAYERS, is_dedicated: bool = false, host_name: String = "Host", use_websocket: bool = false) -> Error:
	disconnect_peer()
	
	current_port = port
	max_players = max_clients
	is_websocket_mode = use_websocket
	local_nickname = host_name.strip_edges()
	if local_nickname.is_empty():
		local_nickname = "Host"
	
	if use_websocket:
		var ws_peer := WebSocketMultiplayerPeer.new()
		var err := ws_peer.create_server(current_port)
		if err != OK:
			var err_msg := "Failed to create WebSocket server on port %d (Error code: %d)" % [current_port, err]
			_log_error(err_msg)
			_set_status("Error: " + err_msg)
			return err
		server_peer = ws_peer
	else:
		var enet_peer := ENetMultiplayerPeer.new()
		var err := enet_peer.create_server(current_port, max_players)
		if err != OK:
			var err_msg := "Failed to create server on UDP port %d (Error code: %d)" % [current_port, err]
			_log_error(err_msg)
			_set_status("Error: " + err_msg)
			return err
		server_peer = enet_peer
	
	multiplayer.multiplayer_peer = server_peer
	current_role = NetworkRole.DEDICATED_SERVER if is_dedicated else NetworkRole.LISTEN_HOST
	
	var proto_name := "WebSocket (WSS-Ready)" if use_websocket else "UDP/ENet"
	var mode_name := "DEDICATED SERVER" if is_dedicated else "LISTEN HOST"
	_log_info("%s started successfully on %s port %d (Max peers: %d)" % [mode_name, proto_name, current_port, max_players])
	_set_status("Running as %s (%s) on port %d" % [mode_name, proto_name, current_port])
	
	players.clear()
	
	if not is_dedicated:
		# In Listen Server mode, register host as peer 1
		players[1] = {
			"peer_id": 1,
			"nickname": local_nickname,
			"role": "Host",
			"joined_at": Time.get_ticks_msec()
		}
		player_joined.emit(1, players[1])
		player_list_updated.emit(players)
	
	server_started.emit(current_port)
	return OK


# ==============================================================================
# CLIENT CONNECTION
# ==============================================================================
func start_client(ip: String = DEFAULT_IP, port: int = DEFAULT_PORT, nickname: String = "Player", force_websocket: bool = false) -> Error:
	disconnect_peer()
	
	current_ip = ip.strip_edges()
	if current_ip.is_empty():
		current_ip = DEFAULT_IP
	current_port = port
	local_nickname = nickname.strip_edges()
	if local_nickname.is_empty():
		local_nickname = "Player_%d" % (randi() % 900 + 100)
	
	var is_ws := force_websocket or OS.has_feature("web") or current_ip.begins_with("ws://") or current_ip.begins_with("wss://")
	is_websocket_mode = is_ws
	
	if is_ws:
		var ws_url := current_ip
		if OS.has_feature("web") and (current_ip == DEFAULT_IP or current_ip.is_empty()):
			ws_url = DEFAULT_WSS_URL
		elif not ws_url.begins_with("ws://") and not ws_url.begins_with("wss://"):
			ws_url = "ws://%s:%d" % [current_ip, current_port]
		var ws_peer := WebSocketMultiplayerPeer.new()
		var err := ws_peer.create_client(ws_url)
		if err != OK:
			var err_msg := "Failed to initiate WebSocket connection to %s (Error code: %d)" % [ws_url, err]
			_log_error(err_msg)
			_set_status("Error: " + err_msg)
			connection_failed.emit(err_msg)
			return err
		server_peer = ws_peer
		_log_info("Connecting to WebSocket server at %s as '%s'..." % [ws_url, local_nickname])
		_set_status("Connecting via WebSocket to %s..." % ws_url)
	else:
		var enet_peer := ENetMultiplayerPeer.new()
		var err := enet_peer.create_client(current_ip, current_port)
		if err != OK:
			var err_msg := "Failed to initiate client connection to %s:%d (Error code: %d)" % [current_ip, current_port, err]
			_log_error(err_msg)
			_set_status("Error: " + err_msg)
			connection_failed.emit(err_msg)
			return err
		server_peer = enet_peer
		_log_info("Connecting to server at %s:%d as '%s'..." % [current_ip, current_port, local_nickname])
		_set_status("Connecting to %s:%d..." % [current_ip, current_port])
	
	multiplayer.multiplayer_peer = server_peer
	current_role = NetworkRole.CLIENT
	return OK


# ==============================================================================
# DISCONNECT & CLEANUP
# ==============================================================================
func disconnect_peer() -> void:
	if server_peer:
		server_peer.close()
		server_peer = null
	
	multiplayer.multiplayer_peer = null
	players.clear()
	
	var was_role := current_role
	current_role = NetworkRole.NONE
	_set_status("Disconnected")
	
	if was_role == NetworkRole.DEDICATED_SERVER or was_role == NetworkRole.LISTEN_HOST:
		server_stopped.emit()
	
	_log_info("Multiplayer peer disconnected and cleaned up.")


# ==============================================================================
# MULTIPLAYER SIGNALS (SERVER & CLIENT)
# ==============================================================================
func _on_peer_connected(peer_id: int) -> void:
	_log_info("Remote peer connected: ID %d" % peer_id)
	
	if multiplayer.is_server():
		# Wait for client to send their registered nickname via RPC
		_log_info("[SERVER] Awaiting registration handshake from peer %d..." % peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
	_log_info("Peer disconnected: ID %d" % peer_id)
	
	if multiplayer.is_server():
		if players.has(peer_id):
			var p_name: String = players[peer_id].get("nickname", str(peer_id))
			_log_info("[SERVER] Player '%s' (ID %d) left the session." % [p_name, peer_id])
			players.erase(peer_id)
			player_left.emit(peer_id)
			player_list_updated.emit(players)
			# Broadcast updated player list to remaining clients
			s2c_sync_player_list.rpc(players)


func _on_connected_to_server() -> void:
	var my_id := multiplayer.get_unique_id()
	_log_info("[CLIENT] Successfully connected to server! Assigned Peer ID: %d" % my_id)
	_set_status("Connected to %s:%d (ID: %d)" % [current_ip, current_port, my_id])
	
	# Send registration handshake to authoritative server
	c2s_register_nickname.rpc_id(1, local_nickname)
	connected_to_server.emit()


func _on_connection_failed() -> void:
	_log_error("[CLIENT] Failed to connect to server at %s:%d" % [current_ip, current_port])
	_set_status("Connection failed to %s:%d" % [current_ip, current_port])
	disconnect_peer()
	connection_failed.emit("Server unreachable or connection rejected.")


func _on_server_disconnected() -> void:
	_log_warn("[CLIENT] Server disconnected or dropped the connection.")
	_set_status("Server disconnected")
	disconnect_peer()
	server_disconnected.emit()


# ==============================================================================
# AUTHORITATIVE RPC PROTOCOLS
# ==============================================================================
## Client -> Server: Register player's chosen nickname
@rpc("any_peer", "call_remote", "reliable")
func c2s_register_nickname(requested_nickname: String) -> void:
	if not multiplayer.is_server():
		return
	
	var sender_id := multiplayer.get_remote_sender_id()
	if sender_id <= 0:
		return
	
	# Sanitize nickname (strip whitespace, limit length, prevent empty)
	var clean_name := requested_nickname.strip_edges()
	if clean_name.is_empty():
		clean_name = "Player_%d" % sender_id
	if clean_name.length() > 20:
		clean_name = clean_name.substr(0, 20)
	
	# Ensure unique nickname display
	var final_name := clean_name
	var counter := 2
	for p_id in players:
		if p_id != sender_id and players[p_id].get("nickname") == final_name:
			final_name = "%s_%d" % [clean_name, counter]
			counter += 1
	
	players[sender_id] = {
		"peer_id": sender_id,
		"nickname": final_name,
		"role": "Client",
		"joined_at": Time.get_ticks_msec()
	}
	
	_log_info("[SERVER] Registered peer %d as '%s'. Total players: %d" % [sender_id, final_name, players.size()])
	
	# Emit locally on server
	player_joined.emit(sender_id, players[sender_id])
	player_list_updated.emit(players)
	
	# Broadcast full authoritative roster to all connected clients
	s2c_sync_player_list.rpc(players)


## Server -> All Clients: Synchronize player roster
@rpc("authority", "call_remote", "reliable")
func s2c_sync_player_list(synced_players: Dictionary) -> void:
	players = synced_players
	_log_info("[CLIENT] Synchronized player list. Count: %d" % players.size())
	player_list_updated.emit(players)


# ==============================================================================
# HELPERS & LOGGING
# ==============================================================================
func _set_status(new_status: String) -> void:
	connection_status = new_status
	status_changed.emit(connection_status)


func _log_info(msg: String) -> void:
	print("[%s] [NET-INFO] %s" % [_get_timestamp(), msg])


func _log_warn(msg: String) -> void:
	print("[%s] [NET-WARN] %s" % [_get_timestamp(), msg])


func _log_error(msg: String) -> void:
	printerr("[%s] [NET-ERROR] %s" % [_get_timestamp(), msg])


func _get_timestamp() -> String:
	var dt := Time.get_time_dict_from_system()
	return "%02d:%02d:%02d" % [dt.hour, dt.minute, dt.second]


# ==============================================================================
# COMMAND LINE AUTOMATION & HEADLESS DEDICATED SERVER PARSER
# ==============================================================================
func _parse_cmdline_arguments() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		args = OS.get_cmdline_args()
	
	var is_server_requested := false
	var is_client_requested := false
	var use_websocket := false
	var parsed_port := DEFAULT_PORT
	var parsed_ip := DEFAULT_IP
	var parsed_nick := ""
	var parsed_max := DEFAULT_MAX_PLAYERS
	
	var i := 0
	while i < args.size():
		var arg := args[i]
		match arg:
			"--server", "--dedicated-server":
				is_server_requested = true
			"--websocket", "--ws":
				use_websocket = true
			"--client":
				is_client_requested = true
			"--port":
				if i + 1 < args.size():
					parsed_port = int(args[i + 1])
					i += 1
			"--ip", "--connect":
				if i + 1 < args.size():
					parsed_ip = args[i + 1]
					i += 1
			"--nickname", "--nick", "--name":
				if i + 1 < args.size():
					parsed_nick = args[i + 1]
					i += 1
			"--max-players":
				if i + 1 < args.size():
					parsed_max = int(args[i + 1])
					i += 1
		i += 1
	
	# Automatically start server if --server or --dedicated-server was specified
	if is_server_requested:
		var proto_str := "WebSocket" if use_websocket else "UDP/ENet"
		_log_info("Command-line trigger: Starting Headless Dedicated Server on %s port %d..." % [proto_str, parsed_port])
		var err := start_server(parsed_port, parsed_max, true, "DedicatedServer", use_websocket)
		if err == OK:
			get_tree().change_scene_to_file(WORLD_SCENE_PATH)
	elif is_client_requested:
		if parsed_nick.is_empty():
			parsed_nick = "Player_%d" % (randi() % 900 + 100)
		_log_info("Command-line trigger: Connecting Client to %s:%d as '%s'..." % [parsed_ip, parsed_port, parsed_nick])
		start_client(parsed_ip, parsed_port, parsed_nick)
		get_tree().change_scene_to_file(WORLD_SCENE_PATH)
