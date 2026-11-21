# ==============================================================================
# MISSION LOG & HISTORY INTERFACE MODAL
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Comprehensive quest tracker, narrative mission history, objectives,
#          and character lore dossiers.
# ==============================================================================
class_name MissionLogModal
extends Control

signal closed()

@onready var tab_container: TabContainer = $Panel/VBox/TabContainer
@onready var close_btn: Button = $Panel/VBox/Footer/CloseBtn

# Active Mission Tab
@onready var active_title_label: Label = $Panel/VBox/TabContainer/ActiveMission/VBox/TitleLabel
@onready var active_desc_label: Label = $Panel/VBox/TabContainer/ActiveMission/VBox/DescLabel
@onready var active_reward_label: Label = $Panel/VBox/TabContainer/ActiveMission/VBox/RewardLabel
@onready var active_status_label: Label = $Panel/VBox/TabContainer/ActiveMission/VBox/StatusLabel

# Completed Mission Tab
@onready var history_list: ItemList = $Panel/VBox/TabContainer/MissionHistory/VBox/HistoryList
@onready var history_details_label: Label = $Panel/VBox/TabContainer/MissionHistory/VBox/DetailsLabel


func _ready() -> void:
	if close_btn:
		close_btn.pressed.connect(close)
	if history_list:
		history_list.item_selected.connect(_on_history_item_selected)
		
	EventBus.mission_started.connect(func(_id, _t): _refresh_ui())
	EventBus.mission_objective_updated.connect(func(_s, _d): _refresh_ui())
	EventBus.mission_completed.connect(func(_id, _r): _refresh_ui())


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_J:
			close()
			get_viewport().set_input_as_handled()


func open_modal() -> void:
	show()
	_refresh_ui()


func close() -> void:
	hide()
	closed.emit()


func _refresh_ui() -> void:
	# 1. Active Mission Info
	var root = get_tree().root
	var ms = root.find_child("MissionSystem", true, false)
	
	if ms and ms.is_mission_active:
		var m_res = ms.get_active_mission()
		if m_res:
			active_title_label.text = "%s (%s)" % [m_res.title_english, m_res.title_bengali]
			var cur_step = ms.get_current_step()
			if not cur_step.is_empty():
				active_desc_label.text = "CURRENT OBJECTIVE:\n%s\n\nবাংলা:\n%s" % [
					cur_step.get("description", ""),
					cur_step.get("bengali_desc", "")
				]
			else:
				active_desc_label.text = "Follow on-screen waypoints."
			active_reward_label.text = "Reward: %s" % EconomySystem.format_bdt(m_res.reward_bdt)
			active_status_label.text = "STATUS: IN PROGRESS [Step %d / %d]" % [ms.current_step_index + 1, m_res.steps.size()]
	else:
		active_title_label.text = "No Active Mission"
		active_desc_label.text = "Explore the Padma-Buriganga district, talk to questgivers, or take on side activities."
		active_reward_label.text = "Reward: ৳0 BDT"
		active_status_label.text = "STATUS: FREE ROAM"
		
	# 2. History List
	if history_list:
		history_list.clear()
		var completed_ids = ms.completed_mission_ids if ms else []
		
		var lore_db := {
			"mission_01_sand_and_sparkplugs": {
				"name": "Mission 01: Shadows & Spark Plugs (ছায়া ও চালক)",
				"desc": "Delivered sensitive high-output diesel fuel injectors across the heavily patrolled Canal Bridge to Bhai Bhai Auto Workshop. Reward: ৳1,500 BDT."
			},
			"mission_02_eyes_of_the_buriganga": {
				"name": "Mission 02: Eyes of the Buriganga (বুড়িগঙ্গার চোখ)",
				"desc": "Infiltrated the dredging docks and retrieved the sand extraction manifest for investigative journalist Nila Chowdhury, evading 1-Star police scrutiny. Reward: ৳2,800 BDT."
			},
			"mission_03_smoke_over_padma": {
				"name": "Mission 03: Smoke Over Padma (পদ্মার ধোঁয়া)",
				"desc": "Engaged Balu Syndicate enforcers in a high-speed vehicle pursuit along Padma highway, disabling the chase truck with precision PIT maneuvers. Reward: ৳4,500 BDT."
			}
		}
		
		if completed_ids.is_empty():
			history_list.add_item("No completed missions yet.")
		else:
			for id in completed_ids:
				var info = lore_db.get(id, {"name": id, "desc": "Mission successfully completed."})
				var idx = history_list.add_item(info["name"])
				history_list.set_item_metadata(idx, info["desc"])


func _on_history_item_selected(index: int) -> void:
	if not history_details_label:
		return
	var desc = history_list.get_item_metadata(index)
	if desc:
		history_details_label.text = str(desc)
	else:
		history_details_label.text = "Select a completed mission to review details."
