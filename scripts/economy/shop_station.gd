# ==============================================================================
# SHOP STATION ENTITY (ECONOMY & COMMERCE)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Reusable 3D shopkeeper booth / counter trigger for food stalls,
#          general markets, clothing boutiques, and vehicle garages.
# ==============================================================================
class_name ShopStation
extends Node3D

signal station_opened(station_type: int, station_info: Dictionary)

enum StationType {
	FOOD_TONG,
	GENERAL_STORE,
	CLOTHING_TAILOR,
	VEHICLE_GARAGE
}

@export var station_type: StationType = StationType.FOOD_TONG
@export var shop_title: String = "Mama Tong Cha Stall"
@export var bangla_title: String = "মামা টং চা দোকান"
@export var shopkeeper_name: String = "Kalu Mama"
@export var items_for_sale: Array[String] = ["cha", "singara", "samucha", "speed_drink", "kacchi_biryani"]

@onready var interactable: Interactable = $Interactable if has_node("Interactable") else null
@onready var title_label: Label3D = $Sign/Label3D if has_node("Sign/Label3D") else null


func _ready() -> void:
	if title_label:
		title_label.text = "%s\n%s" % [shop_title, bangla_title]
	
	if interactable:
		interactable.prompt_text = "Browse " + shop_title
		interactable.interacted.connect(_on_shop_interacted)


func _on_shop_interacted(_user: Node) -> void:
	AudioManager.play_sfx("res://audio/economy/cash_register.wav")
	
	var data := {
		"station_type": station_type,
		"title": shop_title,
		"bangla_title": bangla_title,
		"shopkeeper": shopkeeper_name,
		"items": items_for_sale
	}
	station_opened.emit(station_type, data)
