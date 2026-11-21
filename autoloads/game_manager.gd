# ==============================================================================
# GAME MANAGER (AUTOLOAD)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Master game state coordinator, active entity tracking, and transitions.
# ==============================================================================
extends Node

enum GameState {
	ON_FOOT,
	IN_VEHICLE,
	PAUSED,
	IN_MENU,
	CUTSCENE,
	DEAD
}

var current_state: GameState = GameState.ON_FOOT

var active_player: CharacterBody3D = null
var active_vehicle: Node = null

var wallet_bdt: int = 5000 # Starting pocket cash in Bangladesh Taka
var bank_bdt: int = 25000 # Starting Rupali Bank / bKash balance
var wanted_stars: int = 0
var max_wanted_stars: int = 5

var current_time_hours: int = 14
var current_time_minutes: int = 30

var transaction_history: Array[Dictionary] = []
var owned_properties: Array[String] = []
var current_outfit: String = "dhaka_casual"
var inventory: InventorySystem = InventorySystem.new()
var active_vehicle_customs: Dictionary = {
	"paint_color": "green_yellow",
	"engine_tune": 0,
	"armor_plated": false,
	"horn_style": "default"
}


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	EventBus.crime_committed.connect(_on_crime_committed)


func register_player(player: CharacterBody3D) -> void:
	active_player = player
	EventBus.player_spawned.emit(player)
	EventBus.money_changed.emit(wallet_bdt, 0)
	EventBus.wanted_level_changed.emit(wanted_stars)


func enter_vehicle(vehicle: Node, seat_name: String = "driver") -> void:
	if not active_player or not vehicle:
		return
	
	active_vehicle = vehicle
	current_state = GameState.IN_VEHICLE
	
	# Hide and disable player physics while inside vehicle
	active_player.hide()
	active_player.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Inform vehicle to activate driving controls
	if vehicle.has_method("mount_driver"):
		vehicle.mount_driver(active_player)
	
	EventBus.vehicle_entered.emit(vehicle, seat_name)


func exit_vehicle() -> void:
	if not active_vehicle or not active_player:
		return
	
	var vehicle = active_vehicle
	active_vehicle = null
	current_state = GameState.ON_FOOT
	
	# Determine dismount spawn location near driver door / side
	var exit_transform: Transform3D = vehicle.global_transform
	if vehicle.has_method("get_safe_exit_global_transform"):
		exit_transform = vehicle.get_safe_exit_global_transform()
	elif vehicle.has_node("ExitPoint"):
		exit_transform = vehicle.get_node("ExitPoint").global_transform
	else:
		exit_transform.origin += vehicle.global_transform.basis.x * -1.8 # Left side
		exit_transform.origin.y += 0.5
	
	active_player.global_transform.origin = exit_transform.origin
	active_player.show()
	active_player.process_mode = Node.PROCESS_MODE_INHERIT
	
	if vehicle.has_method("dismount_driver"):
		vehicle.dismount_driver()
	
	EventBus.vehicle_exited.emit(vehicle)


func add_money(amount: int, desc: String = "Cash Received", category: String = "INCOME") -> void:
	wallet_bdt += amount
	EventBus.money_changed.emit(wallet_bdt, amount)
	log_transaction(category, desc, amount)


func spend_money(amount: int, desc: String = "Purchase", category: String = "PURCHASE") -> bool:
	if wallet_bdt >= amount:
		wallet_bdt -= amount
		EventBus.money_changed.emit(wallet_bdt, -amount)
		log_transaction(category, desc, -amount)
		return true
	return false


func deposit_to_bank(amount: int) -> bool:
	if amount <= 0:
		return false
	if wallet_bdt >= amount:
		wallet_bdt -= amount
		bank_bdt += amount
		EventBus.money_changed.emit(wallet_bdt, -amount)
		EventBus.bank_balance_changed.emit(bank_bdt, amount)
		log_transaction("DEPOSIT", "Rupali Bank ATM Deposit", -amount)
		return true
	return false


func withdraw_from_bank(amount: int) -> bool:
	if amount <= 0:
		return false
	if bank_bdt >= amount:
		bank_bdt -= amount
		wallet_bdt += amount
		EventBus.money_changed.emit(wallet_bdt, amount)
		EventBus.bank_balance_changed.emit(bank_bdt, -amount)
		log_transaction("WITHDRAW", "Rupali Bank ATM Cash Withdrawal", amount)
		return true
	return false


func log_transaction(type_str: String, description: String, amount: int) -> Dictionary:
	var entry := {
		"id": transaction_history.size() + 1,
		"time": "%02d:%02d" % [current_time_hours, current_time_minutes],
		"type": type_str,
		"description": description,
		"amount": amount,
		"wallet_balance": wallet_bdt,
		"bank_balance": bank_bdt
	}
	transaction_history.push_front(entry)
	if transaction_history.size() > 50:
		transaction_history.pop_back()
	EventBus.transaction_logged.emit(entry)
	return entry


func purchase_property(property_id: String, cost: int, property_name: String) -> bool:
	if is_property_owned(property_id):
		return true
	
	# Prefer paying from bank if wallet has insufficient cash
	if wallet_bdt >= cost:
		if spend_money(cost, "Padma Housing: " + property_name, "PROPERTY"):
			owned_properties.append(property_id)
			EventBus.property_purchased.emit(property_id, property_name)
			return true
	elif bank_bdt >= cost:
		bank_bdt -= cost
		EventBus.bank_balance_changed.emit(bank_bdt, -cost)
		log_transaction("PROPERTY", "Padma Housing (Bank Transfer): " + property_name, -cost)
		owned_properties.append(property_id)
		EventBus.property_purchased.emit(property_id, property_name)
		return true
	return false


func is_property_owned(property_id: String) -> bool:
	return owned_properties.has(property_id)


func equip_outfit(outfit_id: String) -> void:
	current_outfit = outfit_id
	EventBus.outfit_changed.emit(outfit_id)
	if active_player and active_player.has_node("HumanoidCharacterSkin"):
		var skin = active_player.get_node("HumanoidCharacterSkin")
		if skin.has_method("apply_clothing_outfit"):
			skin.apply_clothing_outfit(outfit_id)


func advance_time(hours: int) -> void:
	current_time_hours = (current_time_hours + hours) % 24
	var norm = (float(current_time_hours) + float(current_time_minutes) / 60.0) / 24.0
	EventBus.time_of_day_updated.emit(current_time_hours, current_time_minutes, norm)


func set_wanted_level(stars: int) -> void:
	wanted_stars = clampi(stars, 0, max_wanted_stars)
	EventBus.wanted_level_changed.emit(wanted_stars)
	if wanted_stars > 0:
		EventBus.police_pursuit_started.emit()
	else:
		EventBus.police_pursuit_evaded.emit()


func _on_crime_committed(_crime_type: String, severity: int, _location: Vector3) -> void:
	set_wanted_level(wanted_stars + severity)
