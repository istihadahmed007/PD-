# ==============================================================================
# MISSION DIALOGUE UI CONTROLLER (UI SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Cinematic dialogue letterbox featuring character portrait badges,
#          authentic dual-language Bengali & English typography, and keyboard advance.
# ==============================================================================
class_name MissionDialogueUI
extends Control

signal dialogue_finished()

var active_lines: Array = []
var current_line_index: int = 0
var is_active: bool = false

# Node References
@onready var panel_container: PanelContainer = $LetterboxPanel
@onready var portrait_texture: TextureRect = $LetterboxPanel/HBox/PortraitRect
@onready var speaker_label: Label = $LetterboxPanel/HBox/TextVBox/SpeakerLabel
@onready var bengali_label: Label = $LetterboxPanel/HBox/TextVBox/BengaliLabel
@onready var english_label: Label = $LetterboxPanel/HBox/TextVBox/EnglishLabel
@onready var prompt_hint: Label = $LetterboxPanel/HBox/TextVBox/PromptHint
@onready var blip_audio: AudioStreamPlayer = $BlipAudio


func _ready() -> void:
	visible = false
	EventBus.mission_dialogue_line_triggered.connect(_on_external_line_triggered)


func play_dialogue_sequence(lines: Array) -> void:
	if lines.is_empty():
		return
	
	active_lines = lines
	current_line_index = 0
	is_active = true
	visible = true
	EventBus.mission_dialogue_opened.emit()
	
	_show_current_line()


func _show_current_line() -> void:
	if current_line_index < 0 or current_line_index >= active_lines.size():
		_close_dialogue()
		return
	
	var line_data: Dictionary = active_lines[current_line_index]
	var speaker = line_data.get("speaker", "Character")
	var bengali = line_data.get("bengali", "")
	var english = line_data.get("english", "")
	var portrait_path = line_data.get("portrait", "")
	
	if speaker_label:
		speaker_label.text = speaker.to_upper()
	if bengali_label:
		bengali_label.text = bengali
	if english_label:
		english_label.text = english
	if prompt_hint:
		prompt_hint.text = "[ Click / Space / E ] Continue... (%d/%d)" % [current_line_index + 1, active_lines.size()]
	
	if portrait_texture and not portrait_path.is_empty() and ResourceLoader.exists(portrait_path):
		portrait_texture.texture = load(portrait_path)
	
	# Play blip audio
	if blip_audio and blip_audio.stream:
		blip_audio.pitch_scale = randf_range(0.95, 1.1)
		blip_audio.play()


func advance_dialogue() -> void:
	if not is_active:
		return
	
	current_line_index += 1
	if current_line_index < active_lines.size():
		_show_current_line()
	else:
		_close_dialogue()


func _close_dialogue() -> void:
	is_active = false
	visible = false
	active_lines.clear()
	current_line_index = 0
	EventBus.mission_dialogue_closed.emit()
	dialogue_finished.emit()


func _gui_input(event: InputEvent) -> void:
	if not is_active:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		advance_dialogue()
		accept_event()


func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_E or event.keycode == KEY_ENTER:
			advance_dialogue()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		advance_dialogue()
		get_viewport().set_input_as_handled()


func _on_external_line_triggered(speaker: String, bn: String, en: String, portrait: String) -> void:
	play_dialogue_sequence([{
		"speaker": speaker,
		"bengali": bn,
		"english": en,
		"portrait": portrait
	}])
