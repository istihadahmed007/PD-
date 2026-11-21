# ==============================================================================
# INVENTORY MODAL (PLAYER BACKPACK & ITEM MANAGEMENT)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Functional 16-slot grid inventory for using food, drink, utility tools,
#          inspecting items, and dropping physical pickups in 3D world.
# ==============================================================================
class_name InventoryModal
extends Control

signal closed()

const PICKUP_SCENE := preload("res://scripts/economy/item_pickup_3d.tscn")

@onready var slot_grid: GridContainer = $Panel/VBox/Content/LeftBox/SlotGrid
@onready var wallet_label: Label = $Panel/VBox/Header/WalletLabel

# Inspector pane
@onready var item_name_label: Label = $Panel/VBox/Content/RightBox/ItemNameLabel
@onready var item_desc_label: Label = $Panel/VBox/Content/RightBox/ItemDescLabel
@onready var item_stats_label: Label = $Panel/VBox/Content/RightBox/ItemStatsLabel
@onready var use_btn: Button = $Panel/VBox/Content/RightBox/UseBtn
@onready var drop_one_btn: Button = $Panel/VBox/Content/RightBox/DropOneBtn
@onready var drop_all_btn: Button = $Panel/VBox/Content/RightBox/DropAllBtn
@onready var close_btn: Button = $Panel/VBox/Footer/CloseBtn

var selected_slot_index: int = -1


func _ready() -> void:
	if close_btn:
		close_btn.pressed.connect(close)
	if use_btn:
		use_btn.pressed.connect(_on_use_pressed)
	if drop_one_btn:
		drop_one_btn.pressed.connect(_on_drop_one_pressed)
	if drop_all_btn:
		drop_all_btn.pressed.connect(_on_drop_all_pressed)
		
	EventBus.inventory_updated.connect(_refresh_slots)
	EventBus.money_changed.connect(func(_b, _d): _update_wallet())


func open_inventory() -> void:
	show()
	_update_wallet()
	_refresh_slots()
	_select_slot(-1)


func close() -> void:
	hide()
	closed.emit()


func _update_wallet() -> void:
	if wallet_label:
		wallet_label.text = "Wallet: %s  |  Bank: %s" % [
			EconomySystem.format_bdt(GameManager.wallet_bdt),
			EconomySystem.format_bdt(GameManager.bank_bdt)
		]


func _refresh_slots() -> void:
	if not slot_grid:
		return
		
	for child in slot_grid.get_children():
		child.queue_free()
		
	var slots: Array = GameManager.inventory.slots
	for i in range(InventorySystem.MAX_SLOTS):
		var slot_btn = Button.new()
		slot_btn.custom_minimum_size = Vector2(76, 76)
		
		var slot_data = slots[i] if i < slots.size() else null
		if slot_data != null:
			var item_id: String = slot_data["item_id"]
			var qty: int = slot_data["quantity"]
			var item_info = EconomySystem.get_item(item_id)
			var short_name = item_info.get("name", item_id.capitalize())
			if short_name.length() > 10:
				short_name = short_name.substr(0, 9) + "…"
			slot_btn.text = "%s\n(x%d)" % [short_name, qty]
			slot_btn.modulate = Color(1.0, 1.0, 1.0)
		else:
			slot_btn.text = "[ Empty ]"
			slot_btn.modulate = Color(0.6, 0.6, 0.6)
			
		var slot_idx := i
		slot_btn.pressed.connect(func():
			_select_slot(slot_idx)
		)
		slot_grid.add_child(slot_btn)
		
	# Refresh inspector for current selection
	_select_slot(selected_slot_index)


func _select_slot(slot_idx: int) -> void:
	selected_slot_index = slot_idx
	var slots: Array = GameManager.inventory.slots
	
	if slot_idx < 0 or slot_idx >= slots.size() or slots[slot_idx] == null:
		if item_name_label: item_name_label.text = "Select an Item"
		if item_desc_label: item_desc_label.text = "Click any occupied inventory slot on the left to inspect, consume, or drop."
		if item_stats_label: item_stats_label.text = ""
		if use_btn: use_btn.disabled = true
		if drop_one_btn: drop_one_btn.disabled = true
		if drop_all_btn: drop_all_btn.disabled = true
		return
		
	var slot_data: Dictionary = slots[slot_idx]
	var item_id: String = slot_data["item_id"]
	var qty: int = slot_data["quantity"]
	var info: Dictionary = EconomySystem.get_item(item_id)
	
	if item_name_label:
		item_name_label.text = "%s (%s)" % [info.get("name", item_id.capitalize()), info.get("bangla_name", "")]
	if item_desc_label:
		item_desc_label.text = info.get("desc", "No description available.")
	if item_stats_label:
		item_stats_label.text = "Quantity: %d  |  Price: %s\nCategory: %s" % [
			qty,
			EconomySystem.format_bdt(info.get("price", 0)),
			EconomySystem.ItemCategory.keys()[info.get("category", 0)]
		]
		
	if use_btn:
		use_btn.disabled = false
		use_btn.text = "Use / Consume 1"
	if drop_one_btn:
		drop_one_btn.disabled = false
	if drop_all_btn:
		drop_all_btn.disabled = false


func _on_use_pressed() -> void:
	if selected_slot_index < 0:
		return
	GameManager.inventory.use_item(selected_slot_index)


func _on_drop_one_pressed() -> void:
	if selected_slot_index < 0:
		return
	_drop_item(1)


func _on_drop_all_pressed() -> void:
	if selected_slot_index < 0:
		return
	var slots: Array = GameManager.inventory.slots
	if selected_slot_index < slots.size() and slots[selected_slot_index] != null:
		var qty: int = slots[selected_slot_index]["quantity"]
		_drop_item(qty)


func _drop_item(qty: int) -> void:
	var slots: Array = GameManager.inventory.slots
	if selected_slot_index >= slots.size() or slots[selected_slot_index] == null:
		return
		
	var item_id: String = slots[selected_slot_index]["item_id"]
	var player = GameManager.active_player
	var drop_pos := Vector3.ZERO
	if player:
		drop_pos = player.global_position - (player.global_transform.basis.z * 1.4) + Vector3(0, 0.4, 0)
	
	if GameManager.inventory.drop_item(selected_slot_index, qty, drop_pos):
		# Spawn 3D physical pickup
		var pickup = PICKUP_SCENE.instantiate() as ItemPickup3D
		pickup.item_id = item_id
		pickup.quantity = qty
		pickup.global_position = drop_pos
		get_tree().current_scene.add_child(pickup)
