# ==============================================================================
# TEST ECONOMY SYSTEM (PLAYABLE HARNESS)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Comprehensive diagnostic harness for Part 07:
#          - Cash & Bank balances (Rupali Bank ATM)
#          - Food & drink purchases (Mama Tong)
#          - Groceries & utilities (Bismillah General Store)
#          - Vehicle repair, paint & tuning (Bhai Bhai Auto Workshop)
#          - Clothing purchases & wardrobe equipping (Lalbagh Tailors)
#          - Property purchase & safehouse resting/saving (Padma Housing)
#          - 16-slot Inventory with Use & 3D Drop / Pickup
# ==============================================================================
extends Node3D

@onready var player: Player = $Player if has_node("Player") else null
@onready var ui_controller: EconomyUIController = $EconomyUIController if has_node("EconomyUIController") else null
@onready var test_sedan: BaseVehicle3D = $Sedan if has_node("Sedan") else null

# Stations
@onready var tong_station: ShopStation = $Stations/TongStation if has_node("Stations/TongStation") else null
@onready var general_station: ShopStation = $Stations/GeneralStation if has_node("Stations/GeneralStation") else null
@onready var fashion_station: ShopStation = $Stations/FashionStation if has_node("Stations/FashionStation") else null
@onready var garage_station: ShopStation = $Stations/GarageStation if has_node("Stations/GarageStation") else null
@onready var atm_station: AtmTerminal = $Stations/AtmTerminal if has_node("Stations/AtmTerminal") else null
@onready var safehouse_station: SafehouseProperty = $Stations/SafehouseProperty if has_node("Stations/SafehouseProperty") else null

var telemetry_label: Label = null


func _ready() -> void:
	_create_telemetry_ui()
	_connect_stations()
	
	# Initial player inventory items for testing
	if GameManager.inventory.get_item_count("cha") == 0:
		GameManager.inventory.add_item("cha", 2)
		GameManager.inventory.add_item("singara", 3)
		GameManager.inventory.add_item("medkit", 1)


func _connect_stations() -> void:
	if tong_station:
		tong_station.station_opened.connect(func(_type, data):
			if ui_controller: ui_controller.open_shop(data)
		)
	if general_station:
		general_station.station_opened.connect(func(_type, data):
			if ui_controller: ui_controller.open_shop(data)
		)
	if fashion_station:
		fashion_station.station_opened.connect(func(_type, _data):
			if ui_controller: ui_controller.open_clothing()
		)
	if garage_station:
		garage_station.station_opened.connect(func(_type, _data):
			if ui_controller: ui_controller.open_garage(test_sedan)
		)
	if atm_station:
		atm_station.atm_opened.connect(func():
			if ui_controller: ui_controller.open_atm()
		)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
		
	match event.keycode:
		KEY_1:
			# Quick cheat: Singara snack
			if GameManager.inventory.has_item("singara"):
				for i in range(InventorySystem.MAX_SLOTS):
					if GameManager.inventory.slots[i] != null and GameManager.inventory.slots[i]["item_id"] == "singara":
						GameManager.inventory.use_item(i, player)
						break
			else:
				GameManager.inventory.add_item("singara", 1)
		KEY_2:
			# Quick cheat: Drink Cha
			if GameManager.inventory.has_item("cha"):
				for i in range(InventorySystem.MAX_SLOTS):
					if GameManager.inventory.slots[i] != null and GameManager.inventory.slots[i]["item_id"] == "cha":
						GameManager.inventory.use_item(i, player)
						break
			else:
				GameManager.inventory.add_item("cha", 1)
		KEY_3:
			# Cash cheat +৳ 5,000
			GameManager.add_money(5000, "Debug Cash Bonus", "CHEAT")
		KEY_4:
			# Damage test vehicle by 35 HP to test garage repair
			if test_sedan:
				test_sedan.take_damage(35.0)
		KEY_B:
			# Quick open ATM
			if ui_controller:
				ui_controller.open_atm()
		KEY_G:
			# Quick open Garage
			if ui_controller:
				ui_controller.open_garage(test_sedan)
		KEY_K:
			# Quick Save
			var p_pos = player.global_position if player else Vector3.ZERO
			SaveSystem.save_game(p_pos, GameManager.wallet_bdt, GameManager.wanted_stars, [])
			if telemetry_label:
				EventBus.mission_objective_updated.emit(1, "Game state saved to user://dta_savegame.json!")
		KEY_L:
			# Quick Load
			var loaded = SaveSystem.load_game()
			if not loaded.is_empty() and player:
				EventBus.mission_objective_updated.emit(1, "Game state loaded successfully!")


func _create_telemetry_ui() -> void:
	var canvas = CanvasLayer.new()
	canvas.name = "TelemetryCanvas"
	canvas.layer = 15
	add_child(canvas)
	
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.position = Vector2(24, 24)
	canvas.add_child(panel)
	
	telemetry_label = Label.new()
	telemetry_label.text = "BANGLADESH ECONOMY HARNESS: INITIALIZING..."
	telemetry_label.add_theme_font_size_override("font_size", 13)
	telemetry_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95, 1))
	panel.add_child(telemetry_label)


func _process(_delta: float) -> void:
	if not telemetry_label:
		return
		
	var w := EconomySystem.format_bdt(GameManager.wallet_bdt)
	var b := EconomySystem.format_bdt(GameManager.bank_bdt)
	var outfit := GameManager.current_outfit
	var props_count := GameManager.owned_properties.size()
	
	var inv_count := 0
	for s in GameManager.inventory.slots:
		if s != null:
			inv_count += s.get("quantity", 1)
			
	var veh_hp := "N/A"
	var veh_tune := "N/A"
	if test_sedan:
		veh_hp = "%d / %d HP" % [int(test_sedan.current_health), int(test_sedan.max_health)]
		veh_tune = "Stage %d (Armor: %s)" % [test_sedan.engine_tune_stage, "Yes" if test_sedan.is_armor_plated else "No"]
		
	var recent_tx := "None"
	if not GameManager.transaction_history.is_empty():
		var t = GameManager.transaction_history[0]
		recent_tx = "[%s] %s (%s)" % [t.get("time", ""), t.get("description", ""), EconomySystem.format_bdt(t.get("amount", 0))]
		
	var text := "=== DTA BANGLADESH GAME ECONOMY & INTERACTION ===\n"
	text += "Pocket Cash (Wallet)  : %s\n" % w
	text += "Rupali Bank Savings   : %s\n" % b
	text += "Current Outfit        : %s\n" % outfit
	text += "Properties Owned      : %d (Safehouses)\n" % props_count
	text += "Inventory Items       : %d items in bag\n" % inv_count
	text += "Test Sedan Condition  : %s | %s\n" % [veh_hp, veh_tune]
	text += "Latest Transaction    : %s\n" % recent_tx
	text += "--------------------------------------------------\n"
	text += "CONTROLS & SHORTCUTS:\n"
	text += "[E] Walk up & Interact with any Station or Pickup\n"
	text += "[I / Tab] Toggle 16-Slot Inventory Screen\n"
	text += "[B] Open Rupali Bank ATM  |  [G] Open Garage Bay\n"
	text += "[1] Eat Singara (+25 HP)  |  [2] Drink Cha (+Stamina)\n"
	text += "[3] +৳ 5,000 Cash Cheat   |  [4] Damage Car (-35 HP)\n"
	text += "[K] Save Game to JSON     |  [L] Load Game State\n"
	
	telemetry_label.text = text
