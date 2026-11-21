# ==============================================================================
# SAFEHOUSE PROPERTY COMPONENT (ECONOMY & HOUSING)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Manages purchasable residential properties, safehouses, resting/sleep,
#          wardrobe access, private stash storage, and save triggers.
# ==============================================================================
class_name SafehouseProperty
extends Node3D

signal property_entered(property_id: String)

@export var property_id: String = "safehouse_buriganga"
@export var property_name: String = "Buriganga Riverview Flat"
@export var price_bdt: int = 25000

@onready var interactable_main: Interactable = $InteractableMain if has_node("InteractableMain") else null
@onready var sign_label: Label3D = $Signboard/Label3D if has_node("Signboard/Label3D") else null
@onready var marker_light: OmniLight3D = $MarkerLight if has_node("MarkerLight") else null


func _ready() -> void:
	_update_property_state()
	EventBus.property_purchased.connect(_on_property_purchased_globally)


func _update_property_state() -> void:
	var is_owned = GameManager.is_property_owned(property_id)
	
	if sign_label:
		if is_owned:
			sign_label.text = "PADMA HOUSING LTD.\n[ PRIVATE SAFEHOUSE ]\nJoynal Abedin"
			sign_label.modulate = Color(0.2, 0.95, 0.4)
		else:
			sign_label.text = "PADMA HOUSING LTD.\n[ FOR SALE ]\n৳ %s" % EconomySystem.format_bdt(price_bdt)
			sign_label.modulate = Color(1.0, 0.8, 0.2)
			
	if marker_light:
		marker_light.light_color = Color(0.2, 0.9, 0.4) if is_owned else Color(1.0, 0.75, 0.2)
		
	if interactable_main:
		if is_owned:
			interactable_main.prompt_text = "Enter Safehouse & Rest"
		else:
			interactable_main.prompt_text = "Buy Safehouse (%s)" % EconomySystem.format_bdt(price_bdt)
			
		if not interactable_main.interacted.is_connected(_on_interacted):
			interactable_main.interacted.connect(_on_interacted)


func _on_interacted(user: Node) -> void:
	var is_owned = GameManager.is_property_owned(property_id)
	
	if not is_owned:
		# Attempt purchase
		var bought = GameManager.purchase_property(property_id, price_bdt, property_name)
		if bought:
			AudioManager.play_sfx("res://audio/economy/door_unlock.wav")
			_update_property_state()
			EventBus.mission_objective_updated.emit(1, "Purchased Safehouse: %s!" % property_name)
		else:
			AudioManager.play_sfx("res://audio/police/handcuff_click.wav")
			EventBus.mission_objective_updated.emit(1, "Insufficient funds! Need %s (Wallet or Bank)." % EconomySystem.format_bdt(price_bdt))
	else:
		# Access safehouse amenities: Sleep / Save / Heal
		_use_safehouse_amenities(user)


func _use_safehouse_amenities(user: Node) -> void:
	AudioManager.play_sfx("res://audio/economy/door_unlock.wav")
	
	# 1. Advance Time by 6 hours
	GameManager.advance_time(6)
	
	# 2. Heal player and restore stamina
	var p = user if user else GameManager.active_player
	if p:
		if "current_health" in p:
			p.current_health = p.max_health
			EventBus.player_health_changed.emit(p.current_health, p.max_health)
		if "current_stamina" in p:
			p.current_stamina = p.max_stamina
			EventBus.player_stamina_changed.emit(p.current_stamina, p.max_stamina)
			
	# 3. Clear low wanted stars inside safehouse (safe haven)
	if GameManager.wanted_stars <= 2:
		GameManager.set_wanted_level(0)
		
	# 4. Trigger auto-save
	var p_pos = p.global_position if p else Vector3.ZERO
	SaveSystem.save_game(p_pos, GameManager.wallet_bdt, GameManager.wanted_stars, [])
	
	EventBus.safehouse_entered.emit(property_id)
	EventBus.mission_objective_updated.emit(1, "Rested in Safehouse. Health Restored. Game Saved.")


func _on_property_purchased_globally(p_id: String, _p_name: String) -> void:
	if p_id == property_id:
		_update_property_state()
