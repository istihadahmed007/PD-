# ==============================================================================
# PAUSE MENU & IN-GAME MANAGER
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Manages gameplay pauses, multi-slot saving/loading, settings access,
#          mission review, and scene navigation to main menu.
# ==============================================================================
class_name PauseMenu
extends CanvasLayer

signal resumed()

@onready var menu_root: Control = $MenuRoot
@onready var btn_resume: Button = $MenuRoot/Panel/VBox/BtnResume
@onready var btn_save: Button = $MenuRoot/Panel/VBox/BtnSave
@onready var btn_load: Button = $MenuRoot/Panel/VBox/BtnLoad
@onready var btn_missions: Button = $MenuRoot/Panel/VBox/BtnMissions
@onready var btn_map: Button = $MenuRoot/Panel/VBox/BtnMap
@onready var btn_settings: Button = $MenuRoot/Panel/VBox/BtnSettings
@onready var btn_main_menu: Button = $MenuRoot/Panel/VBox/BtnMainMenu
@onready var btn_quit: Button = $MenuRoot/Panel/VBox/BtnQuit

# Save/Load Sub-Panel
@onready var slots_panel: Panel = $MenuRoot/SlotsPanel
@onready var slots_title: Label = $MenuRoot/SlotsPanel/VBox/TitleLabel
@onready var btn_slot_1: Button = $MenuRoot/SlotsPanel/VBox/BtnSlot1
@onready var btn_slot_2: Button = $MenuRoot/SlotsPanel/VBox/BtnSlot2
@onready var btn_slot_3: Button = $MenuRoot/SlotsPanel/VBox/BtnSlot3
@onready var btn_slots_back: Button = $MenuRoot/SlotsPanel/VBox/BtnBack
@onready var status_toast: Label = $MenuRoot/StatusToast

# Sub Modals
@onready var settings_modal: SettingsModal = $SettingsModal
@onready var mission_log_modal: MissionLogModal = $MissionLogModal

var _is_save_action: bool = true # true = save, false = load
var _previous_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED


func _ready() -> void:
	layer = 20
	process_mode = PROCESS_MODE_ALWAYS
	menu_root.hide()
	if slots_panel: slots_panel.hide()
	if status_toast: status_toast.text = ""
	
	_connect_buttons()


func _connect_buttons() -> void:
	if btn_resume: btn_resume.pressed.connect(resume_game)
	if btn_save: btn_save.pressed.connect(func(): _open_slots_panel(true))
	if btn_load: btn_load.pressed.connect(func(): _open_slots_panel(false))
	if btn_missions: btn_missions.pressed.connect(_open_mission_log)
	if btn_map: btn_map.pressed.connect(_open_world_map)
	if btn_settings: btn_settings.pressed.connect(_open_settings)
	if btn_main_menu: btn_main_menu.pressed.connect(_on_quit_to_main_menu)
	if btn_quit: btn_quit.pressed.connect(func(): get_tree().quit())
	
	if btn_slot_1: btn_slot_1.pressed.connect(func(): _execute_slot_action(1))
	if btn_slot_2: btn_slot_2.pressed.connect(func(): _execute_slot_action(2))
	if btn_slot_3: btn_slot_3.pressed.connect(func(): _execute_slot_action(3))
	if btn_slots_back: btn_slots_back.pressed.connect(func(): slots_panel.hide())
	
	if settings_modal: settings_modal.closed.connect(func(): menu_root.show())
	if mission_log_modal: mission_log_modal.closed.connect(func(): menu_root.show())


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if settings_modal and settings_modal.visible:
				settings_modal.close()
				get_viewport().set_input_as_handled()
				return
			if mission_log_modal and mission_log_modal.visible:
				mission_log_modal.close()
				get_viewport().set_input_as_handled()
				return
			if slots_panel and slots_panel.visible:
				slots_panel.hide()
				get_viewport().set_input_as_handled()
				return
				
			if get_tree().paused:
				resume_game()
			else:
				pause_game()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_J and not get_tree().paused:
			_open_mission_log()
			get_viewport().set_input_as_handled()


func pause_game() -> void:
	_previous_mouse_mode = Input.mouse_mode
	get_tree().paused = true
	menu_root.show()
	if slots_panel: slots_panel.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func resume_game() -> void:
	get_tree().paused = false
	menu_root.hide()
	if slots_panel: slots_panel.hide()
	if settings_modal: settings_modal.hide()
	if mission_log_modal: mission_log_modal.hide()
	Input.mouse_mode = _previous_mouse_mode
	resumed.emit()


func _open_slots_panel(is_save: bool) -> void:
	_is_save_action = is_save
	slots_title.text = "SELECT SAVE SLOT" if is_save else "SELECT LOAD SLOT"
	_refresh_slot_buttons()
	slots_panel.show()


func _refresh_slot_buttons() -> void:
	var s1 = SaveSystem.get_slot_info(1)
	var s2 = SaveSystem.get_slot_info(2)
	var s3 = SaveSystem.get_slot_info(3)
	
	if btn_slot_1: btn_slot_1.text = "Slot 1: %s" % (s1["summary"] if s1["exists"] else "Empty")
	if btn_slot_2: btn_slot_2.text = "Slot 2: %s" % (s2["summary"] if s2["exists"] else "Empty")
	if btn_slot_3: btn_slot_3.text = "Slot 3: %s" % (s3["summary"] if s3["exists"] else "Empty")


func _execute_slot_action(slot_id: int) -> void:
	if _is_save_action:
		var p_pos = GameManager.active_player.global_position if GameManager.active_player else Vector3.ZERO
		var success = SaveSystem.save_game(slot_id, p_pos)
		_show_status("Game saved to Slot %d!" % slot_id if success else "Failed to save slot!")
		_refresh_slot_buttons()
	else:
		var info = SaveSystem.get_slot_info(slot_id)
		if not info["exists"]:
			_show_status("Slot %d is empty!" % slot_id)
			return
		SaveSystem.load_game(slot_id)
		_show_status("Slot %d restored successfully!" % slot_id)
		await get_tree().create_timer(0.4).timeout
		resume_game()


func _show_status(msg: String) -> void:
	if status_toast:
		status_toast.text = msg
		var t = get_tree().create_timer(3.0)
		t.timeout.connect(func(): if status_toast.text == msg: status_toast.text = "")


func _open_mission_log() -> void:
	if mission_log_modal:
		mission_log_modal.open_modal()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _open_world_map() -> void:
	var wm = get_tree().root.find_child("WorldMapUI", true, false)
	if wm:
		menu_root.hide()
		wm.toggle_map()
	else:
		_show_status("World Map not in scene tree.")


func _open_settings() -> void:
	if settings_modal:
		settings_modal.open_modal()


func _on_quit_to_main_menu() -> void:
	get_tree().paused = false
	if ResourceLoader.exists("res://ui/menu/main_menu.tscn"):
		get_tree().change_scene_to_file("res://ui/menu/main_menu.tscn")
	else:
		get_tree().quit()
