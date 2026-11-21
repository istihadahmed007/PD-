# ==============================================================================
# SAVE & PERSISTENCE SYSTEM (MULTI-SLOT & SETTINGS ARCHITECTURE)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Supports multiple save slots (Slots 1-3, Autosave), player transforms,
#          economy ledger, inventory, owned vehicles & customizations, mission
#          progression, world time & weather, and user settings serialization.
# ==============================================================================
class_name SaveSystem
extends RefCounted

const DEFAULT_SAVE_PATH := "user://dta_savegame.json"
const SETTINGS_PATH := "user://dta_settings.json"

const SLOT_PATHS := {
	0: "user://dta_save_autosave.json",
	1: "user://dta_save_slot_1.json",
	2: "user://dta_save_slot_2.json",
	3: "user://dta_save_slot_3.json"
}

static var active_slot: int = 1


static func get_save_path(slot_id: int = -1) -> String:
	var s = slot_id if slot_id >= 0 else active_slot
	return SLOT_PATHS.get(s, DEFAULT_SAVE_PATH)


static func save_game(slot_or_pos = null, arg2 = null, arg3 = null, arg4 = null) -> bool:
	var slot_id: int = active_slot
	var player_pos: Vector3 = Vector3.ZERO
	var player_rot_y: float = 0.0
	var wallet: int = -1
	var wanted: int = -1
	var completed_missions: Array = []
	
	# Handle flexible calling signatures:
	# 1. save_game(slot_id: int, pos: Vector3, wallet, ...)
	# 2. save_game(pos: Vector3, wallet, wanted, completed)
	if slot_or_pos is int:
		slot_id = slot_or_pos
		if arg2 is Vector3:
			player_pos = arg2
		elif GameManager.active_player:
			player_pos = GameManager.active_player.global_position
			player_rot_y = GameManager.active_player.rotation.y
		if arg3 is int: wallet = arg3
		if arg4 is Array: completed_missions = arg4
	elif slot_or_pos is Vector3:
		player_pos = slot_or_pos
		if GameManager.active_player:
			player_rot_y = GameManager.active_player.rotation.y
		if arg2 is int: wallet = arg2
		if arg3 is int: wanted = arg3
		if arg4 is Array: completed_missions = arg4
	elif GameManager.active_player:
		player_pos = GameManager.active_player.global_position
		player_rot_y = GameManager.active_player.rotation.y
		
	active_slot = slot_id
	var save_path = get_save_path(slot_id)
	
	var final_wallet = wallet if wallet >= 0 else GameManager.wallet_bdt
	var final_wanted = wanted if wanted >= 0 else GameManager.wanted_stars
	
	# Query World State
	var world_hours: float = 14.0
	var world_weather: String = "SUNNY"
	var world_wetness: float = 0.0
	
	# Check for running weather system
	var root = Engine.get_main_loop() as SceneTree
	if root and root.root:
		var ws = root.root.find_child("WeatherSystem", true, false)
		if ws:
			world_hours = ws.current_time_hours
			world_weather = WeatherSystem.WeatherType.keys()[ws.current_weather]
			world_wetness = ws.wetness_intensity
	
	# Query Missions
	var active_mission_id := ""
	var active_step_idx := 0
	if root and root.root:
		var ms = root.root.find_child("MissionSystem", true, false)
		if ms:
			active_mission_id = ms.active_mission_id
			active_step_idx = ms.current_step_index
			if completed_missions.is_empty():
				completed_missions = ms.completed_mission_ids
	
	var save_dict := {
		"version": 3,
		"slot_id": slot_id,
		"timestamp": Time.get_datetime_string_from_system(false, true),
		"player": {
			"pos_x": player_pos.x,
			"pos_y": player_pos.y,
			"pos_z": player_pos.z,
			"rot_y": player_rot_y,
			"outfit": GameManager.current_outfit
		},
		"economy": {
			"wallet_bdt": final_wallet,
			"bank_bdt": GameManager.bank_bdt,
			"transactions": GameManager.transaction_history,
			"inventory": GameManager.inventory.serialize(),
			"properties": GameManager.owned_properties
		},
		"vehicles": {
			"customs": GameManager.active_vehicle_customs
		},
		"police": {
			"wanted_stars": final_wanted
		},
		"missions": {
			"active_id": active_mission_id,
			"step_index": active_step_idx,
			"completed": completed_missions
		},
		"world": {
			"time_hours": world_hours,
			"weather": world_weather,
			"wetness": world_wetness
		}
	}
	
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to open save file: " + save_path)
		return false
	
	file.store_string(JSON.stringify(save_dict, "\t"))
	file.close()
	
	# Also maintain default savegame.json copy for backwards compatibility
	if slot_id == 1:
		var def_file := FileAccess.open(DEFAULT_SAVE_PATH, FileAccess.WRITE)
		if def_file:
			def_file.store_string(JSON.stringify(save_dict, "\t"))
			def_file.close()
			
	return true


static func load_game(slot_id: int = -1) -> Dictionary:
	var s = slot_id if slot_id >= 0 else active_slot
	var save_path = get_save_path(s)
	
	if not FileAccess.file_exists(save_path):
		if s == 1 and FileAccess.file_exists(DEFAULT_SAVE_PATH):
			save_path = DEFAULT_SAVE_PATH
		else:
			return {}
	
	var file := FileAccess.open(save_path, FileAccess.READ)
	if not file:
		return {}
	
	var text := file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(text) != OK:
		push_error("JSON Parse Error in " + save_path)
		return {}
	
	var data = json.data if json.data is Dictionary else {}
	if not data.is_empty():
		active_slot = s
		apply_loaded_state(data)
	return data


static func get_slot_info(slot_id: int) -> Dictionary:
	var path = get_save_path(slot_id)
	if not FileAccess.file_exists(path):
		if slot_id == 1 and FileAccess.file_exists(DEFAULT_SAVE_PATH):
			path = DEFAULT_SAVE_PATH
		else:
			return {"exists": false, "name": "Empty Slot"}
			
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return {"exists": false, "name": "Empty Slot"}
	var text := file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(text) != OK or not (json.data is Dictionary):
		return {"exists": false, "name": "Corrupted Save"}
		
	var d: Dictionary = json.data
	var ts = d.get("timestamp", "Unknown Date")
	var econ = d.get("economy", {})
	var wallet = econ.get("wallet_bdt", 0)
	var missions = d.get("missions", {})
	var m_id = missions.get("active_id", "")
	var m_title = m_id if m_id != "" else "Free Roam"
	
	return {
		"exists": true,
		"slot_id": slot_id,
		"timestamp": ts,
		"wallet": wallet,
		"mission": m_title,
		"summary": "৳%s | %s | %s" % [EconomySystem.format_bdt(wallet), m_title, ts]
	}


static func apply_loaded_state(data: Dictionary, player_node: Node = null) -> void:
	# 1. Economy State
	var econ = data.get("economy", {})
	if not econ.is_empty():
		GameManager.wallet_bdt = econ.get("wallet_bdt", 5000)
		GameManager.bank_bdt = econ.get("bank_bdt", 25000)
		EventBus.money_changed.emit(GameManager.wallet_bdt, 0)
		EventBus.bank_balance_changed.emit(GameManager.bank_bdt, 0)
		
		var tx = econ.get("transactions", [])
		GameManager.transaction_history.clear()
		for t in tx:
			GameManager.transaction_history.append(t)
			
		var inv_data = econ.get("inventory", [])
		if not inv_data.is_empty():
			GameManager.inventory.deserialize(inv_data)
			
		var props = econ.get("properties", [])
		GameManager.owned_properties.clear()
		for p in props:
			GameManager.owned_properties.append(p)
	
	# 2. Player State
	var p_data = data.get("player", {})
	if not p_data.is_empty():
		var outfit_id = p_data.get("outfit", "dhaka_casual")
		GameManager.equip_outfit(outfit_id)
		
		var p = player_node if player_node else GameManager.active_player
		if p:
			var px = p_data.get("pos_x", p.global_position.x)
			var py = p_data.get("pos_y", p.global_position.y)
			var pz = p_data.get("pos_z", p.global_position.z)
			var ry = p_data.get("rot_y", p.rotation.y)
			p.global_position = Vector3(px, py, pz)
			p.rotation.y = ry
	
	# 3. Police Wanted Stars
	var police = data.get("police", {})
	if not police.is_empty():
		var stars = police.get("wanted_stars", 0)
		GameManager.set_wanted_level(stars)
		
	# 4. Vehicles
	var veh = data.get("vehicles", {})
	if not veh.is_empty():
		var customs = veh.get("customs", {})
		for k in customs:
			GameManager.active_vehicle_customs[k] = customs[k]
			
	# 5. World State (Weather & Time)
	var world = data.get("world", {})
	if not world.is_empty():
		var root = Engine.get_main_loop() as SceneTree
		if root and root.root:
			var ws = root.root.find_child("WeatherSystem", true, false)
			if ws:
				ws.current_time_hours = world.get("time_hours", 14.0)
				var w_str = world.get("weather", "SUNNY")
				if WeatherSystem.WeatherType.has(w_str):
					ws.set_weather(WeatherSystem.WeatherType[w_str])
					
	# 6. Missions
	var miss = data.get("missions", {})
	if not miss.is_empty():
		var root = Engine.get_main_loop() as SceneTree
		if root and root.root:
			var ms = root.root.find_child("MissionSystem", true, false)
			if ms:
				var comp = miss.get("completed", [])
				ms.completed_mission_ids.clear()
				for c in comp: ms.completed_mission_ids.append(c)


# ------------------------------------------------------------------------------
# SETTINGS PERSISTENCE
# ------------------------------------------------------------------------------
static func save_settings(settings: Dictionary) -> bool:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if not file:
		return false
	file.store_string(JSON.stringify(settings, "\t"))
	file.close()
	apply_settings(settings)
	return true


static func load_settings() -> Dictionary:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return get_default_settings()
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if not file:
		return get_default_settings()
	var text := file.get_as_text()
	file.close()
	var json = JSON.new()
	if json.parse(text) != OK or not (json.data is Dictionary):
		return get_default_settings()
	return json.data


static func get_default_settings() -> Dictionary:
	return {
		"graphics": {
			"quality_preset": 2, # High
			"window_mode": 0,    # 0: Windowed, 1: Fullscreen
			"fps_limit": 60,
			"vsync": true
		},
		"audio": {
			"master_volume": 1.0,
			"music_volume": 0.8,
			"sfx_volume": 0.85,
			"ambiance_volume": 0.75
		},
		"controls": {
			"mouse_sensitivity": 1.0,
			"invert_y": false
		}
	}


static func apply_settings(settings: Dictionary) -> void:
	# 1. Audio
	var audio = settings.get("audio", {})
	if not audio.is_empty():
		AudioManager.master_volume = audio.get("master_volume", 1.0)
		AudioManager.music_volume = audio.get("music_volume", 0.8)
		AudioManager.sfx_volume = audio.get("sfx_volume", 0.85)
		AudioManager.ambiance_volume = audio.get("ambiance_volume", 0.75)
		AudioManager.apply_volume_settings()
		
	# 2. Graphics Display Mode
	var gfx = settings.get("graphics", {})
	if not gfx.is_empty():
		var win_mode = gfx.get("window_mode", 0)
		if win_mode == 1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			
		var fps_lim = gfx.get("fps_limit", 60)
		Engine.max_fps = fps_lim
		
		# Quality Preset
		var q_preset = gfx.get("quality_preset", 2)
		var root = Engine.get_main_loop() as SceneTree
		if root and root.root:
			var ws = root.root.find_child("WeatherSystem", true, false)
			if ws:
				ws.apply_quality_preset(q_preset as WeatherSystem.GraphicsQuality)
