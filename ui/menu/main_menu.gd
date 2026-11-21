# ==============================================================================
# MAIN MENU CONTROLLER
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Cinematic startup title screen, new game / slot load, settings access,
#          credits display, and original theme music playback.
# ==============================================================================
class_name MainMenu
extends Control

const MAIN_SCENE_PATH := "res://scenes/districts/district_01_padma_buriganga.tscn"
const MULTIPLAYER_MENU_PATH := "res://multiplayer/multiplayer_menu.tscn"

@onready var btn_new_game: Button = %BtnNewGame
@onready var btn_multiplayer: Button = %BtnMultiplayer
@onready var btn_continue: Button = %BtnContinue
@onready var btn_load: Button = %BtnLoad
@onready var btn_settings: Button = %BtnSettings
@onready var btn_credits: Button = %BtnCredits
@onready var btn_exit: Button = %BtnExit

# Sub-Panels
@onready var slots_panel: Panel = %SlotsPanel
@onready var slots_title: Label = %SlotsTitle
@onready var btn_slot_1: Button = %BtnSlot1
@onready var btn_slot_2: Button = %BtnSlot2
@onready var btn_slot_3: Button = %BtnSlot3
@onready var btn_slots_back: Button = %BtnSlotsBack

@onready var credits_panel: Panel = %CreditsPanel
@onready var btn_credits_close: Button = %BtnCreditsClose

@onready var settings_modal: SettingsModal = %SettingsModal


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if slots_panel: slots_panel.hide()
	if credits_panel: credits_panel.hide()
	if settings_modal: settings_modal.hide()
	
	_connect_buttons()
	_update_continue_button()
	
	# Start Main Theme Soundtrack
	AudioManager.play_main_theme()


func _connect_buttons() -> void:
	if btn_new_game: btn_new_game.pressed.connect(_on_new_game_pressed)
	if btn_multiplayer: btn_multiplayer.pressed.connect(_on_multiplayer_pressed)
	if btn_continue: btn_continue.pressed.connect(_on_continue_pressed)
	if btn_load: btn_load.pressed.connect(_on_load_pressed)
	if btn_settings: btn_settings.pressed.connect(func(): if settings_modal: settings_modal.open_modal())
	if btn_credits: btn_credits.pressed.connect(func(): if credits_panel: credits_panel.show())
	if btn_exit: btn_exit.pressed.connect(func(): get_tree().quit())
	
	if btn_slot_1: btn_slot_1.pressed.connect(func(): _load_slot(1))
	if btn_slot_2: btn_slot_2.pressed.connect(func(): _load_slot(2))
	if btn_slot_3: btn_slot_3.pressed.connect(func(): _load_slot(3))
	if btn_slots_back: btn_slots_back.pressed.connect(func(): slots_panel.hide())
	if btn_credits_close: btn_credits_close.pressed.connect(func(): credits_panel.hide())


func _update_continue_button() -> void:
	var s1 = SaveSystem.get_slot_info(1)
	if btn_continue:
		btn_continue.disabled = not s1["exists"]
		if s1["exists"]:
			btn_continue.text = "Continue (%s)" % s1["timestamp"]
		else:
			btn_continue.text = "Continue (No Save Found)"


func _on_multiplayer_pressed() -> void:
	AudioManager.stop_music()
	get_tree().change_scene_to_file(MULTIPLAYER_MENU_PATH)


func _on_new_game_pressed() -> void:
	AudioManager.stop_music()
	SaveSystem.active_slot = 1
	# Reset GameManager state
	GameManager.wallet_bdt = 5000
	GameManager.bank_bdt = 25000
	GameManager.wanted_stars = 0
	GameManager.transaction_history.clear()
	GameManager.owned_properties.clear()
	GameManager.current_outfit = "dhaka_casual"
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)


func _on_continue_pressed() -> void:
	_load_slot(1)


func _on_load_pressed() -> void:
	_refresh_slots()
	slots_panel.show()


func _refresh_slots() -> void:
	var s1 = SaveSystem.get_slot_info(1)
	var s2 = SaveSystem.get_slot_info(2)
	var s3 = SaveSystem.get_slot_info(3)
	
	if btn_slot_1:
		btn_slot_1.text = "Slot 1: %s" % (s1["summary"] if s1["exists"] else "Empty")
		btn_slot_1.disabled = not s1["exists"]
	if btn_slot_2:
		btn_slot_2.text = "Slot 2: %s" % (s2["summary"] if s2["exists"] else "Empty")
		btn_slot_2.disabled = not s2["exists"]
	if btn_slot_3:
		btn_slot_3.text = "Slot 3: %s" % (s3["summary"] if s3["exists"] else "Empty")
		btn_slot_3.disabled = not s3["exists"]


func _load_slot(slot_id: int) -> void:
	AudioManager.stop_music()
	SaveSystem.active_slot = slot_id
	SaveSystem.load_game(slot_id)
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)
