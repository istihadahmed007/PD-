# ==============================================================================
# AUDIO MANAGER (AUTOLOAD)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Master sound dispatcher, audio bus volume controls, footstep manager,
#          radio station streamer, and dynamic soundtrack playback.
# ==============================================================================
extends Node

enum RadioStation {
	OFF,
	RADIO_PADMA,     # Bengali Band & Rock
	DHAKA_BEATS,     # Desi Hip-hop & Urban
	SURMA_FOLK,      # Baul & Traditional
	KOTHA_FM         # Satire Talk Radio
}

var current_station: RadioStation = RadioStation.OFF
var is_radio_playing: bool = false

var _ambiance_player: AudioStreamPlayer = null
var _music_player: AudioStreamPlayer = null
var _radio_player: AudioStreamPlayer = null

# Settings volumes (0.0 to 1.0)
var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 0.85
var ambiance_volume: float = 0.75

# Cached audio streams
var _footsteps_asphalt: Array[AudioStream] = []
var _footsteps_puddle: Array[AudioStream] = []
var _snd_jump: AudioStream = null
var _snd_land: AudioStream = null

var _radio_tracks := {
	RadioStation.RADIO_PADMA: "res://audio/music/radio_padma_rock.wav",
	RadioStation.DHAKA_BEATS: "res://audio/music/dhaka_beats_hiphop.wav",
	RadioStation.SURMA_FOLK: "res://audio/music/surma_folk.wav"
}


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	_setup_audio_players()
	_load_sound_effects()
	apply_volume_settings()


func _setup_audio_players() -> void:
	_ambiance_player = AudioStreamPlayer.new()
	_ambiance_player.name = "AmbiancePlayer"
	_ambiance_player.bus = "Master"
	add_child(_ambiance_player)
	
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	_music_player.bus = "Master"
	add_child(_music_player)
	
	_radio_player = AudioStreamPlayer.new()
	_radio_player.name = "RadioPlayer"
	_radio_player.bus = "Master"
	add_child(_radio_player)


func _load_sound_effects() -> void:
	for i in range(1, 5):
		var path = "res://audio/player/footstep_asphalt_%d.wav" % i
		if ResourceLoader.exists(path):
			_footsteps_asphalt.append(load(path))
			
	for i in range(1, 3):
		var path = "res://audio/player/footstep_puddle_%d.wav" % i
		if ResourceLoader.exists(path):
			_footsteps_puddle.append(load(path))
			
	if ResourceLoader.exists("res://audio/player/jump_effort.wav"):
		_snd_jump = load("res://audio/player/jump_effort.wav")
	if ResourceLoader.exists("res://audio/player/land_impact.wav"):
		_snd_land = load("res://audio/player/land_impact.wav")


func play_sfx(path: String, volume_offset_db: float = 0.0) -> void:
	if ResourceLoader.exists(path):
		var stream := load(path) as AudioStream
		play_sound_2d(stream, volume_offset_db)


func play_footstep(is_wet: bool = false, volume_db: float = -6.0) -> void:
	var stream: AudioStream = null
	if is_wet and not _footsteps_puddle.is_empty():
		stream = _footsteps_puddle.pick_random()
	elif not _footsteps_asphalt.is_empty():
		stream = _footsteps_asphalt.pick_random()
		
	if stream:
		play_sound_2d(stream, volume_db)


func play_jump() -> void:
	if _snd_jump:
		play_sound_2d(_snd_jump, -4.0)


func play_land() -> void:
	if _snd_land:
		play_sound_2d(_snd_land, -2.0)


func play_sound_2d(stream: AudioStream, volume_offset_db: float = 0.0) -> void:
	if not stream:
		return
	var p := AudioStreamPlayer.new()
	p.stream = stream
	var base_db = linear_to_db(max(0.001, sfx_volume * master_volume))
	p.volume_db = base_db + volume_offset_db
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)


func play_sound_3d(stream: AudioStream, position: Vector3, _bus: String = "Master", volume_db: float = 0.0) -> void:
	if not stream:
		return
	var player := AudioStreamPlayer3D.new()
	player.stream = stream
	var base_db = linear_to_db(max(0.001, sfx_volume * master_volume))
	player.volume_db = base_db + volume_db
	player.global_position = position
	get_tree().root.add_child(player)
	player.play()
	player.finished.connect(player.queue_free)


func play_main_theme() -> void:
	if _music_player and ResourceLoader.exists("res://audio/music/main_theme.wav"):
		_music_player.stream = load("res://audio/music/main_theme.wav")
		var vol = linear_to_db(max(0.001, music_volume * master_volume))
		_music_player.volume_db = vol
		_music_player.play()


func stop_music() -> void:
	if _music_player and _music_player.playing:
		_music_player.stop()


func cycle_radio_station() -> String:
	var next_idx = (int(current_station) + 1) % RadioStation.size()
	current_station = RadioStation.values()[next_idx]
	_update_radio_playback()
	return get_station_name(current_station)


func set_radio_station(station: RadioStation) -> void:
	current_station = station
	_update_radio_playback()


func _update_radio_playback() -> void:
	if current_station == RadioStation.OFF:
		if _radio_player and _radio_player.playing:
			_radio_player.stop()
		return
		
	var path: String = _radio_tracks.get(current_station, "")
	if path != "" and ResourceLoader.exists(path) and _radio_player:
		_radio_player.stream = load(path)
		var vol = linear_to_db(max(0.001, music_volume * master_volume))
		_radio_player.volume_db = vol
		_radio_player.play()


func get_station_name(station: RadioStation) -> String:
	match station:
		RadioStation.OFF: return "Radio: OFF"
		RadioStation.RADIO_PADMA: return "Radio Padma 99.2 (Bangla Rock)"
		RadioStation.DHAKA_BEATS: return "Dhaka Beats 104.5 (Desi Hip-Hop)"
		RadioStation.SURMA_FOLK: return "Surma Folk 88.0 (Baul Classics)"
		RadioStation.KOTHA_FM: return "Kotha FM 92.4 (Dhaka Gossip & News)"
	return "Radio"


func apply_volume_settings() -> void:
	if _music_player and _music_player.playing:
		_music_player.volume_db = linear_to_db(max(0.001, music_volume * master_volume))
	if _radio_player and _radio_player.playing:
		_radio_player.volume_db = linear_to_db(max(0.001, music_volume * master_volume))
	if _ambiance_player and _ambiance_player.playing:
		_ambiance_player.volume_db = linear_to_db(max(0.001, ambiance_volume * master_volume))
