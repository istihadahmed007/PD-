# ==============================================================================
# ATM MODAL (RUPALI BANK / BKASH FAST POINT)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Functional ATM terminal for cash deposits, withdrawals, and digital ledger.
# ==============================================================================
class_name AtmModal
extends Control

signal closed()

@onready var wallet_label: Label = $Panel/VBox/BalanceBox/WalletLabel
@onready var bank_label: Label = $Panel/VBox/BalanceBox/BankLabel
@onready var ledger_container: VBoxContainer = $Panel/VBox/HistoryBox/Scroll/LedgerContainer
@onready var exit_button: Button = $Panel/VBox/Footer/ExitButton

# Deposit buttons
@onready var dep_500: Button = $Panel/VBox/Actions/DepositBox/Dep500
@onready var dep_2000: Button = $Panel/VBox/Actions/DepositBox/Dep2000
@onready var dep_5000: Button = $Panel/VBox/Actions/DepositBox/Dep5000
@onready var dep_all: Button = $Panel/VBox/Actions/DepositBox/DepAll

# Withdraw buttons
@onready var with_500: Button = $Panel/VBox/Actions/WithdrawBox/With500
@onready var with_2000: Button = $Panel/VBox/Actions/WithdrawBox/With2000
@onready var with_5000: Button = $Panel/VBox/Actions/WithdrawBox/With5000
@onready var with_all: Button = $Panel/VBox/Actions/WithdrawBox/WithAll


func _ready() -> void:
	if exit_button:
		exit_button.pressed.connect(close)
		
	if dep_500: dep_500.pressed.connect(func(): _deposit(500))
	if dep_2000: dep_2000.pressed.connect(func(): _deposit(2000))
	if dep_5000: dep_5000.pressed.connect(func(): _deposit(5000))
	if dep_all: dep_all.pressed.connect(func(): _deposit(GameManager.wallet_bdt))
	
	if with_500: with_500.pressed.connect(func(): _withdraw(500))
	if with_2000: with_2000.pressed.connect(func(): _withdraw(2000))
	if with_5000: with_5000.pressed.connect(func(): _withdraw(5000))
	if with_all: with_all.pressed.connect(func(): _withdraw(GameManager.bank_bdt))
	
	EventBus.money_changed.connect(func(_b, _d): _update_display())
	EventBus.bank_balance_changed.connect(func(_b, _d): _update_display())
	EventBus.transaction_logged.connect(func(_entry): _refresh_ledger())


func open_atm() -> void:
	show()
	_update_display()
	_refresh_ledger()
	AudioManager.play_sfx("res://audio/economy/atm_beep.wav")


func close() -> void:
	hide()
	closed.emit()


func _deposit(amount: int) -> void:
	if GameManager.deposit_to_bank(amount):
		AudioManager.play_sfx("res://audio/economy/cash_register.wav")
	else:
		AudioManager.play_sfx("res://audio/police/handcuff_click.wav")
	_update_display()


func _withdraw(amount: int) -> void:
	if GameManager.withdraw_from_bank(amount):
		AudioManager.play_sfx("res://audio/economy/coin_drop.wav")
	else:
		AudioManager.play_sfx("res://audio/police/handcuff_click.wav")
	_update_display()


func _update_display() -> void:
	if wallet_label:
		wallet_label.text = "Pocket Cash (Wallet): %s" % EconomySystem.format_bdt(GameManager.wallet_bdt)
	if bank_label:
		bank_label.text = "Rupali Bank Savings: %s" % EconomySystem.format_bdt(GameManager.bank_bdt)
		
	# Update button enabled states
	var w = GameManager.wallet_bdt
	var b = GameManager.bank_bdt
	
	if dep_500: dep_500.disabled = (w < 500)
	if dep_2000: dep_2000.disabled = (w < 2000)
	if dep_5000: dep_5000.disabled = (w < 5000)
	if dep_all: dep_all.disabled = (w <= 0)
	
	if with_500: with_500.disabled = (b < 500)
	if with_2000: with_2000.disabled = (b < 2000)
	if with_5000: with_5000.disabled = (b < 5000)
	if with_all: with_all.disabled = (b <= 0)


func _refresh_ledger() -> void:
	if not ledger_container:
		return
	
	for child in ledger_container.get_children():
		child.queue_free()
		
	var history: Array = GameManager.transaction_history
	if history.is_empty():
		var empty_lbl = Label.new()
		empty_lbl.text = "No recent transactions recorded."
		empty_lbl.add_theme_font_size_override("font_size", 11)
		empty_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		ledger_container.add_child(empty_lbl)
		return
		
	for entry in history:
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 16)
		
		var t_lbl = Label.new()
		t_lbl.text = entry.get("time", "12:00")
		t_lbl.custom_minimum_size = Vector2(50, 0)
		t_lbl.add_theme_font_size_override("font_size", 11)
		t_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		row.add_child(t_lbl)
		
		var desc_lbl = Label.new()
		desc_lbl.text = entry.get("description", "Transaction")
		desc_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		desc_lbl.add_theme_font_size_override("font_size", 11)
		row.add_child(desc_lbl)
		
		var amt: int = entry.get("amount", 0)
		var amt_lbl = Label.new()
		amt_lbl.text = ("+" if amt > 0 else "") + EconomySystem.format_bdt(amt)
		amt_lbl.custom_minimum_size = Vector2(90, 0)
		amt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		amt_lbl.add_theme_font_size_override("font_size", 11)
		amt_lbl.add_theme_color_override("font_color", Color(0.3, 0.9, 0.4) if amt > 0 else Color(1.0, 0.4, 0.4))
		row.add_child(amt_lbl)
		
		ledger_container.add_child(row)
