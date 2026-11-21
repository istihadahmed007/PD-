# ==============================================================================
# POLICE STATION CONTROLLER (POLICE SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Manages gameplay interactions at the Lalbagh/Padma Police Thana.
#          Features Duty Officer desk interactions (surrender/fines/bribes),
#          impound yard vehicle retrieval, and restricted armory trespassing alarms.
# ==============================================================================
class_name PoliceStationController
extends Node3D

signal fine_paid(amount: int)
signal impound_fee_paid(amount: int)
signal facility_trespass_detected()

@export var station_name: String = "Lalbagh Police Thana (লালবাগ থানা ফাঁড়ি)"
@export var fine_star_1_bdt: int = 500
@export var fine_star_2_bdt: int = 1500
@export var impound_fee_bdt: int = 250

# References
@onready var front_desk_interactable: Interactable = $DutyDesk/InteractableArea if has_node("DutyDesk/InteractableArea") else null
@onready var impound_interactable: Interactable = $ImpoundYard/InteractableArea if has_node("ImpoundYard/InteractableArea") else null
@onready var restricted_area: Area3D = $RestrictedZone/Area3D if has_node("RestrictedZone/Area3D") else null
@onready var audio_radio: AudioStreamPlayer3D = $AudioRadio if has_node("AudioRadio") else null


func _ready() -> void:
	if front_desk_interactable:
		front_desk_interactable.prompt_text = "Speak with Duty Officer (অফিসার ইন চার্জ)"
		front_desk_interactable.interacted.connect(_on_duty_desk_interacted)
	
	if impound_interactable:
		impound_interactable.prompt_text = "Retrieve Impounded Vehicle (৳ %d)" % impound_fee_bdt
		impound_interactable.interacted.connect(_on_impound_interacted)
	
	if restricted_area:
		restricted_area.body_entered.connect(_on_restricted_zone_entered)


func _on_duty_desk_interacted(_user: Node) -> void:
	var stars = GameManager.wanted_stars
	
	if stars == 0:
		# Law-abiding citizen interaction
		EventBus.interaction_available.emit("Duty Officer: 'সব শান্ত আছে। কোনো সন্দেহভাজন দেখলে ৯৯৯ এ কল দিন।' (All quiet. Call 999 for emergencies)", "interact")
		_play_radio_chatter()
	elif stars == 1:
		# Minor offense: option to pay fine
		if GameManager.spend_money(fine_star_1_bdt):
			GameManager.set_wanted_level(0)
			fine_paid.emit(fine_star_1_bdt)
			EventBus.interaction_available.emit("Fine of ৳ %d paid. Wanted level cleared. 'সাবধানে চলাফেরা করবেন!'" % fine_star_1_bdt, "interact")
			_play_radio_chatter()
		else:
			EventBus.interaction_available.emit("Not enough money for fine! Need ৳ %d to clear charges." % fine_star_1_bdt, "interact")
	elif stars == 2:
		# Misdemeanor: pay bail & fine
		if GameManager.spend_money(fine_star_2_bdt):
			GameManager.set_wanted_level(0)
			fine_paid.emit(fine_star_2_bdt)
			EventBus.interaction_available.emit("Bail & Fine of ৳ %d paid. Record cleared by Sub-Inspector." % fine_star_2_bdt, "interact")
			_play_radio_chatter()
		else:
			EventBus.interaction_available.emit("Not enough money for bail! Need ৳ %d." % fine_star_2_bdt, "interact")
	else:
		# Felon with 3+ stars walking into police station!
		EventBus.interaction_available.emit("DUTY OFFICER ALARM: 'সশস্ত্র ফেরারি আসামি থানায়! অ্যারেস্ট করো!' (Armed felon at station!)", "interact")
		# Alert all station units
		EventBus.crime_committed.emit("ASSAULT_POLICE", 1, global_position)


func _on_impound_interacted(_user: Node) -> void:
	if GameManager.spend_money(impound_fee_bdt):
		impound_fee_paid.emit(impound_fee_bdt)
		EventBus.interaction_available.emit("Vehicle retrieved from Thana impound yard! (৳ %d deducted)" % impound_fee_bdt, "interact")
		# Spawn or unlock vehicle in yard
		_spawn_impound_vehicle()
	else:
		EventBus.interaction_available.emit("Insufficient funds! Impound release fee is ৳ %d." % impound_fee_bdt, "interact")


func _on_restricted_zone_entered(body: Node3D) -> void:
	if body == GameManager.active_player or (body is Node and body.is_ancestor_of(GameManager.active_player)):
		facility_trespass_detected.emit()
		EventBus.interaction_available.emit("SECURITY BREACH: Trespassing in Thana Armory! Police alerted!", "interact")
		# Give 2 wanted stars for trespassing
		GameManager.set_wanted_level(maxi(GameManager.wanted_stars, 2))
		EventBus.crime_committed.emit("POLICE_FACILITY_TRESPASS", 2, global_position)


func _spawn_impound_vehicle() -> void:
	# If there's an impound spawn point
	var spawn_marker = get_node_or_null("ImpoundYard/SpawnPoint")
	if spawn_marker:
		var sedan_scene = load("res://vehicles/sedan/sedan.tscn")
		if sedan_scene:
			var car = sedan_scene.instantiate()
			car.global_transform = spawn_marker.global_transform
			car.set_meta("player_owned", true) # Owned so no theft crime
			get_parent().add_child(car)


func _play_radio_chatter() -> void:
	if audio_radio and ResourceLoader.exists("res://audio/police/police_radio.wav"):
		audio_radio.stream = load("res://audio/police/police_radio.wav")
		audio_radio.play()
