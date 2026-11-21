# ==============================================================================
# WITNESS COMPONENT (POLICE SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Enables civilian NPCs to observe crimes, react with panic/shouts,
#          and report crimes to DMP Dispatch (999 Emergency) after an interactive delay.
# ==============================================================================
class_name WitnessComponent
extends Node3D

signal reporting_started(crime_type: String, duration: float)
signal reporting_cancelled(reason: String)
signal crime_reported_to_police(crime_type: String, severity: int, location: Vector3)

@export var witness_range_visual: float = 28.0
@export var witness_range_gunfire: float = 48.0
@export var report_call_duration: float = 3.5
@export var can_report: bool = true

var is_reporting: bool = false
var report_timer: float = 0.0
var pending_crime_type: String = ""
var pending_severity: int = 1
var pending_location: Vector3 = Vector3.ZERO

# 3D Visual Indicator above head
var call_indicator: Label3D = null
var shout_audio: AudioStreamPlayer3D = null


func _ready() -> void:
	_create_visual_indicator()
	_setup_shout_audio()


func _create_visual_indicator() -> void:
	call_indicator = Label3D.new()
	call_indicator.text = "[!] 999 CALLING..."
	call_indicator.font_size = 32
	call_indicator.modulate = Color(1.0, 0.25, 0.2, 1.0)
	call_indicator.outline_modulate = Color(0.1, 0.1, 0.1, 1.0)
	call_indicator.outline_size = 8
	call_indicator.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	call_indicator.position = Vector3(0, 2.2, 0)
	call_indicator.visible = false
	add_child(call_indicator)


func _setup_shout_audio() -> void:
	shout_audio = AudioStreamPlayer3D.new()
	shout_audio.name = "WitnessShoutAudio"
	shout_audio.max_distance = 35.0
	shout_audio.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	
	# Load pedestrian shout if available
	if ResourceLoader.exists("res://audio/city/pedestrian_shout_1.wav"):
		shout_audio.stream = load("res://audio/city/pedestrian_shout_1.wav")
	add_child(shout_audio)


func _process(delta: float) -> void:
	if not is_reporting:
		return
	
	report_timer -= delta
	if call_indicator:
		call_indicator.text = "[!] 999 DIALING (%1.1fs)" % maxf(0.0, report_timer)
	
	# Check cancellation conditions: suspect too far away or witness disabled
	var parent_body = get_parent()
	if parent_body is CharacterBody3D and parent_body.velocity.length() > 15.0: # Knocked away by car/explosion
		cancel_report("Witness knocked down")
		return
	
	if is_instance_valid(GameManager.active_player):
		var dist = global_position.distance_to(GameManager.active_player.global_position)
		if dist > 65.0:
			# Suspect escaped the scene before call completed
			cancel_report("Suspect fled the vicinity")
			return
	
	if report_timer <= 0.0:
		_complete_crime_report()


func observe_crime(crime_type: String, severity: int, location: Vector3) -> bool:
	if not can_report or is_reporting:
		return false
	
	var dist := global_position.distance_to(location)
	var max_range := witness_range_gunfire if crime_type.contains("FIREARM") or crime_type.contains("GUN") else witness_range_visual
	
	if dist > max_range:
		return false
	
	# Start reporting sequence
	pending_crime_type = crime_type
	pending_severity = severity
	pending_location = location
	is_reporting = true
	report_timer = report_call_duration
	
	if call_indicator:
		call_indicator.visible = true
	
	# Play panic shout
	if shout_audio and shout_audio.stream:
		shout_audio.pitch_scale = randf_range(0.95, 1.25)
		shout_audio.play()
	
	# Trigger panic animation / state on parent pedestrian if applicable
	var parent_body = get_parent()
	if parent_body and parent_body.has_method("trigger_panic"):
		parent_body.trigger_panic(location)
	
	reporting_started.emit(crime_type, report_call_duration)
	return true


func cancel_report(reason: String) -> void:
	is_reporting = false
	report_timer = 0.0
	if call_indicator:
		call_indicator.visible = false
	reporting_cancelled.emit(reason)


func _complete_crime_report() -> void:
	is_reporting = false
	if call_indicator:
		call_indicator.text = "[✓] REPORT DISPATCHED!"
		call_indicator.modulate = Color(0.2, 0.9, 0.3, 1.0)
		get_tree().create_timer(1.2).timeout.connect(func(): if is_instance_valid(call_indicator): call_indicator.visible = false)
	
	var witness_name = get_parent().name if get_parent() else "Civilian Witness"
	EventBus.witness_reported_crime.emit(witness_name, pending_crime_type, pending_location)
	EventBus.crime_committed.emit(pending_crime_type, pending_severity, pending_location)
	crime_reported_to_police.emit(pending_crime_type, pending_severity, pending_location)
