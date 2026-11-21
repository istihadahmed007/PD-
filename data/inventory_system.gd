# ==============================================================================
# INVENTORY SYSTEM (DATA & LOGIC)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Manages player item slots, stacking, using consumables, dropping items,
#          and persisting inventory state.
# ==============================================================================
class_name InventorySystem
extends RefCounted

const MAX_SLOTS: int = 16

# Array of Dictionary: { "item_id": String, "quantity": int } or null
var slots: Array = []


func _init() -> void:
	slots.resize(MAX_SLOTS)
	for i in range(MAX_SLOTS):
		slots[i] = null


func add_item(item_id: String, quantity: int = 1) -> bool:
	if quantity <= 0:
		return false
	
	var item_data := EconomySystem.get_item(item_id)
	if item_data.is_empty():
		push_error("Unknown item ID: " + item_id)
		return false
	
	var max_stack: int = item_data.get("max_stack", 10)
	var remaining := quantity
	
	# 1. Try to stack onto existing matching slots
	for i in range(MAX_SLOTS):
		if slots[i] != null and slots[i]["item_id"] == item_id:
			var current_qty: int = slots[i]["quantity"]
			var space: int = max_stack - current_qty
			if space > 0:
				var to_add := mini(remaining, space)
				slots[i]["quantity"] += to_add
				remaining -= to_add
				if remaining <= 0:
					EventBus.inventory_updated.emit()
					return true
	
	# 2. Put remainder into first empty slot
	for i in range(MAX_SLOTS):
		if slots[i] == null:
			var to_add := mini(remaining, max_stack)
			slots[i] = {
				"item_id": item_id,
				"quantity": to_add
			}
			remaining -= to_add
			if remaining <= 0:
				EventBus.inventory_updated.emit()
				return true
	
	EventBus.inventory_updated.emit()
	return remaining < quantity # True if at least some was added


func remove_item(item_id: String, quantity: int = 1) -> bool:
	if not has_item(item_id, quantity):
		return false
	
	var remaining := quantity
	for i in range(MAX_SLOTS - 1, -1, -1):
		if slots[i] != null and slots[i]["item_id"] == item_id:
			var slot_qty: int = slots[i]["quantity"]
			if slot_qty <= remaining:
				remaining -= slot_qty
				slots[i] = null
			else:
				slots[i]["quantity"] -= remaining
				remaining = 0
			if remaining <= 0:
				break
	
	EventBus.inventory_updated.emit()
	return true


func has_item(item_id: String, quantity: int = 1) -> bool:
	var total := 0
	for slot in slots:
		if slot != null and slot["item_id"] == item_id:
			total += slot["quantity"]
	return total >= quantity


func get_item_count(item_id: String) -> int:
	var total := 0
	for slot in slots:
		if slot != null and slot["item_id"] == item_id:
			total += slot["quantity"]
	return total


func use_item(slot_index: int, user: Node = null) -> bool:
	if slot_index < 0 or slot_index >= MAX_SLOTS or slots[slot_index] == null:
		return false
	
	var slot_data: Dictionary = slots[slot_index]
	var item_id: String = slot_data["item_id"]
	var item_info: Dictionary = EconomySystem.get_item(item_id)
	if item_info.is_empty():
		return false
	
	var effect_type: String = item_info.get("effect_type", "")
	var effect_val: float = item_info.get("effect_val", 0.0)
	var effect_applied := false
	
	# Apply Game Effect
	var player = user if user else GameManager.active_player
	
	match effect_type:
		"stamina", "stamina_boost":
			if player and "current_stamina" in player:
				player.current_stamina = minf(player.max_stamina, player.current_stamina + effect_val)
				EventBus.player_stamina_changed.emit(player.current_stamina, player.max_stamina)
				AudioManager.play_sfx("res://audio/economy/eat_drink.wav")
				effect_applied = true
		"health":
			if player and "current_health" in player:
				player.current_health = minf(player.max_health, player.current_health + effect_val)
				EventBus.player_health_changed.emit(player.current_health, player.max_health)
				AudioManager.play_sfx("res://audio/economy/eat_drink.wav")
				effect_applied = true
		"full_restore":
			if player:
				if "current_health" in player:
					player.current_health = player.max_health
					EventBus.player_health_changed.emit(player.current_health, player.max_health)
				if "current_stamina" in player:
					player.current_stamina = player.max_stamina
					EventBus.player_stamina_changed.emit(player.current_stamina, player.max_stamina)
				AudioManager.play_sfx("res://audio/economy/eat_drink.wav")
				effect_applied = true
		"repair_vehicle":
			var veh = GameManager.active_vehicle
			if veh and veh.has_method("repair_vehicle"):
				veh.repair_vehicle()
				AudioManager.play_sfx("res://audio/economy/wrench_ratchet.wav")
				effect_applied = true
			elif veh and "current_health" in veh:
				veh.current_health = minf(veh.max_health, veh.current_health + effect_val)
				EventBus.vehicle_health_changed.emit(veh.current_health, veh.max_health)
				AudioManager.play_sfx("res://audio/economy/wrench_ratchet.wav")
				effect_applied = true
			else:
				# Cannot use if not in vehicle
				return false
		"cash":
			GameManager.add_money(int(effect_val), "Syndicate Cash Bundle Disbursed", "INCOME")
			AudioManager.play_sfx("res://audio/economy/cash_register.wav")
			effect_applied = true
		_:
			effect_applied = true
	
	if effect_applied:
		slot_data["quantity"] -= 1
		if slot_data["quantity"] <= 0:
			slots[slot_index] = null
		EventBus.item_used.emit(item_id, item_info.get("name", item_id))
		EventBus.inventory_updated.emit()
		return true
	
	return false


func drop_item(slot_index: int, quantity: int = 1, drop_pos: Vector3 = Vector3.ZERO) -> bool:
	if slot_index < 0 or slot_index >= MAX_SLOTS or slots[slot_index] == null:
		return false
	
	var slot_data: Dictionary = slots[slot_index]
	var item_id: String = slot_data["item_id"]
	var available: int = slot_data["quantity"]
	var to_drop := mini(quantity, available)
	
	slot_data["quantity"] -= to_drop
	if slot_data["quantity"] <= 0:
		slots[slot_index] = null
	
	EventBus.item_dropped.emit(item_id, to_drop, drop_pos)
	EventBus.inventory_updated.emit()
	AudioManager.play_sfx("res://audio/economy/item_drop.wav")
	return true


func serialize() -> Array:
	var result: Array = []
	for s in slots:
		if s == null:
			result.append({})
		else:
			result.append({
				"item_id": s["item_id"],
				"quantity": s["quantity"]
			})
	return result


func deserialize(data: Array) -> void:
	slots.resize(MAX_SLOTS)
	for i in range(MAX_SLOTS):
		if i < data.size() and not data[i].is_empty():
			slots[i] = {
				"item_id": data[i].get("item_id", "cha"),
				"quantity": data[i].get("quantity", 1)
			}
		else:
			slots[i] = null
	EventBus.inventory_updated.emit()
