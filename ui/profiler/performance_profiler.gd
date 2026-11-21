# ==============================================================================
# PERFORMANCE PROFILER & GRAPHICS BENCHMARK DASHBOARD
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Real-time FPS, frame time (ms), memory, active entities, graphics presets
#          (Low, Medium, High), live weather switching, and time controls.
# ==============================================================================
class_name PerformanceProfiler
extends CanvasLayer

@onready var telemetry_label: Label = $Panel/VBox/TelemetryLabel
@onready var weather_system: WeatherSystem = null

# Quality buttons
@onready var btn_low: Button = $Panel/VBox/QualityBox/BtnLow
@onready var btn_med: Button = $Panel/VBox/QualityBox/BtnMed
@onready var btn_high: Button = $Panel/VBox/QualityBox/BtnHigh

# Weather buttons
@onready var btn_sunny: Button = $Panel/VBox/WeatherBox/BtnSunny
@onready var btn_cloudy: Button = $Panel/VBox/WeatherBox/BtnCloudy
@onready var btn_rain: Button = $Panel/VBox/WeatherBox/BtnRain
@onready var btn_fog: Button = $Panel/VBox/WeatherBox/BtnFog
@onready var btn_storm: Button = $Panel/VBox/WeatherBox/BtnStorm

# Time buttons
@onready var btn_dawn: Button = $Panel/VBox/TimeBox/BtnDawn
@onready var btn_noon: Button = $Panel/VBox/TimeBox/BtnNoon
@onready var btn_sunset: Button = $Panel/VBox/TimeBox/BtnSunset
@onready var btn_night: Button = $Panel/VBox/TimeBox/BtnNight
@onready var btn_speed: Button = $Panel/VBox/TimeBox/BtnSpeed

var _fps_samples: Array[float] = []


func _ready() -> void:
	layer = 16
	_connect_buttons()


func _connect_buttons() -> void:
	if btn_low: btn_low.pressed.connect(func(): _set_quality(WeatherSystem.GraphicsQuality.LOW))
	if btn_med: btn_med.pressed.connect(func(): _set_quality(WeatherSystem.GraphicsQuality.MEDIUM))
	if btn_high: btn_high.pressed.connect(func(): _set_quality(WeatherSystem.GraphicsQuality.HIGH))
	
	if btn_sunny: btn_sunny.pressed.connect(func(): _set_weather(WeatherSystem.WeatherType.SUNNY))
	if btn_cloudy: btn_cloudy.pressed.connect(func(): _set_weather(WeatherSystem.WeatherType.CLOUDY))
	if btn_rain: btn_rain.pressed.connect(func(): _set_weather(WeatherSystem.WeatherType.MONSOON_RAIN))
	if btn_fog: btn_fog.pressed.connect(func(): _set_weather(WeatherSystem.WeatherType.FOG))
	if btn_storm: btn_storm.pressed.connect(func(): _set_weather(WeatherSystem.WeatherType.THUNDERSTORM))
	
	if btn_dawn: btn_dawn.pressed.connect(func(): _set_time(6.0))
	if btn_noon: btn_noon.pressed.connect(func(): _set_time(12.5))
	if btn_sunset: btn_sunset.pressed.connect(func(): _set_time(18.5))
	if btn_night: btn_night.pressed.connect(func(): _set_time(23.5))
	if btn_speed:
		btn_speed.pressed.connect(func():
			if _find_weather_system():
				var spd = weather_system.time_speed_multiplier
				weather_system.time_speed_multiplier = 5.0 if spd == 1.0 else (0.0 if spd == 5.0 else 1.0)
				btn_speed.text = "Speed: %s" % ("x5" if weather_system.time_speed_multiplier == 5.0 else ("Paused" if weather_system.time_speed_multiplier == 0.0 else "x1"))
		)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F3:
			visible = not visible
			get_viewport().set_input_as_handled()


func _find_weather_system() -> WeatherSystem:
	if not weather_system:
		weather_system = get_tree().current_scene.get_node_or_null("WeatherSystem") as WeatherSystem
		if not weather_system:
			weather_system = get_tree().root.find_child("WeatherSystem", true, false) as WeatherSystem
	return weather_system


func _set_quality(q: WeatherSystem.GraphicsQuality) -> void:
	if _find_weather_system():
		weather_system.apply_quality_preset(q)


func _set_weather(w: WeatherSystem.WeatherType) -> void:
	if _find_weather_system():
		weather_system.set_weather(w)


func _set_time(hours: float) -> void:
	if _find_weather_system():
		weather_system.current_time_hours = hours


func _process(delta: float) -> void:
	if not visible or not telemetry_label:
		return
		
	var fps = Engine.get_frames_per_second()
	var frame_ms = delta * 1000.0
	
	var ws = _find_weather_system()
	var cur_w := "N/A"
	var cur_time := "12:00"
	var wetness := 0.0
	if ws:
		cur_w = WeatherSystem.WeatherType.keys()[ws.current_weather]
		var h = int(ws.current_time_hours)
		var m = int(fmod(ws.current_time_hours * 60.0, 60.0))
		cur_time = "%02d:%02d" % [h, m]
		wetness = ws.wetness_intensity
		
	var mem_mb = float(OS.get_static_memory_usage()) / (1024.0 * 1024.0)
	var tiles_count = get_tree().get_nodes_in_group("world_tiles").size()
	var peds_count = get_tree().get_nodes_in_group("pedestrians").size()
	var vehs_count = get_tree().get_nodes_in_group("vehicles").size()
	
	var t := "=== REAL-TIME HARDWARE PROFILER ===\n"
	t += "Framerate: %d FPS  |  Frame Time: %.2f ms\n" % [fps, frame_ms]
	t += "Memory Usage: %.1f MB (Static RAM)\n" % mem_mb
	t += "Clock Time: %s  |  Weather: %s\n" % [cur_time, cur_w]
	t += "Road Wetness: %d%%  |  Puddles: Active\n" % int(wetness * 100.0)
	t += "Entities: Chunks: %d | Pedestrians: %d | Vehicles: %d\n" % [tiles_count, peds_count, vehs_count]
	t += "[F3] Toggle Profiler Overlay\n"
	
	telemetry_label.text = t
