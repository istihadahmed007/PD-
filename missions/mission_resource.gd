# ==============================================================================
# MISSION RESOURCE (MISSION SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Master data container for original story missions, driving runs,
#          delivery tasks, rescues, and syndicate investigations.
# ==============================================================================
class_name MissionResource
extends Resource

enum MissionType {
	STORY,
	DRIVING,
	DELIVERY,
	INVESTIGATION,
	RESCUE,
	CHASE,
	SIDE_ACTIVITY,
	EXPLORATION
}

@export_category("Mission Identity")
@export var mission_id: String = "m01_shadows_and_sparkplugs"
@export var title: String = "Shadows & Spark Plugs (ছায়া ও চালক)"
@export var mission_type: MissionType = MissionType.STORY
@export_multiline var description: String = "Joy assists Kabir Ustad in making an urgent delivery of tuned carburetor parts across the canal before debt collectors arrive."
@export var prerequisite_mission_id: String = ""

@export_category("Mission Giver")
@export var giver_name: String = "Kabir Ustad (কবির ওস্তাদ)"
@export var giver_location: Vector3 = Vector3(-48.0, 0.2, 96.0) # Auto Workshop
@export var giver_portrait_path: String = "res://assets/textures/characters/portrait_kabir.png"

@export_category("Rewards")
@export var reward_bdt: int = 1500
@export var reward_xp: int = 250
@export var reward_items: Array[String] = []

@export_category("Objectives & Progression")
## Array of Dictionary steps:
## {
##   "type": "GOTO" | "TALK" | "DRIVE" | "DELIVER" | "CHASE" | "INVESTIGATE" | "DEFEND",
##   "description": "Drive across the canal bridge to the Commercial Bazaar",
##   "target_position": Vector3(x, y, z),
##   "target_radius": 5.0,
##   "target_entity": "GaffarBhai",
##   "time_limit": 180.0,
##   "fragile_cargo": true,
##   "dialogue_before": "d_intro",
##   "dialogue_after": "d_finish",
##   "checkpoint": Vector3(x, y, z)
## }
@export var steps: Array[Dictionary] = []

@export_category("Dialogue Sequences")
## Dictionary mapping dialogue_id -> Array of lines:
## {
##   "d_intro": [
##     {"speaker": "Kabir Ustad", "bengali": "...", "english": "...", "portrait": "..."},
##     {"speaker": "Joy", "bengali": "...", "english": "...", "portrait": "..."}
##   ]
## }
@export var dialogues: Dictionary = {}


func get_step(step_index: int) -> Dictionary:
	if step_index >= 0 and step_index < steps.size():
		return steps[step_index]
	return {}


func get_dialogue(dialogue_id: String) -> Array:
	if dialogues.has(dialogue_id):
		return dialogues[dialogue_id]
	return []


func get_total_steps() -> int:
	return steps.size()
