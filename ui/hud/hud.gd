# ==============================================================================
# BANGLADESH OPEN-WORLD HUD CONTROLLER
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Dynamic in-game UI hooked to EventBus signals.
# ==============================================================================
extends Control

@onready var money_label: Label = %MoneyLabel
@onready var wanted_label: Label = %WantedLabel
@onready var interaction_banner: PanelContainer = %InteractionBanner
@onready var interaction_label: Label = %InteractionLabel
@onready var health_bar: ProgressBar = %HealthBar
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var vehicle_hud: Control = %VehicleHUD
@onready var speed_label: Label = %SpeedLabel
@onready var vehicle_name_label: Label = %VehicleNameLabel
@onready var gear_label: Label = %GearLabel if has_node("%GearLabel") else null
@onready var mission_toast: PanelContainer = %MissionToast
@onready var mission_text: Label = %MissionText
@onready var objective_panel: PanelContainer = %ObjectivePanel if has_node("%ObjectivePanel") else null
@onready var objective_title: Label = %ObjectiveTitle if has_node("%ObjectiveTitle") else null
@onready var objective_desc: Label = %ObjectiveDesc if has_node("%ObjectiveDesc") else null
@onready var objective_distance: Label = %ObjectiveDistance if has_node("%ObjectiveDistance") else null
@onready var controls_hint_label: Label = %ControlsHintLabel if has_node("%ControlsHintLabel") else null


func _ready() -> void:
	# Connect to EventBus signals
	EventBus.money_changed.connect(_on_money_changed)
	EventBus.wanted_level_changed.connect(_on_wanted_level_changed)
	EventBus.interaction_available.connect(_on_interaction_available)
	EventBus.interaction_cleared.connect(_on_interaction_cleared)
	EventBus.player_health_changed.connect(_on_health_changed)
	EventBus.player_stamina_changed.connect(_on_stamina_changed)
	EventBus.vehicle_entered.connect(_on_vehicle_entered)
	EventBus.vehicle_exited.connect(_on_vehicle_exited)
	EventBus.vehicle_speed_changed.connect(_on_vehicle_speed_changed)
	EventBus.vehicle_gear_changed.connect(_on_vehicle_gear_changed)
	EventBus.mission_started.connect(_on_mission_started)
	EventBus.mission_objective_updated.connect(_on_mission_objective_updated)
	EventBus.mission_completed.connect(_on_mission_completed)
	
	interaction_banner.visible = false
	vehicle_hud.visible = false
	mission_toast.visible = false
	
	# Initial values from GameManager
	_on_money_changed(GameManager.wallet_bdt, 0)
	_on_wanted_level_changed(GameManager.wanted_stars)


func _on_money_changed(current_balance: int, _delta: int) -> void:
	if money_label:
		money_label.text = EconomySystem.format_bdt(current_balance)


func _on_wanted_level_changed(stars: int) -> void:
	if not wanted_label:
		return
	
	if stars <= 0:
		wanted_label.text = ""
		wanted_label.visible = false
	else:
		var stars_str := ""
		for i in range(5):
			if i < stars:
				stars_str += "★ "
			else:
				stars_str += "☆ "
		wanted_label.text = stars_str.strip_edges()
		wanted_label.visible = true


func _on_interaction_available(prompt: String, action_key: String) -> void:
	if interaction_banner and interaction_label:
		var key_display = action_key.to_upper()
		if action_key == "interact":
			key_display = "E"
		interaction_label.text = "[ " + key_display + " ]  " + prompt
		interaction_banner.visible = true


func _on_interaction_cleared() -> void:
	if interaction_banner:
		interaction_banner.visible = false


func _on_health_changed(current: float, max_val: float) -> void:
	if health_bar:
		health_bar.max_value = max_val
		health_bar.value = current


func _on_stamina_changed(current: float, max_val: float) -> void:
	if stamina_bar:
		stamina_bar.max_value = max_val
		stamina_bar.value = current


func _process(_delta: float) -> void:
	if not objective_panel or not objective_panel.visible:
		return
	var ms = get_tree().get_first_node_in_group("mission_system")
	if ms and ms.get("active_beacon") and ms.active_beacon and ms.active_beacon.is_active:
		if is_instance_valid(GameManager.active_player):
			var dist = GameManager.active_player.global_position.distance_to(ms.active_beacon.global_position)
			if objective_distance:
				objective_distance.text = "Beacon Distance: %d meters" % int(round(dist))
	elif objective_distance:
		objective_distance.text = "Target in Range"


func _on_vehicle_entered(vehicle: Node, _seat: String) -> void:
	if vehicle_hud:
		vehicle_hud.visible = true
		if vehicle_name_label and vehicle.get("vehicle_name"):
			vehicle_name_label.text = str(vehicle.vehicle_name).to_upper()
	if controls_hint_label:
		controls_hint_label.text = "[W S] Accelerate/Brake  •  [A D] Steer  •  [Space] Handbrake  •  [E] Dismount  •  [H] Horn"


func _on_vehicle_exited(_vehicle: Node) -> void:
	if vehicle_hud:
		vehicle_hud.visible = false
	if controls_hint_label:
		controls_hint_label.text = "[W A S D] Move  •  [Shift] Sprint  •  [Space] Jump  •  [E] Interact  •  [R-Click] Aim  •  [Esc] Menu"


func _on_vehicle_speed_changed(kmh: float) -> void:
	if speed_label:
		speed_label.text = str(int(round(kmh))) + " KM/H"


func _on_vehicle_gear_changed(gear_name: String, _rpm: float) -> void:
	if gear_label:
		gear_label.text = "GEAR: " + gear_name


func _on_mission_started(_id: String, title: String) -> void:
	_show_mission_toast("MISSION STARTED: " + title)
	if objective_panel:
		objective_panel.visible = true
	if objective_title:
		objective_title.text = title


func _on_mission_objective_updated(_step: int, desc: String) -> void:
	_show_mission_toast("OBJECTIVE: " + desc)
	if objective_panel:
		objective_panel.visible = true
	if objective_desc:
		objective_desc.text = desc


func _on_mission_completed(_id: String, reward: int) -> void:
	_show_mission_toast("MISSION COMPLETED! Reward: " + EconomySystem.format_bdt(reward))
	if objective_desc:
		objective_desc.text = "Mission Completed! Reward: +%s" % EconomySystem.format_bdt(reward)
	if objective_distance:
		objective_distance.text = "Completed"


func _show_mission_toast(msg: String) -> void:
	if not mission_toast or not mission_text:
		return
	mission_text.text = msg
	mission_toast.visible = true
	var timer = get_tree().create_timer(5.0)
	timer.timeout.connect(func(): mission_toast.visible = false)
