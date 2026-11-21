# ==============================================================================
# ATM TERMINAL (RUPALI BANK / BKASH FAST POINT)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: 3D in-world ATM kiosk allowing cash deposits, withdrawals, and ledger.
# ==============================================================================
class_name AtmTerminal
extends Node3D

signal atm_opened()

@onready var interactable: Interactable = $Interactable if has_node("Interactable") else null


func _ready() -> void:
	if interactable:
		interactable.prompt_text = "Use Rupali Bank ATM"
		interactable.interacted.connect(_on_atm_interacted)


func _on_atm_interacted(_user: Node) -> void:
	AudioManager.play_sfx("res://audio/economy/atm_beep.wav")
	atm_opened.emit()
