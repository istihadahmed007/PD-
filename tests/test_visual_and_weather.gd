# ==============================================================================
# TEST VISUAL QUALITY, WEATHER & OPTIMIZATION (PLAYABLE HARNESS)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Comprehensive diagnostic harness for Part 09:
#          - Realistic PBR materials (Roads, buildings, water, foliage)
#          - Natural 4-split CSM shadows, SSAO, and SSR reflections
#          - 5 Weather systems (Sunny, Cloudy, Monsoon Rain, Fog, Thunderstorm)
#          - Dynamic 24-hour sun/moon lighting & automated night streetlights
#          - Real-time hardware profiler with Low, Medium, High quality presets
# ==============================================================================
extends Node3D

@onready var player: Player = $Player if has_node("Player") else null
@onready var weather_system: WeatherSystem = $WeatherSystem if has_node("WeatherSystem") else null
@onready var profiler: PerformanceProfiler = $PerformanceProfiler if has_node("PerformanceProfiler") else null
@onready var test_sedan: BaseVehicle3D = $Sedan if has_node("Sedan") else null

var current_quality_idx: int = 2 # High


func _ready() -> void:
	if weather_system:
		weather_system.set_weather(WeatherSystem.WeatherType.SUNNY)
		weather_system.apply_quality_preset(WeatherSystem.GraphicsQuality.HIGH)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
		
	match event.keycode:
		KEY_1:
			if weather_system: weather_system.set_weather(WeatherSystem.WeatherType.SUNNY)
		KEY_2:
			if weather_system: weather_system.set_weather(WeatherSystem.WeatherType.CLOUDY)
		KEY_3:
			if weather_system: weather_system.set_weather(WeatherSystem.WeatherType.MONSOON_RAIN)
		KEY_4:
			if weather_system: weather_system.set_weather(WeatherSystem.WeatherType.FOG)
		KEY_5:
			if weather_system: weather_system.set_weather(WeatherSystem.WeatherType.THUNDERSTORM)
		KEY_6:
			if weather_system: weather_system.current_time_hours = 6.0 # Dawn
		KEY_7:
			if weather_system: weather_system.current_time_hours = 12.0 # Noon
		KEY_8:
			if weather_system: weather_system.current_time_hours = 18.5 # Sunset
		KEY_9:
			if weather_system: weather_system.current_time_hours = 23.5 # Night
		KEY_Q:
			current_quality_idx = (current_quality_idx + 1) % 3
			if weather_system:
				weather_system.apply_quality_preset(current_quality_idx as WeatherSystem.GraphicsQuality)
				var q_name = ["Low", "Medium", "High / Ultra"][current_quality_idx]
				EventBus.mission_objective_updated.emit(1, "Graphics Preset Switched to: %s" % q_name)
		KEY_C:
			if player and test_sedan:
				test_sedan.global_position = player.global_position + (player.global_transform.basis.x * 4.0)
				test_sedan.linear_velocity = Vector3.ZERO
		KEY_K:
			var p_pos = player.global_position if player else Vector3.ZERO
			SaveSystem.save_game(p_pos)
			EventBus.mission_objective_updated.emit(1, "Visual and world state saved to savegame.json")
		KEY_L:
			SaveSystem.load_game()
			EventBus.mission_objective_updated.emit(1, "Visual and world state restored")
