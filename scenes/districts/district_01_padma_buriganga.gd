# ==============================================================================
# DISTRICT 01: LALBAGH-BURIGANGA CANAL DISTRICT (MASTER SCENE CONTROLLER)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Orchestrates 400m x 400m open-world district, weather, audio, and missions.
# ==============================================================================
extends Node3D

@onready var player: Player = %Player
@onready var weather_system: WeatherSystem = $WeatherSystem if has_node("WeatherSystem") else null
@onready var tong_shop: Node3D = %BismillahTeaStall if has_node("%BismillahTeaStall") else null

var mission_system: MissionSystem = null
var world_system: WorldSystem = null


func _ready() -> void:
	# In multiplayer session, free standalone single-player character to allow MultiplayerSpawner to manage players
	if multiplayer and multiplayer.has_multiplayer_peer():
		if player and is_instance_valid(player):
			player.queue_free()
			player = null
		if DisplayServer.get_name() == "headless":
			var ui_canvas = get_node_or_null("UI")
			if ui_canvas:
				ui_canvas.visible = false
	
	await get_tree().create_timer(0.3).timeout
	
	# Initialize Master Mission System
	mission_system = MissionSystem.new()
	mission_system.name = "MissionSystem"
	add_child(mission_system)
	
	# Initialize Master Open-World System (streams 7 interconnected regions around Old Dhaka)
	if not has_node("WorldSystem"):
		world_system = WorldSystem.new()
		world_system.name = "WorldSystem"
		world_system.is_master_district_present = true
		add_child(world_system)
	
	# Spawn World Story Quest Triggers
	_spawn_story_mission_triggers()
	
	# Spawn District Economy Infrastructure (Shops, Garage, ATM, Safehouses, UI)
	_spawn_economy_infrastructure()
	
	# Hook up tea stall interaction
	if tong_shop and tong_shop.has_node("InteractableZone"):
		var interactable = tong_shop.get_node("InteractableZone")
		interactable.interacted.connect(_on_tea_stall_interacted)
	
	# If no story mission completed yet, initiate Chapter 1
	if not mission_system.completed_mission_ids.has("m01_shadows_and_sparkplugs"):
		mission_system.start_mission(StoryMissions.get_mission_1())


func _spawn_story_mission_triggers() -> void:
	var trigger_scene = load("res://missions/mission_trigger.tscn")
	if not trigger_scene:
		return
	
	# 1. Kabir Ustad at Auto Workshop
	var t1 = trigger_scene.instantiate() as MissionTrigger
	t1.name = "TriggerKabirUstad"
	t1.prompt_speaker = "Kabir Ustad"
	t1.mission_data = StoryMissions.get_mission_1()
	t1.trigger_color = Color(1.0, 0.8, 0.2, 0.8)
	add_child(t1)
	t1.global_position = Vector3(-48.0, 0.2, 99.0)
	
	# 2. Nila Chowdhury at Riverside Stepped Ghat
	var t2 = trigger_scene.instantiate() as MissionTrigger
	t2.name = "TriggerNila"
	t2.prompt_speaker = "Nila Chowdhury"
	t2.mission_data = StoryMissions.get_mission_2()
	t2.trigger_color = Color(0.2, 0.85, 1.0, 0.8)
	add_child(t2)
	t2.global_position = Vector3(-38.0, 0.2, 26.0)
	
	# 3. SI Mahfuz at Lalbagh Police Thana Porch (Mission 3)
	var t3 = trigger_scene.instantiate() as MissionTrigger
	t3.name = "TriggerMahfuz"
	t3.prompt_speaker = "SI Mahfuz"
	t3.mission_data = StoryMissions.get_mission_3()
	t3.trigger_color = Color(0.2, 0.45, 1.0, 0.8)
	add_child(t3)
	t3.global_position = Vector3(75.0, 0.2, -96.0)
	
	# 4. Nila Chowdhury - Mission 4: Hostile Repossession
	var t4 = trigger_scene.instantiate() as MissionTrigger
	t4.name = "TriggerNilaMission4"
	t4.prompt_speaker = "Nila Chowdhury"
	t4.mission_data = StoryMissions.get_mission_4()
	t4.trigger_color = Color(0.9, 0.3, 0.7, 0.8)
	add_child(t4)
	t4.global_position = Vector3(-35.0, 0.2, 28.0)
	
	# 5. SI Mahfuz - Mission 5: The Thana Lockdown
	var t5 = trigger_scene.instantiate() as MissionTrigger
	t5.name = "TriggerMahfuzMission5"
	t5.prompt_speaker = "SI Mahfuz"
	t5.mission_data = StoryMissions.get_mission_5()
	t5.trigger_color = Color(1.0, 0.2, 0.2, 0.8)
	add_child(t5)
	t5.global_position = Vector3(80.0, 0.2, -98.0)


func _spawn_economy_infrastructure() -> void:
	var economy_ui: EconomyUIController = null
	if has_node("UI/EconomyUIController"):
		economy_ui = $UI/EconomyUIController as EconomyUIController
	else:
		var ui_scene = load("res://ui/economy/economy_ui_controller.tscn")
		if ui_scene:
			economy_ui = ui_scene.instantiate() as EconomyUIController
			add_child(economy_ui)
		
	var station_scene = load("res://scripts/economy/shop_station.tscn")
	var atm_scene = load("res://scripts/economy/atm_terminal.tscn")
	var safehouse_scene = load("res://scripts/economy/safehouse_property.tscn")
	
	if station_scene and economy_ui:
		# 1. Mama Tong Cha Stall
		var s1 = station_scene.instantiate() as ShopStation
		s1.name = "StationMamaTong"
		s1.station_type = ShopStation.StationType.FOOD_TONG
		s1.shop_title = "Mama Tong Cha Stall"
		s1.bangla_title = "মামা টং চা দোকান"
		s1.shopkeeper_name = "Kalu Mama"
		s1.station_opened.connect(func(_type, data): economy_ui.open_shop(data))
		add_child(s1)
		s1.global_position = Vector3(-62.0, 0.2, 88.0)
		
		# 2. Bismillah General Store
		var s2 = station_scene.instantiate() as ShopStation
		s2.name = "StationBismillahStore"
		s2.station_type = ShopStation.StationType.GENERAL_STORE
		s2.shop_title = "Bismillah General Store"
		s2.bangla_title = "বিসমিল্লাহ জেনারেল স্টোর"
		s2.shopkeeper_name = "Gaffar Bhai"
		s2.items_for_sale.assign(["medkit", "repair_kit", "money_wad", "cha", "singara"])
		s2.station_opened.connect(func(_type, data): economy_ui.open_shop(data))
		add_child(s2)
		s2.global_position = Vector3(-45.0, 0.2, -42.0)
		
		# 3. Lalbagh Tailors & Desi Fashion
		var s3 = station_scene.instantiate() as ShopStation
		s3.name = "StationLalbaghTailors"
		s3.station_type = ShopStation.StationType.CLOTHING_TAILOR
		s3.shop_title = "Lalbagh Tailors & Desi Fashion"
		s3.bangla_title = "লালবাগ টেইলার্স"
		s3.shopkeeper_name = "Master Rafiq"
		s3.station_opened.connect(func(_type, _data): economy_ui.open_clothing())
		add_child(s3)
		s3.global_position = Vector3(-35.0, 0.2, -42.0)
		
		# 4. Bhai Bhai Auto Workshop Garage Bay
		var s4 = station_scene.instantiate() as ShopStation
		s4.name = "StationBhaiBhaiGarage"
		s4.station_type = ShopStation.StationType.VEHICLE_GARAGE
		s4.shop_title = "Bhai Bhai Auto Workshop Bay"
		s4.bangla_title = "ভাই ভাই অটো ওয়ার্কশপ"
		s4.shopkeeper_name = "Kabir Ustad"
		s4.station_opened.connect(func(_type, _data): economy_ui.open_garage())
		add_child(s4)
		s4.global_position = Vector3(-42.0, 0.2, 94.0)
		
	if atm_scene and economy_ui:
		var atm = atm_scene.instantiate() as AtmTerminal
		atm.name = "RupaliBankAtm"
		atm.atm_opened.connect(func(): economy_ui.open_atm())
		add_child(atm)
		atm.global_position = Vector3(-25.0, 0.2, -35.0)
		
	if safehouse_scene:
		var sh = safehouse_scene.instantiate() as SafehouseProperty
		sh.name = "BurigangaSafehouse"
		sh.property_id = "safehouse_buriganga"
		sh.property_name = "Buriganga Riverview Flat"
		sh.price_bdt = 25000
		add_child(sh)
		sh.global_position = Vector3(35.0, 0.2, 45.0)


func _on_tea_stall_interacted(_user: Node) -> void:
	if GameManager.spend_money(10):
		if player:
			player.current_stamina = player.max_stamina
			EventBus.player_stamina_changed.emit(player.current_stamina, player.max_stamina)
		EventBus.mission_objective_updated.emit(1, "Hot spiced Cha consumed! Stamina fully restored.")
	else:
		EventBus.mission_objective_updated.emit(1, "Not enough money for Cha! Need ৳ 10.")
