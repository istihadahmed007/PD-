# ==============================================================================
# SETTINGS & GRAPHICS CONFIGURATION MODAL
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Interactive configuration for PC graphics presets, audio volume mixing,
#          display resolution modes, framerate capping, and mouse sensitivity.
# ==============================================================================
class_name SettingsModal
extends Control

signal closed()

# Graphics
@onready var quality_option: OptionButton = $Panel/VBox/TabContainer/Graphics/VBox/QualityRow/QualityOption
@onready var window_option: OptionButton = $Panel/VBox/TabContainer/Graphics/VBox/WindowRow/WindowOption
@onready var fps_option: OptionButton = $Panel/VBox/TabContainer/Graphics/VBox/FpsRow/FpsOption
@onready var ssao_check: CheckBox = $Panel/VBox/TabContainer/Graphics/VBox/SsaoCheck
@onready var ssr_check: CheckBox = $Panel/VBox/TabContainer/Graphics/VBox/SsrCheck
@onready var fog_check: CheckBox = $Panel/VBox/TabContainer/Graphics/VBox/FogCheck

# Audio Sliders
@onready var master_slider: HSlider = $Panel/VBox/TabContainer/Audio/VBox/MasterRow/MasterSlider
@onready var music_slider: HSlider = $Panel/VBox/TabContainer/Audio/VBox/MusicRow/MusicSlider
@onready var sfx_slider: HSlider = $Panel/VBox/TabContainer/Audio/VBox/SfxRow/SfxSlider
@onready var ambiance_slider: HSlider = $Panel/VBox/TabContainer/Audio/VBox/AmbianceRow/AmbianceSlider

# Controls
@onready var sens_slider: HSlider = $Panel/VBox/TabContainer/Controls/VBox/SensRow/SensSlider
@onready var invert_y_check: CheckBox = $Panel/VBox/TabContainer/Controls/VBox/InvertYCheck

# Buttons
@onready var apply_btn: Button = $Panel/VBox/Footer/ApplyBtn
@onready var close_btn: Button = $Panel/VBox/Footer/CloseBtn


func _ready() -> void:
	_populate_dropdowns()
	_connect_signals()
	load_current_settings()


func _populate_dropdowns() -> void:
	if quality_option:
		quality_option.clear()
		quality_option.add_item("Low (Integrated GPU)", 0)
		quality_option.add_item("Medium (Balanced 60 FPS)", 1)
		quality_option.add_item("High / Ultra (Full PBR + SSR)", 2)
		
	if window_option:
		window_option.clear()
		window_option.add_item("Windowed", 0)
		window_option.add_item("Fullscreen", 1)
		
	if fps_option:
		fps_option.clear()
		fps_option.add_item("30 FPS", 0)
		fps_option.add_item("60 FPS (Recommended)", 1)
		fps_option.add_item("Unlimited", 2)


func _connect_signals() -> void:
	if apply_btn:
		apply_btn.pressed.connect(_on_apply_pressed)
	if close_btn:
		close_btn.pressed.connect(close)
		
	# Live audio feedback when sliding
	if master_slider:
		master_slider.value_changed.connect(func(v):
			AudioManager.master_volume = v / 100.0
			AudioManager.apply_volume_settings()
		)
	if music_slider:
		music_slider.value_changed.connect(func(v):
			AudioManager.music_volume = v / 100.0
			AudioManager.apply_volume_settings()
		)
	if sfx_slider:
		sfx_slider.value_changed.connect(func(v):
			AudioManager.sfx_volume = v / 100.0
			AudioManager.apply_volume_settings()
		)
	if ambiance_slider:
		ambiance_slider.value_changed.connect(func(v):
			AudioManager.ambiance_volume = v / 100.0
			AudioManager.apply_volume_settings()
		)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			close()
			get_viewport().set_input_as_handled()


func open_modal() -> void:
	load_current_settings()
	show()


func close() -> void:
	hide()
	closed.emit()


func load_current_settings() -> void:
	var s = SaveSystem.load_settings()
	var gfx = s.get("graphics", {})
	if quality_option: quality_option.selected = gfx.get("quality_preset", 2)
	if window_option: window_option.selected = gfx.get("window_mode", 0)
	var fps_lim = gfx.get("fps_limit", 60)
	if fps_option:
		fps_option.selected = 0 if fps_lim == 30 else (1 if fps_lim == 60 else 2)
		
	var audio = s.get("audio", {})
	if master_slider: master_slider.value = audio.get("master_volume", 1.0) * 100.0
	if music_slider: music_slider.value = audio.get("music_volume", 0.8) * 100.0
	if sfx_slider: sfx_slider.value = audio.get("sfx_volume", 0.85) * 100.0
	if ambiance_slider: ambiance_slider.value = audio.get("ambiance_volume", 0.75) * 100.0
	
	var ctrl = s.get("controls", {})
	if sens_slider: sens_slider.value = ctrl.get("mouse_sensitivity", 1.0) * 100.0
	if invert_y_check: invert_y_check.button_pressed = ctrl.get("invert_y", false)


func _on_apply_pressed() -> void:
	var q_idx = quality_option.selected if quality_option else 2
	var win_idx = window_option.selected if window_option else 0
	var fps_choice = fps_option.selected if fps_option else 1
	var target_fps = 30 if fps_choice == 0 else (60 if fps_choice == 1 else 0)
	
	var settings := {
		"graphics": {
			"quality_preset": q_idx,
			"window_mode": win_idx,
			"fps_limit": target_fps,
			"ssao": ssao_check.button_pressed if ssao_check else true,
			"ssr": ssr_check.button_pressed if ssr_check else true,
			"fog": fog_check.button_pressed if fog_check else true
		},
		"audio": {
			"master_volume": (master_slider.value / 100.0) if master_slider else 1.0,
			"music_volume": (music_slider.value / 100.0) if music_slider else 0.8,
			"sfx_volume": (sfx_slider.value / 100.0) if sfx_slider else 0.85,
			"ambiance_volume": (ambiance_slider.value / 100.0) if ambiance_slider else 0.75
		},
		"controls": {
			"mouse_sensitivity": (sens_slider.value / 100.0) if sens_slider else 1.0,
			"invert_y": invert_y_check.button_pressed if invert_y_check else false
		}
	}
	
	SaveSystem.save_settings(settings)
	EventBus.mission_objective_updated.emit(1, "Settings saved successfully.")
	close()
