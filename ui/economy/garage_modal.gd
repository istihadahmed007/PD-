# ==============================================================================
# GARAGE MODAL (VEHICLE WORKSHOP & CUSTOMIZATION)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Functional vehicle repair, paint shop, engine tuning, and armor upgrades
#          at Bhai Bhai Auto Workshop.
# ==============================================================================
class_name GarageModal
extends Control

signal closed()

@onready var vehicle_name_label: Label = $Panel/VBox/Header/VehicleNameLabel
@onready var health_bar: ProgressBar = $Panel/VBox/StatusBox/HealthBar
@onready var health_val_label: Label = $Panel/VBox/StatusBox/HealthValLabel
@onready var tune_label: Label = $Panel/VBox/StatusBox/TuneLabel
@onready var armor_label: Label = $Panel/VBox/StatusBox/ArmorLabel
@onready var wallet_label: Label = $Panel/VBox/Header/WalletLabel

@onready var repair_btn: Button = $Panel/VBox/Services/RepairBtn
@onready var apply_paint_btn: Button = $Panel/VBox/Services/PaintBox/ApplyPaintBtn
@onready var tune_btn: Button = $Panel/VBox/Services/TuneBtn
@onready var armor_btn: Button = $Panel/VBox/Services/ArmorBtn
@onready var close_btn: Button = $Panel/VBox/Footer/CloseBtn

var target_vehicle: BaseVehicle3D = null
var selected_paint_color: Color = Color(0.08, 0.45, 0.22, 1.0) # Dhaka Green


func _ready() -> void:
	if close_btn:
		close_btn.pressed.connect(close)
	if repair_btn:
		repair_btn.pressed.connect(_on_repair_pressed)
	if apply_paint_btn:
		apply_paint_btn.pressed.connect(_on_apply_paint_pressed)
	if tune_btn:
		tune_btn.pressed.connect(_on_tune_pressed)
	if armor_btn:
		armor_btn.pressed.connect(_on_armor_pressed)
		
	_setup_color_buttons()
	EventBus.money_changed.connect(func(_b, _d): _update_status())


func open_garage(vehicle: BaseVehicle3D = null) -> void:
	if vehicle:
		target_vehicle = vehicle
	elif GameManager.active_vehicle and GameManager.active_vehicle is BaseVehicle3D:
		target_vehicle = GameManager.active_vehicle
	else:
		# Search nearby vehicles
		target_vehicle = _find_nearby_vehicle()
	
	show()
	_update_status()


func close() -> void:
	hide()
	closed.emit()


func _setup_color_buttons() -> void:
	var color_container = get_node_or_null("Panel/VBox/Services/PaintBox/ColorGrid")
	if not color_container:
		return
		
	var colors := {
		"Dhaka Green": Color(0.08, 0.45, 0.22, 1.0),
		"Crimson Red": Color(0.72, 0.12, 0.15, 1.0),
		"Midnight Black": Color(0.08, 0.09, 0.1, 1.0),
		"Pearl White": Color(0.92, 0.93, 0.95, 1.0),
		"Sky Blue": Color(0.15, 0.45, 0.78, 1.0),
		"Amber Yellow": Color(0.88, 0.65, 0.12, 1.0)
	}
	
	for col_name in colors:
		var c: Color = colors[col_name]
		var btn = Button.new()
		btn.text = col_name
		btn.custom_minimum_size = Vector2(100, 32)
		btn.pressed.connect(func():
			selected_paint_color = c
			if target_vehicle and target_vehicle.has_method("set_custom_paint"):
				target_vehicle.set_custom_paint(c) # Live preview
		)
		color_container.add_child(btn)


func _update_status() -> void:
	if wallet_label:
		wallet_label.text = "Cash: %s  |  Bank: %s" % [
			EconomySystem.format_bdt(GameManager.wallet_bdt),
			EconomySystem.format_bdt(GameManager.bank_bdt)
		]
	
	if not target_vehicle:
		if vehicle_name_label:
			vehicle_name_label.text = "BHAI BHAI AUTO WORKSHOP (No Vehicle Parked in Bay)"
		if repair_btn:
			repair_btn.disabled = true
		if apply_paint_btn:
			apply_paint_btn.disabled = true
		if tune_btn:
			tune_btn.disabled = true
		if armor_btn:
			armor_btn.disabled = true
		return
	
	if vehicle_name_label:
		vehicle_name_label.text = "BHAI BHAI AUTO WORKSHOP: " + target_vehicle.vehicle_name.to_upper()
	
	var cur_hp = target_vehicle.current_health
	var max_hp = target_vehicle.max_health
	if health_bar:
		health_bar.max_value = max_hp
		health_bar.value = cur_hp
	if health_val_label:
		health_val_label.text = "Condition: %d / %d HP" % [int(cur_hp), int(max_hp)]
	
	if tune_label:
		tune_label.text = "ECU Tuning: Stage %d" % target_vehicle.engine_tune_stage
	if armor_label:
		armor_label.text = "Armor: " + ("Reinforced Steel (+50% HP)" if target_vehicle.is_armor_plated else "Stock Factory")
	
	# Update buttons
	if repair_btn:
		var needs_repair = cur_hp < max_hp
		repair_btn.disabled = not needs_repair or (GameManager.wallet_bdt < 500)
		repair_btn.text = "Repair Body & Engine (%s)" % EconomySystem.format_bdt(500) if needs_repair else "Vehicle Fully Repaired"
	
	if apply_paint_btn:
		apply_paint_btn.disabled = (GameManager.wallet_bdt < 1200)
		apply_paint_btn.text = "Apply Paint (%s)" % EconomySystem.format_bdt(1200)
		
	if tune_btn:
		var can_tune = target_vehicle.engine_tune_stage < 1
		tune_btn.disabled = not can_tune or (GameManager.wallet_bdt < 3500)
		tune_btn.text = "Stage 1 ECU Tuning (+25% Torque) (%s)" % EconomySystem.format_bdt(3500) if can_tune else "Max Tuning Installed"
		
	if armor_btn:
		var can_armor = not target_vehicle.is_armor_plated
		armor_btn.disabled = not can_armor or (GameManager.wallet_bdt < 4500)
		armor_btn.text = "Install Steel Bullbar & Armor (%s)" % EconomySystem.format_bdt(4500) if can_armor else "Reinforced Armor Active"


func _on_repair_pressed() -> void:
	if not target_vehicle:
		return
	if GameManager.spend_money(500, "Bhai Bhai Workshop: Vehicle Repair", "GARAGE"):
		target_vehicle.repair_vehicle()
		_update_status()


func _on_apply_paint_pressed() -> void:
	if not target_vehicle:
		return
	if GameManager.spend_money(1200, "Bhai Bhai Workshop: Custom Polyurethane Paint", "GARAGE"):
		target_vehicle.set_custom_paint(selected_paint_color)
		AudioManager.play_sfx("res://audio/economy/wrench_ratchet.wav")
		_update_status()


func _on_tune_pressed() -> void:
	if not target_vehicle:
		return
	if GameManager.spend_money(3500, "Bhai Bhai Workshop: Stage 1 ECU Tuning", "GARAGE"):
		target_vehicle.apply_engine_tuning(1)
		_update_status()


func _on_armor_pressed() -> void:
	if not target_vehicle:
		return
	if GameManager.spend_money(4500, "Bhai Bhai Workshop: Reinforced Armor", "GARAGE"):
		target_vehicle.apply_armor_plating()
		_update_status()


func _find_nearby_vehicle() -> BaseVehicle3D:
	var player = GameManager.active_player
	if not player:
		return null
	var vehicles = player.get_tree().get_nodes_in_group("vehicles")
	var closest: BaseVehicle3D = null
	var min_dist := 12.0
	for v in vehicles:
		if v is BaseVehicle3D:
			var d = player.global_position.distance_to(v.global_position)
			if d < min_dist:
				min_dist = d
				closest = v
	return closest
