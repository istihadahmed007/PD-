# ==============================================================================
# SHOP MODAL (ECONOMY UI)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Functional shop interface for purchasing/selling food, drinks,
#          and utility items with Bengali/English typography and real transactions.
# ==============================================================================
class_name ShopModal
extends Control

signal closed()

@onready var title_label: Label = $Panel/VBox/Header/TitleLabel
@onready var shopkeeper_label: Label = $Panel/VBox/Header/ShopkeeperLabel
@onready var wallet_label: Label = $Panel/VBox/Header/WalletLabel
@onready var item_container: VBoxContainer = $Panel/VBox/Scroll/ItemContainer
@onready var close_button: Button = $Panel/VBox/Footer/CloseButton

var current_shop_data: Dictionary = {}


func _ready() -> void:
	if close_button:
		close_button.pressed.connect(close)
	EventBus.money_changed.connect(_on_money_changed)
	EventBus.inventory_updated.connect(_refresh_items)


func open_shop(shop_data: Dictionary) -> void:
	current_shop_data = shop_data
	show()
	_update_header()
	_refresh_items()


func close() -> void:
	hide()
	closed.emit()


func _update_header() -> void:
	if title_label:
		var t = current_shop_data.get("title", "Local Market")
		var bt = current_shop_data.get("bangla_title", "")
		title_label.text = "%s (%s)" % [t, bt] if bt != "" else t
	
	if shopkeeper_label:
		var sk = current_shop_data.get("shopkeeper", "Shopkeeper")
		shopkeeper_label.text = "Merchant: " + sk
	
	_on_money_changed(GameManager.wallet_bdt, 0)


func _on_money_changed(balance: int, _delta: int) -> void:
	if wallet_label:
		wallet_label.text = "Cash: %s  |  Bank: %s" % [
			EconomySystem.format_bdt(balance),
			EconomySystem.format_bdt(GameManager.bank_bdt)
		]


func _refresh_items() -> void:
	if not item_container:
		return
	
	# Clear previous entries
	for child in item_container.get_children():
		child.queue_free()
	
	var items: Array = current_shop_data.get("items", [])
	if items.is_empty():
		items = ["cha", "singara", "samucha", "speed_drink", "kacchi_biryani", "medkit", "repair_kit"]
	
	for item_id in items:
		var item_info: Dictionary = EconomySystem.get_item(item_id)
		if item_info.is_empty():
			continue
		
		var row := _create_item_row(item_info)
		item_container.add_child(row)


func _create_item_row(info: Dictionary) -> PanelContainer:
	var panel = PanelContainer.new()
	var row_box = HBoxContainer.new()
	row_box.add_theme_constant_override("separation", 12)
	panel.add_child(row_box)
	
	var item_id: String = info["id"]
	var item_name: String = info.get("name", item_id.capitalize())
	var bangla_name: String = info.get("bangla_name", "")
	var price: int = info.get("price", 10)
	var desc: String = info.get("desc", "")
	var player_has: int = GameManager.inventory.get_item_count(item_id)
	
	# Details Box
	var details_box = VBoxContainer.new()
	details_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var name_label = Label.new()
	name_label.text = "%s  [%s]" % [item_name, bangla_name]
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	details_box.add_child(name_label)
	
	var desc_label = Label.new()
	desc_label.text = desc
	desc_label.add_theme_font_size_override("font_size", 11)
	desc_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	details_box.add_child(desc_label)
	
	var owned_label = Label.new()
	owned_label.text = "In Bag: %d  |  Price: %s" % [player_has, EconomySystem.format_bdt(price)]
	owned_label.add_theme_font_size_override("font_size", 11)
	owned_label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.4))
	details_box.add_child(owned_label)
	
	row_box.add_child(details_box)
	
	# Buy Button
	var buy_btn = Button.new()
	buy_btn.text = "Buy (%s)" % EconomySystem.format_bdt(price)
	buy_btn.custom_minimum_size = Vector2(110, 36)
	buy_btn.disabled = (GameManager.wallet_bdt < price)
	buy_btn.pressed.connect(func():
		_on_buy_pressed(item_id, price, item_name)
	)
	row_box.add_child(buy_btn)
	
	# Sell Button (40% discount)
	var sell_price: int = maxi(1, int(float(price) * 0.6))
	var sell_btn = Button.new()
	sell_btn.text = "Sell (%s)" % EconomySystem.format_bdt(sell_price)
	sell_btn.custom_minimum_size = Vector2(100, 36)
	sell_btn.disabled = (player_has <= 0)
	sell_btn.pressed.connect(func():
		_on_sell_pressed(item_id, sell_price, item_name)
	)
	row_box.add_child(sell_btn)
	
	return panel


func _on_buy_pressed(item_id: String, price: int, item_name: String) -> void:
	if GameManager.spend_money(price, "Bought %s" % item_name, "PURCHASE"):
		GameManager.inventory.add_item(item_id, 1)
		AudioManager.play_sfx("res://audio/economy/cash_register.wav")
		_refresh_items()


func _on_sell_pressed(item_id: String, sell_price: int, item_name: String) -> void:
	if GameManager.inventory.remove_item(item_id, 1):
		GameManager.add_money(sell_price, "Sold %s" % item_name, "INCOME")
		AudioManager.play_sfx("res://audio/economy/coin_drop.wav")
		_refresh_items()
