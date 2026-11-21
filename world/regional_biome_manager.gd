# ==============================================================================
# REGIONAL BIOME & ENVIRONMENT TRANSITION MANAGER
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Detects active geographical region, cross-fades ambient audio streams,
#          and smoothly transitions WorldEnvironment lighting, sky, and volumetric fog.
# ==============================================================================
class_name RegionalBiomeManager
extends Node

signal region_changed(region_id: String, region_title: String, bangla_title: String)

const BIOMES := {
	"dhaka": {
		"title": "Metropolitan Dhaka",
		"bangla": "মেট্রোপলিটন ঢাকা",
		"audio_path": "res://audio/ambient/ambient_dhaka_city.wav",
		"ambient_color": Color(0.68, 0.65, 0.62, 1.0),
		"fog_density": 0.003,
		"fog_color": Color(0.72, 0.70, 0.68, 1.0)
	},
	"rajshahi": {
		"title": "Rajshahi & Padma Delta",
		"bangla": "রাজশাহী ও পদ্মা অববাহিকা",
		"audio_path": "res://audio/ambient/ambient_padma_river.wav",
		"ambient_color": Color(0.72, 0.75, 0.78, 1.0),
		"fog_density": 0.002,
		"fog_color": Color(0.75, 0.80, 0.85, 1.0)
	},
	"sylhet": {
		"title": "Sylhet Tea Gardens & Wetlands",
		"bangla": "সিলেট চা বাগান ও হাওর",
		"audio_path": "res://audio/ambient/ambient_sylhet_hills.wav",
		"ambient_color": Color(0.60, 0.74, 0.65, 1.0),
		"fog_density": 0.006,
		"fog_color": Color(0.65, 0.78, 0.70, 1.0)
	},
	"chattogram": {
		"title": "Chattogram Maritime Port",
		"bangla": "চট্টগ্রাম সমুদ্র বন্দর",
		"audio_path": "res://audio/ambient/ambient_chattogram_port.wav",
		"ambient_color": Color(0.62, 0.66, 0.72, 1.0),
		"fog_density": 0.004,
		"fog_color": Color(0.68, 0.72, 0.78, 1.0)
	},
	"cox_bazar": {
		"title": "Cox's Bazar Coastal Marine Strip",
		"bangla": "কক্সবাজার মেরিন ড্রাইভ",
		"audio_path": "res://audio/ambient/ambient_cox_ocean.wav",
		"ambient_color": Color(0.78, 0.75, 0.68, 1.0),
		"fog_density": 0.002,
		"fog_color": Color(0.82, 0.80, 0.75, 1.0)
	},
	"sundarbans": {
		"title": "Sundarbans Mangrove Delta",
		"bangla": "সুন্দরবন ম্যানগ্রোভ বন",
		"audio_path": "res://audio/ambient/ambient_sundarbans_jungle.wav",
		"ambient_color": Color(0.50, 0.65, 0.52, 1.0),
		"fog_density": 0.008,
		"fog_color": Color(0.55, 0.68, 0.58, 1.0)
	},
	"rural_plains": {
		"title": "Rural Agricultural Floodplains",
		"bangla": "পল্লী কৃষি অঞ্চল",
		"audio_path": "res://audio/ambient/ambient_rural_fields.wav",
		"ambient_color": Color(0.72, 0.72, 0.62, 1.0),
		"fog_density": 0.002,
		"fog_color": Color(0.78, 0.78, 0.72, 1.0)
	}
}

var current_region: String = "dhaka"
var world_environment: WorldEnvironment = null

var _audio_player_a: AudioStreamPlayer = null
var _audio_player_b: AudioStreamPlayer = null
var _active_player_is_a: bool = true


func _ready() -> void:
	_setup_audio_players()


func _setup_audio_players() -> void:
	_audio_player_a = AudioStreamPlayer.new()
	_audio_player_a.name = "AmbientPlayerA"
	_audio_player_a.bus = "Master"
	add_child(_audio_player_a)
	
	_audio_player_b = AudioStreamPlayer.new()
	_audio_player_b.name = "AmbientPlayerB"
	_audio_player_b.bus = "Master"
	add_child(_audio_player_b)


func update_player_region(player_pos: Vector3, world_env: WorldEnvironment = null) -> void:
	world_environment = world_env
	var new_region := determine_region_from_position(player_pos)
	
	if new_region != current_region:
		transition_to_region(new_region)


func determine_region_from_position(pos: Vector3) -> String:
	# Continuous World Map Region Coordinate Bounds
	var x := pos.x
	var z := pos.z
	
	if x > 256.0 and z > 256.0:
		return "sylhet"
	elif x > 256.0 and z < -768.0:
		return "cox_bazar"
	elif x > 256.0 and z <= 256.0 and z >= -768.0:
		return "chattogram"
	elif x < -256.0 and z < -384.0:
		return "sundarbans"
	elif x < -768.0:
		return "rajshahi"
	elif x <= -256.0 and x >= -768.0:
		return "rural_plains"
	else:
		return "dhaka"


func transition_to_region(new_region: String) -> void:
	if not BIOMES.has(new_region):
		return
		
	var prev = current_region
	current_region = new_region
	var data: Dictionary = BIOMES[new_region]
	
	# Cross-fade Ambient Audio
	_crossfade_ambient(data["audio_path"])
	
	# Transition Environment
	if world_environment and world_environment.environment:
		var env = world_environment.environment
		var tween = create_tween().set_parallel(true)
		tween.tween_property(env, "ambient_light_color", data["ambient_color"], 2.5)
		if env.volumetric_fog_enabled:
			tween.tween_property(env, "volumetric_fog_density", data["fog_density"], 2.5)
			tween.tween_property(env, "volumetric_fog_albedo", data["fog_color"], 2.5)
			
	region_changed.emit(new_region, data["title"], data["bangla"])


func _crossfade_ambient(stream_path: String) -> void:
	var stream = load(stream_path) as AudioStream
	if not stream:
		return
		
	var fade_in_player = _audio_player_b if _active_player_is_a else _audio_player_a
	var fade_out_player = _audio_player_a if _active_player_is_a else _audio_player_b
	_active_player_is_a = not _active_player_is_a
	
	fade_in_player.stream = stream
	fade_in_player.volume_db = -40.0
	fade_in_player.play()
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(fade_in_player, "volume_db", -6.0, 2.0)
	tween.tween_property(fade_out_player, "volume_db", -40.0, 2.0)
	tween.chain().tween_callback(fade_out_player.stop)
