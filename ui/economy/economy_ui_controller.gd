# ==============================================================================
# ECONOMY UI CONTROLLER (MASTER MODAL MANAGER)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Orchestrates all economy screens (Shop, Garage, ATM, Clothing, Inventory)
#          and manages mouse capture, hotkeys [I, Tab, ESC], and station signals.
# ==============================================================================
class_name EconomyUIController
extends CanvasLayer

@onready var shop_modal: ShopModal = $ShopModal if has_node("ShopModal") else null
@onready var garage_modal: GarageModal = $GarageModal if has_node("GarageModal") else null
@onready var atm_modal: AtmModal = $AtmModal if has_node("AtmModal") else null
@onready var clothing_modal: ClothingModal = $ClothingModal if has_node("ClothingModal") else null
@onready var inventory_modal: InventoryModal = $InventoryModal if has_node("InventoryModal") else null


func _ready() -> void:
	layer = 12
	_hide_all_modals()
	
	if shop_modal: shop_modal.closed.connect(_on_modal_closed)
	if garage_modal: garage_modal.closed.connect(_on_modal_closed)
	if atm_modal: atm_modal.closed.connect(_on_modal_closed)
	if clothing_modal: clothing_modal.closed.connect(_on_modal_closed)
	if inventory_modal: inventory_modal.closed.connect(_on_modal_closed)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_I or event.keycode == KEY_TAB:
			toggle_inventory()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE:
			if is_any_modal_open():
				_hide_all_modals()
				_on_modal_closed()
				get_viewport().set_input_as_handled()


func is_any_modal_open() -> bool:
	return (shop_modal and shop_modal.visible) or \
		   (garage_modal and garage_modal.visible) or \
		   (atm_modal and atm_modal.visible) or \
		   (clothing_modal and clothing_modal.visible) or \
		   (inventory_modal and inventory_modal.visible)


func toggle_inventory() -> void:
	if inventory_modal and inventory_modal.visible:
		inventory_modal.close()
	else:
		_hide_all_modals()
		if inventory_modal:
			inventory_modal.open_inventory()
			_set_modal_active_state(true)


func open_shop(shop_data: Dictionary) -> void:
	_hide_all_modals()
	if shop_modal:
		shop_modal.open_shop(shop_data)
		_set_modal_active_state(true)


func open_garage(vehicle: BaseVehicle3D = null) -> void:
	_hide_all_modals()
	if garage_modal:
		garage_modal.open_garage(vehicle)
		_set_modal_active_state(true)


func open_atm() -> void:
	_hide_all_modals()
	if atm_modal:
		atm_modal.open_atm()
		_set_modal_active_state(true)


func open_clothing() -> void:
	_hide_all_modals()
	if clothing_modal:
		clothing_modal.open_wardrobe()
		_set_modal_active_state(true)


func _hide_all_modals() -> void:
	if shop_modal: shop_modal.hide()
	if garage_modal: garage_modal.hide()
	if atm_modal: atm_modal.hide()
	if clothing_modal: clothing_modal.hide()
	if inventory_modal: inventory_modal.hide()


func _set_modal_active_state(is_open: bool) -> void:
	if is_open:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_modal_closed() -> void:
	_set_modal_active_state(false)
