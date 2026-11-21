# ==============================================================================
# POLICE CHECKPOINT & ROADBLOCK (POLICE SYSTEM)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: DMP Roadblock Checkpoint deployed at strategic bridges and avenues.
#          Features reflective barricades, flashing hazard beacons, parked cruisers,
#          armed guards, and dynamic tire spike strips with puncture physics.
# ==============================================================================
class_name PoliceCheckpoint
extends Node3D

signal vehicle_spiked(vehicle: Node)
signal checkpoint_breached()

enum CheckpointMode {
	PASSIVE_MONITOR, # Wanted 0-2: Officers observe, traffic passes slowly
	TACTICAL_LOCKDOWN # Wanted 3-5: Barricades armed, spikes active, officers engage
}

@export var checkpoint_id: String = "checkpoint_buriganga_bridge"
@export var checkpoint_name: String = "Canal Bridge DMP Checkpoint"
@export var activate_at_wanted_level: int = 3

var current_mode: CheckpointMode = CheckpointMode.PASSIVE_MONITOR
var is_spikes_armed: bool = false
var hazard_flash_timer: float = 0.0
var hazard_phase: bool = false

# References
@onready var spike_strip_area: Area3D = $SpikeStripArea if has_node("SpikeStripArea") else null
@onready var hazard_light_1: OmniLight3D = $HazardLights/Light1 if has_node("HazardLights/Light1") else null
@onready var hazard_light_2: OmniLight3D = $HazardLights/Light2 if has_node("HazardLights/Light2") else null
@onready var audio_puncture: AudioStreamPlayer3D = $AudioPuncture if has_node("AudioPuncture") else null
@onready var guards_container: Node3D = $Guards if has_node("Guards") else null


func _ready() -> void:
	EventBus.wanted_level_changed.connect(_on_wanted_level_changed)
	
	if spike_strip_area:
		spike_strip_area.body_entered.connect(_on_spike_strip_body_entered)
	
	_on_wanted_level_changed(GameManager.wanted_stars)


func _physics_process(delta: float) -> void:
	hazard_flash_timer += delta
	var flash_interval = 0.25 if current_mode == CheckpointMode.TACTICAL_LOCKDOWN else 0.65
	
	if hazard_flash_timer >= flash_interval:
		hazard_flash_timer = 0.0
		hazard_phase = not hazard_phase
		
		if hazard_light_1:
			hazard_light_1.visible = hazard_phase
		if hazard_light_2:
			hazard_light_2.visible = not hazard_phase


func _on_wanted_level_changed(stars: int) -> void:
	if stars >= activate_at_wanted_level:
		current_mode = CheckpointMode.TACTICAL_LOCKDOWN
		is_spikes_armed = true
		_alert_checkpoint_guards(true)
	else:
		current_mode = CheckpointMode.PASSIVE_MONITOR
		is_spikes_armed = false
		_alert_checkpoint_guards(false)


func _alert_checkpoint_guards(aggressive: bool) -> void:
	if not guards_container:
		return
	
	for child in guards_container.get_children():
		if child is PoliceOfficer:
			var officer = child as PoliceOfficer
			if aggressive:
				officer.current_state = PoliceOfficer.OfficerState.PURSUE_FOOT
			else:
				officer.current_state = PoliceOfficer.OfficerState.GUARD_CHECKPOINT


func _on_spike_strip_body_entered(body: Node3D) -> void:
	if not is_spikes_armed:
		return
	
	if body is BaseVehicle3D:
		var v = body as BaseVehicle3D
		_puncture_vehicle_tires(v)
	elif body is CharacterBody3D and body == GameManager.active_player:
		# Player on foot sprinting through spikes
		body.damage(body.global_position, Vector3.UP * 5.0)


func _puncture_vehicle_tires(vehicle: BaseVehicle3D) -> void:
	# Audio feedback
	if audio_puncture:
		audio_puncture.play()
	
	# Degrade vehicle dynamics
	vehicle.base_max_speed_kmh = 24.0 # Severely restricted top speed
	vehicle.max_engine_force = vehicle.max_engine_force * 0.35
	vehicle.steer_speed = vehicle.steer_speed * 0.4
	
	# Apply destabilizing torque impulse
	vehicle.apply_torque_impulse(Vector3(0, randf_range(-1500.0, 1500.0), 0))
	
	vehicle_spiked.emit(vehicle)
	checkpoint_breached.emit()
	EventBus.police_checkpoint_alerted.emit(checkpoint_id)
