# ==============================================================================
# WORLD NAVIGATION MAP UI (CARTOGRAPHIC GPS & FAST TRAVEL)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Interactive full-screen navigation map displaying the 7 connected regions,
#          national highways (NH-1, NH-2, NH-3), rivers, live player GPS position,
#          and debug fast travel shortcuts.
# ==============================================================================
class_name WorldMapUI
extends CanvasLayer

signal closed()

@onready var current_region_label: Label = $Panel/VBox/Header/RegionLabel
@onready var coords_label: Label = $Panel/VBox/Header/CoordsLabel
@onready var close_btn: Button = $Panel/VBox/Footer/CloseBtn
@onready var map_canvas: Control = $Panel/VBox/MapArea/MapCanvas

const REGION_SPAWN_COORDS := {
	"dhaka": Vector3(0.0, 0.5, 0.0),
	"rajshahi": Vector3(-1024.0, 0.5, 0.0),
	"sylhet": Vector3(512.0, 0.5, 512.0),
	"chattogram": Vector3(512.0, 0.5, -512.0),
	"cox_bazar": Vector3(512.0, 0.5, -1024.0),
	"sundarbans": Vector3(-512.0, 0.5, -768.0),
	"rural_plains": Vector3(-512.0, 0.5, 0.0)
}


func _ready() -> void:
	layer = 14
	hide()
	if close_btn:
		close_btn.pressed.connect(toggle_map)
		
	var btn_dhaka = get_node_or_null("Panel/VBox/MapArea/FastTravelSidebar/BtnDhaka")
	var btn_raj = get_node_or_null("Panel/VBox/MapArea/FastTravelSidebar/BtnRajshahi")
	var btn_syl = get_node_or_null("Panel/VBox/MapArea/FastTravelSidebar/BtnSylhet")
	var btn_chat = get_node_or_null("Panel/VBox/MapArea/FastTravelSidebar/BtnChattogram")
	var btn_cox = get_node_or_null("Panel/VBox/MapArea/FastTravelSidebar/BtnCox")
	var btn_sun = get_node_or_null("Panel/VBox/MapArea/FastTravelSidebar/BtnSundarbans")
	var btn_rur = get_node_or_null("Panel/VBox/MapArea/FastTravelSidebar/BtnRural")
	
	if btn_dhaka: btn_dhaka.pressed.connect(func(): fast_travel("dhaka"))
	if btn_raj: btn_raj.pressed.connect(func(): fast_travel("rajshahi"))
	if btn_syl: btn_syl.pressed.connect(func(): fast_travel("sylhet"))
	if btn_chat: btn_chat.pressed.connect(func(): fast_travel("chattogram"))
	if btn_cox: btn_cox.pressed.connect(func(): fast_travel("cox_bazar"))
	if btn_sun: btn_sun.pressed.connect(func(): fast_travel("sundarbans"))
	if btn_rur: btn_rur.pressed.connect(func(): fast_travel("rural_plains"))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_M:
			toggle_map()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE and visible:
			toggle_map()
			get_viewport().set_input_as_handled()


func toggle_map() -> void:
	if visible:
		hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		closed.emit()
	else:
		show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_update_map_display()


func _update_map_display() -> void:
	var player = GameManager.active_player
	if not player:
		return
		
	var pos = player.global_position
	if coords_label:
		coords_label.text = "GPS Coordinates: X: %d  |  Z: %d" % [int(pos.x), int(pos.z)]
		
	var region_id := "dhaka"
	if has_node("/root/RegionalBiomeManager"):
		var bm = get_node("/root/RegionalBiomeManager")
		region_id = bm.current_region
	elif pos.x > 256.0 and pos.z > 256.0:
		region_id = "sylhet"
	elif pos.x > 256.0 and pos.z < -768.0:
		region_id = "cox_bazar"
	elif pos.x > 256.0 and pos.z <= 256.0:
		region_id = "chattogram"
	elif pos.x < -256.0 and pos.z < -384.0:
		region_id = "sundarbans"
	elif pos.x < -768.0:
		region_id = "rajshahi"
	elif pos.x <= -256.0:
		region_id = "rural_plains"
		
	var info: Dictionary = RegionalBiomeManager.BIOMES.get(region_id, {})
	if current_region_label:
		current_region_label.text = "Current Sector: %s (%s)" % [
			info.get("title", region_id.capitalize()),
			info.get("bangla", "")
		]


func fast_travel(region_key: String) -> void:
	if not REGION_SPAWN_COORDS.has(region_key):
		return
	var dest: Vector3 = REGION_SPAWN_COORDS[region_key]
	var player = GameManager.active_player
	if player:
		player.global_position = dest
		if GameManager.active_vehicle:
			GameManager.active_vehicle.global_position = dest + Vector3(4, 0, 0)
	toggle_map()
	EventBus.mission_objective_updated.emit(1, "Fast traveled to %s!" % region_key.capitalize())
