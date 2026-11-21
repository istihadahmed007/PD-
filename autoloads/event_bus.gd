# ==============================================================================
# EVENT BUS (AUTOLOAD)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Central decoupled signal routing hub connecting all 14 modular systems.
# ==============================================================================
extends Node

# ------------------------------------------------------------------------------
# 1. PLAYER & CHARACTER SIGNALS
# ------------------------------------------------------------------------------
signal player_spawned(player: Node)
signal player_health_changed(current_health: float, max_health: float)
signal player_stamina_changed(current_stamina: float, max_stamina: float)
signal player_died()
signal player_weapon_switched(weapon_name: String, ammo_count: int)

# ------------------------------------------------------------------------------
# 2. VEHICLE SIGNALS
# ------------------------------------------------------------------------------
signal vehicle_entered(vehicle: Node, seat_name: String)
signal vehicle_exited(vehicle: Node)
signal vehicle_speed_changed(speed_kmh: float)
signal vehicle_health_changed(current_health: float, max_health: float)
signal vehicle_horn_honked(vehicle: Node)
signal vehicle_gear_changed(gear_name: String, rpm: float)
signal vehicle_lights_toggled(headlights_active: bool)

# ------------------------------------------------------------------------------
# 3. INTERACTION SIGNALS
# ------------------------------------------------------------------------------
signal interaction_available(prompt_text: String, action_key: String)
signal interaction_cleared()
signal interaction_triggered(interactable: Node)

# ------------------------------------------------------------------------------
# 4. CRIME & POLICE SIGNALS
# ------------------------------------------------------------------------------
signal crime_committed(crime_type: String, severity: int, location: Vector3)
signal wanted_level_changed(new_stars: int)
signal police_pursuit_started()
signal police_pursuit_evaded()
signal witness_reported_crime(witness_name: String, crime_type: String, location: Vector3)
signal police_search_area_updated(center: Vector3, radius: float, is_active: bool)
signal police_spotted_player(officer: Node, location: Vector3)
signal police_lost_player()
signal police_arrest_triggered(officer: Node)
signal police_checkpoint_alerted(checkpoint_id: String)

# ------------------------------------------------------------------------------
# 5. ECONOMY & COMMERCE SIGNALS (BDT ৳)
# ------------------------------------------------------------------------------
signal money_changed(current_balance: int, delta_amount: int)
signal item_purchased(item_id: String, cost: int)
signal bank_balance_changed(current_balance: int, delta_amount: int)
signal transaction_logged(transaction: Dictionary)
signal inventory_updated()
signal item_used(item_id: String, effect_description: String)
signal item_dropped(item_id: String, quantity: int, position: Vector3)
signal property_purchased(property_id: String, property_name: String)
signal outfit_changed(outfit_id: String)
signal safehouse_entered(property_id: String)
signal vehicle_customized(service_type: String, detail: String)

# ------------------------------------------------------------------------------
# 6. WORLD & WEATHER SIGNALS
# ------------------------------------------------------------------------------
signal time_of_day_updated(hours: int, minutes: int, time_normalized: float)
signal weather_state_changed(weather_name: String, rain_intensity: float)

# ------------------------------------------------------------------------------
# 7. MISSION & QUEST SIGNALS
# ------------------------------------------------------------------------------
signal mission_started(mission_id: String, title: String)
signal mission_objective_updated(step_index: int, description: String)
signal mission_completed(mission_id: String, reward_bdt: int)
signal mission_failed(mission_id: String, reason: String)
signal mission_checkpoint_reached(checkpoint_index: int, location: Vector3)
signal mission_dialogue_line_triggered(speaker_name: String, bengali_text: String, english_text: String, portrait_path: String)
signal mission_dialogue_closed()
signal mission_timer_updated(time_remaining: float)
signal mission_retried(mission_id: String)

# ------------------------------------------------------------------------------
# 8. TRAFFIC & PEDESTRIAN SIGNALS
# ------------------------------------------------------------------------------
signal traffic_jam_detected(intersection_id: String)
signal pedestrian_panicked(threat_position: Vector3)
signal traffic_light_state_changed(intersection_id: String, active_axis: String)
signal simulation_density_changed(ped_density: float, traffic_density: float)
