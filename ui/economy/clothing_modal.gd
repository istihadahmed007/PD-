# ==============================================================================
# CLOTHING MODAL (LALBAGH TAILORS & DESI FASHION)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Functional wardrobe and clothing shop interface for purchasing and equipping
#          authentic Dhaka urban outfits, panjabis, lungis, and tactical gear.
# ==============================================================================
class_name ClothingModal
extends Control

signal closed()

@onready var wallet_label: Label = $Panel/VBox/Header/WalletLabel
@onready var outfit_container: VBoxContainer = $Panel/VBox/Scroll/OutfitContainer
@onready var close_btn: Button = $Panel/VBox/Footer/CloseBtn


func _ready() -> void:
	if close_btn:
		close_btn.pressed.connect(close)
	EventBus.money_changed.connect(func(_b, _d): _update_display())
	EventBus.outfit_changed.connect(func(_o): _update_display())


func open_wardrobe() -> void:
	show()
	_update_display()


func close() -> void:
	hide()
	closed.emit()


func _update_display() -> void:
	if wallet_label:
		wallet_label.text = "Cash: %s  |  Bank: %s" % [
			EconomySystem.format_bdt(GameManager.wallet_bdt),
			EconomySystem.format_bdt(GameManager.bank_bdt)
		]
		
	if not outfit_container:
		return
		
	for child in outfit_container.get_children():
		child.queue_free()
		
	for outfit_id in EconomySystem.OUTFITS:
		var outfit_info: Dictionary = EconomySystem.get_outfit(outfit_id)
		var row := _create_outfit_row(outfit_info)
		outfit_container.add_child(row)


func _create_outfit_row(info: Dictionary) -> PanelContainer:
	var panel = PanelContainer.new()
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	panel.add_child(row)
	
	var outfit_id: String = info["id"]
	var outfit_name: String = info.get("name", outfit_id.capitalize())
	var bangla_name: String = info.get("bangla_name", "")
	var price: int = info.get("price", 0)
	var desc: String = info.get("desc", "")
	var is_equipped: bool = (GameManager.current_outfit == outfit_id)
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var title = Label.new()
	title.text = "%s  [%s]" % [outfit_name, bangla_name]
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3) if is_equipped else Color(0.95, 0.95, 0.95))
	vbox.add_child(title)
	
	var desc_lbl = Label.new()
	desc_lbl.text = desc
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	vbox.add_child(desc_lbl)
	
	row.add_child(vbox)
	
	var action_btn = Button.new()
	action_btn.custom_minimum_size = Vector2(160, 36)
	
	if is_equipped:
		action_btn.text = "EQUIPPED (পরিহিত)"
		action_btn.disabled = true
	else:
		if price == 0:
			action_btn.text = "Equip (Free)"
			action_btn.pressed.connect(func():
				GameManager.equip_outfit(outfit_id)
				_update_display()
			)
		else:
			action_btn.text = "Buy & Equip (%s)" % EconomySystem.format_bdt(price)
			action_btn.disabled = (GameManager.wallet_bdt < price)
			action_btn.pressed.connect(func():
				if GameManager.spend_money(price, "Lalbagh Tailors: " + outfit_name, "CLOTHING"):
					GameManager.equip_outfit(outfit_id)
					_update_display()
			)
	row.add_child(action_btn)
	
	return panel
