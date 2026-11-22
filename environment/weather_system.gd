# ==============================================================================
# WEATHER, ATMOSPHERE & TIME-OF-DAY SYSTEM (GRAPHICS & PERFORMANCE)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Dynamic 24-hour sun/moon lighting, 5 weather systems (Sunny, Cloudy,
#          Monsoon Rain, Fog, Thunderstorm), wet road PBR shaders, dynamic
#          streetlights/building lights, and PC hardware graphics presets.
# ==============================================================================
class_name WeatherSystem
extends Node3D

enum WeatherType {
	SUNNY,
	CLOUDY,
	MONSOON_RAIN,
	FOG,
	THUNDERSTORM
}

enum GraphicsQuality {
	LOW,
	MEDIUM,
	HIGH
}

@export_category("Time of Day")
@export var current_time_hours: float = 14.0 # 0.0 to 24.0
@export var day_cycle_length_minutes: float = 24.0
@export var is_time_paused: bool = false
@export var time_speed_multiplier: float = 1.0

@export_category("Weather Condition")
@export var current_weather: WeatherType = WeatherType.SUNNY

@export_category("Node Bindings")
@export var sun_light: DirectionalLight3D
@export var world_env: WorldEnvironment
@export var rain_particles: GPUParticles3D

# Internal Weather State
var is_raining: bool = false
var wetness_intensity: float = 0.0
var _lightning_timer: float = 0.0
var _next_lightning_interval: float = 6.0
var _is_lightning_flash: bool = false

# Audio players
var _audio_rain: AudioStreamPlayer = null
var _audio_thunder: AudioStreamPlayer = null
var _audio_wind: AudioStreamPlayer = null

# Night state tracking
var _is_night_lights_active: bool = false


func _ready() -> void:
	_setup_weather_audio()
	set_weather(current_weather)
	if OS.has_feature("web"):
		apply_quality_preset(GraphicsQuality.LOW)
	else:
		apply_quality_preset(GraphicsQuality.HIGH)


func _setup_weather_audio() -> void:
	_audio_rain = AudioStreamPlayer.new()
	_audio_rain.name = "RainAudioPlayer"
	_audio_rain.stream = load("res://audio/weather/rain_monsoon_loop.wav")
	_audio_rain.volume_db = -10.0
	add_child(_audio_rain)
	
	_audio_thunder = AudioStreamPlayer.new()
	_audio_thunder.name = "ThunderAudioPlayer"
	_audio_thunder.volume_db = -4.0
	add_child(_audio_thunder)
	
	_audio_wind = AudioStreamPlayer.new()
	_audio_wind.name = "WindAudioPlayer"
	_audio_wind.stream = load("res://audio/weather/wind_storm.wav")
	_audio_wind.volume_db = -12.0
	add_child(_audio_wind)


func _process(delta: float) -> void:
	if not is_time_paused:
		# 24 hours in (day_cycle_length_minutes * 60) real seconds
		var hours_per_sec = (24.0 / (day_cycle_length_minutes * 60.0)) * time_speed_multiplier
		current_time_hours = fmod(current_time_hours + delta * hours_per_sec, 24.0)
		GameManager.current_time_hours = int(current_time_hours)
		GameManager.current_time_minutes = int(fmod(current_time_hours * 60.0, 60.0))
		
	_update_lighting_and_atmosphere(delta)
	_update_dynamic_streetlights()
	_update_weather_effects(delta)
	_notify_time()


func _update_lighting_and_atmosphere(_delta: float) -> void:
	if not sun_light:
		return
		
	# Calculate Sun Elevation & Azimuth
	var hour_norm = current_time_hours / 24.0 # 0.0 to 1.0
	var sun_elevation = (hour_norm * 360.0) - 90.0 # -90 (midnight) -> 0 (dawn) -> 90 (noon) -> 180 (sunset)
	
	sun_light.rotation_degrees.x = -sun_elevation
	sun_light.rotation_degrees.y = 35.0
	
	var is_daytime = current_time_hours >= 5.5 and current_time_hours <= 18.5
	
	# Determine Sun Color & Energy based on time
	var sun_col := Color(1.0, 0.96, 0.9)
	var sun_energy := 1.2
	
	if current_time_hours >= 5.0 and current_time_hours < 7.5:
		# Sunrise / Dawn
		var dawn_t = (current_time_hours - 5.0) / 2.5
		sun_col = Color(1.0, 0.65, 0.35).lerp(Color(1.0, 0.92, 0.8), dawn_t)
		sun_energy = lerpf(0.1, 1.2, dawn_t)
	elif current_time_hours >= 7.5 and current_time_hours < 17.0:
		# Midday
		sun_col = Color(1.0, 0.98, 0.92)
		sun_energy = 1.3
	elif current_time_hours >= 17.0 and current_time_hours <= 19.0:
		# Sunset / Dusk
		var dusk_t = (current_time_hours - 17.0) / 2.0
		sun_col = Color(1.0, 0.92, 0.8).lerp(Color(1.0, 0.42, 0.18), dusk_t)
		sun_energy = lerpf(1.2, 0.1, dusk_t)
	else:
		# Night Moon
		sun_col = Color(0.55, 0.68, 0.85)
		sun_energy = 0.15
		
	# Adjust for weather conditions
	match current_weather:
		WeatherType.CLOUDY:
			sun_energy *= 0.65
			sun_col = sun_col.lerp(Color(0.75, 0.78, 0.82), 0.5)
		WeatherType.MONSOON_RAIN:
			sun_energy *= 0.4
			sun_col = sun_col.lerp(Color(0.45, 0.52, 0.58), 0.7)
		WeatherType.FOG:
			sun_energy *= 0.35
		WeatherType.THUNDERSTORM:
			if _is_lightning_flash:
				sun_energy = 4.0
				sun_col = Color(0.9, 0.95, 1.0)
			else:
				sun_energy *= 0.25
				sun_col = Color(0.35, 0.40, 0.48)
				
	sun_light.light_color = sun_col
	sun_light.light_energy = sun_energy


func _update_dynamic_streetlights() -> void:
	var should_night_lights_be_on = (current_time_hours >= 18.0 or current_time_hours < 6.0)
	
	if should_night_lights_be_on != _is_night_lights_active:
		_is_night_lights_active = should_night_lights_be_on
		
		# Toggle all streetlights and building lights in scene tree
		var streetlights = get_tree().get_nodes_in_group("streetlights")
		for sl in streetlights:
			if sl is Light3D:
				sl.visible = _is_night_lights_active
			elif sl.has_node("SpotLight3D"):
				sl.get_node("SpotLight3D").visible = _is_night_lights_active
				
		var building_lights = get_tree().get_nodes_in_group("building_lights")
		for bl in building_lights:
			if bl is Light3D:
				bl.visible = _is_night_lights_active
				
		# Update pedestrian & traffic density for night hours
		var ped_density := 0.35 if _is_night_lights_active else 1.0
		var traffic_density := 0.4 if _is_night_lights_active else 1.0
		EventBus.simulation_density_changed.emit(ped_density, traffic_density)


func _update_weather_effects(delta: float) -> void:
	# Wet road smoothness transition
	var target_wetness := 1.0 if (current_weather == WeatherType.MONSOON_RAIN or current_weather == WeatherType.THUNDERSTORM) else 0.0
	wetness_intensity = lerpf(wetness_intensity, target_wetness, 0.5 * delta)
	
	# Propagate wetness to all PBR road materials in scene
	var roads = get_tree().get_nodes_in_group("pbr_roads")
	for r in roads:
		if r is CSGPrimitive3D and r.material is ShaderMaterial:
			r.material.set_shader_parameter("wetness_intensity", wetness_intensity)
		elif r is GeometryInstance3D and r.material_override is ShaderMaterial:
			r.material_override.set_shader_parameter("wetness_intensity", wetness_intensity)
	
	# Thunderstorm lightning simulation
	if current_weather == WeatherType.THUNDERSTORM:
		_lightning_timer += delta
		if _lightning_timer >= _next_lightning_interval:
			_lightning_timer = 0.0
			_next_lightning_interval = randf_range(5.0, 11.0)
			_trigger_lightning_flash()


func _trigger_lightning_flash() -> void:
	_is_lightning_flash = true
	
	# Play randomized thunder strike
	if _audio_thunder:
		var sound = "res://audio/weather/thunder_strike_1.wav" if randf() < 0.5 else "res://audio/weather/thunder_strike_2.wav"
		_audio_thunder.stream = load(sound)
		_audio_thunder.play()
		
	await get_tree().create_timer(0.09).timeout
	_is_lightning_flash = false


func set_weather(type: WeatherType) -> void:
	current_weather = type
	
	var is_storm = (type == WeatherType.MONSOON_RAIN or type == WeatherType.THUNDERSTORM)
	if rain_particles:
		rain_particles.emitting = is_storm
		
	if _audio_rain:
		if is_storm and not _audio_rain.playing:
			_audio_rain.play()
		elif not is_storm and _audio_rain.playing:
			_audio_rain.stop()
			
	if _audio_wind:
		if type == WeatherType.THUNDERSTORM and not _audio_wind.playing:
			_audio_wind.play()
		elif type != WeatherType.THUNDERSTORM and _audio_wind.playing:
			_audio_wind.stop()
			
	# Update Volumetric Fog based on weather
	if world_env and world_env.environment:
		var env = world_env.environment
		match type:
			WeatherType.SUNNY:
				env.volumetric_fog_density = 0.001
				env.volumetric_fog_albedo = Color(0.72, 0.70, 0.68)
			WeatherType.CLOUDY:
				env.volumetric_fog_density = 0.003
				env.volumetric_fog_albedo = Color(0.68, 0.70, 0.75)
			WeatherType.MONSOON_RAIN:
				env.volumetric_fog_density = 0.007
				env.volumetric_fog_albedo = Color(0.50, 0.55, 0.60)
			WeatherType.FOG:
				env.volumetric_fog_density = 0.022
				env.volumetric_fog_albedo = Color(0.78, 0.80, 0.85)
			WeatherType.THUNDERSTORM:
				env.volumetric_fog_density = 0.010
				env.volumetric_fog_albedo = Color(0.42, 0.46, 0.52)
				
	EventBus.weather_state_changed.emit(WeatherType.keys()[type], wetness_intensity)


func apply_quality_preset(quality: GraphicsQuality) -> void:
	if not world_env or not world_env.environment:
		return
		
	var env = world_env.environment
	var has_rd: bool = RenderingServer.get_rendering_device() != null
	
	match quality:
		GraphicsQuality.LOW:
			# Maximum performance on web / low-end hardware
			env.ssao_enabled = false
			env.ssr_enabled = false
			env.glow_enabled = false
			env.volumetric_fog_enabled = false
			if sun_light:
				sun_light.directional_shadow_max_distance = 50.0
				sun_light.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
		GraphicsQuality.MEDIUM:
			# Balanced performance
			env.ssao_enabled = has_rd
			env.ssr_enabled = false
			env.volumetric_fog_enabled = has_rd
			if sun_light:
				sun_light.directional_shadow_max_distance = 120.0
				sun_light.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
		GraphicsQuality.HIGH:
			# Full PBR Open-World Visual Standard
			env.ssao_enabled = has_rd
			env.ssr_enabled = has_rd
			if has_rd:
				env.ssr_max_steps = 32
			env.volumetric_fog_enabled = has_rd
			if sun_light:
				sun_light.directional_shadow_max_distance = 160.0
				sun_light.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS


func _notify_time() -> void:
	var total_min = int(current_time_hours * 60.0)
	var h = int(total_min / 60)
	var m = total_min % 60
	EventBus.time_of_day_updated.emit(h, m, current_time_hours / 24.0)
