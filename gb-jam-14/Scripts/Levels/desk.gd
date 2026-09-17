extends Node2D

signal finished(next_level: String)

@onready var dialog_manager: CanvasLayer = $DialogManager
@onready var timer_label: Label = $TimerLabel
@onready var passbook_name: Label = $PassBook/NameLabel
@onready var passbook_balance: Label = $PassBook/BalanceLabel
@onready var hand_icon: TextureRect = $HandIcon
@onready var cash_register_button: TextureButton = $Buttons/CashRegisterButton
@onready var customer_book_button: TextureButton = $Buttons/CustomerBookButton
@onready var bank_statement_button: TextureButton = $Buttons/BankStatementButton
@onready var cash_button: TextureButton = $Buttons/CashButton
@onready var bell_button: TextureButton = $Buttons/BellButton
@onready var cash_register_overlay: CanvasLayer = $CashRegister
@onready var pass_book_overlay: CanvasLayer = $PassBook
@onready var bank_statement_overlay: CanvasLayer = $BankStatement
@onready var cash_overlay: CanvasLayer = $Cash
@onready var cash_register_back_button: Button = $CashRegister/BackButton
@onready var pass_book_back_button: Button = $PassBook/BackButton
@onready var bank_statement_back_button: Button = $BankStatement/BackButton
@onready var cash_back_button: Button = $Cash/BackButton

const HAND_ICON_OFFSET := 4
const SMALL_CASH_TEXTURE = preload("res://Assets/Concept art/bitta cash bitta change.png")
const LARGE_CASH_TEXTURE = preload("res://Assets/Concept art/wad_o_cash.png")
const LARGE_DEPOSIT_THRESHOLD: int = 200

var npc: Node2D
var world
var _dialog_started: bool = false
var _invoking_button: TextureButton = null

@onready var buttons: Array[TextureButton] = [
	bell_button,
	customer_book_button,
	bank_statement_button,
	cash_button,
	cash_register_button
]

@onready var overlays: Array[CanvasLayer] = [
	cash_register_overlay,
	pass_book_overlay,
	bank_statement_overlay,
	cash_overlay
]

@onready var overlay_back_buttons: Array[Button] = [
	cash_register_back_button,
	pass_book_back_button,
	bank_statement_back_button,
	cash_back_button
]


func setup(npc_instance: Node2D) -> void:
	npc = npc_instance


func _ready() -> void:
	if world:
		timer_label.text = world.get_shift_text(world.clock.time_left)
		world.time_updated.connect(_on_time_updated)

	if npc != null:
		passbook_name.text = npc.npc_name
		passbook_balance.text = "BAL: $%d" % npc.balance

	for button in buttons:
		button.focus_entered.connect(_on_button_focus.bind(button))
		button.resized.connect(_on_button_resized.bind(button))
		button.disabled = true

	for back_button in overlay_back_buttons:
		back_button.focus_entered.connect(_on_button_focus.bind(back_button))
		back_button.resized.connect(_on_button_resized.bind(back_button))

	cash_register_button.pressed.connect(_show_cash_register)
	customer_book_button.pressed.connect(_show_pass_book)
	bank_statement_button.pressed.connect(_show_bank_statement)
	cash_button.pressed.connect(_show_cash)
	for back_button in overlay_back_buttons:
		back_button.pressed.connect(_hide_overlays)

	_set_vertical_focus_navigation()
	dialog_manager.dialog_complete.connect(_on_dialog_complete)
	call_deferred("_start_dialog")


func _on_time_updated(text: String) -> void:
	timer_label.text = text


func _set_vertical_focus_navigation() -> void:
	var focusable_buttons: Array[TextureButton] = []
	for button in buttons:
		if button.visible:
			focusable_buttons.append(button)
	for i in range(focusable_buttons.size()):
		if i > 0:
			focusable_buttons[i].focus_neighbor_top = focusable_buttons[i - 1].get_path()
		else:
			focusable_buttons[i].focus_neighbor_top = NodePath("")
		if i < focusable_buttons.size() - 1:
			focusable_buttons[i].focus_neighbor_bottom = focusable_buttons[i + 1].get_path()
		else:
			focusable_buttons[i].focus_neighbor_bottom = NodePath("")


func _start_dialog() -> void:
	if _dialog_started:
		return
	_dialog_started = true

	if npc == null:
		push_error("Desk started without an NPC.")
		dialog_manager.start_dialog(["..."])
		return

	dialog_manager.start_dialog(npc.dialogue, npc.sound_effect)


func _on_dialog_complete() -> void:
	for button in buttons:
		button.disabled = false
	_update_cash_button()
	_set_vertical_focus_navigation()
	cash_register_button.call_deferred("grab_focus")


func _update_cash_button() -> void:
	if npc != null and npc.context == NPCContext.Context.DEPOSIT:
		if npc.context_amount > LARGE_DEPOSIT_THRESHOLD:
			cash_button.texture_normal = LARGE_CASH_TEXTURE
		else:
			cash_button.texture_normal = SMALL_CASH_TEXTURE
		cash_button.visible = true
	else:
		cash_button.visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _is_overlay_open():
		_hide_overlays()
		get_viewport().set_input_as_handled()


func _show_cash_register() -> void:
	_populate_cash_register()
	_show_overlay(cash_register_overlay, cash_register_back_button, cash_register_button)


func _show_pass_book() -> void:
	_populate_pass_book()
	_show_overlay(pass_book_overlay, pass_book_back_button, customer_book_button)


func _show_bank_statement() -> void:
	_populate_bank_statement()
	_show_overlay(bank_statement_overlay, bank_statement_back_button, bank_statement_button)


func _show_cash() -> void:
	_populate_cash()
	_show_overlay(cash_overlay, cash_back_button, cash_button)


func _populate_cash_register() -> void:
	pass # Future cash register sprites and buttons land here.


func _populate_pass_book() -> void:
	print("PASSBOOK DEBUG name='", passbook_name.text, "' balance='", passbook_balance.text, "' name_visible=", passbook_name.visible, " name_rect=", passbook_name.get_global_rect(), " overlay_visible=", pass_book_overlay.visible)


func _populate_bank_statement() -> void:
	pass # Future bank statement sprites and buttons land here.


func _populate_cash() -> void:
	pass # Future cash sprites and buttons land here.


func _show_overlay(active_overlay: CanvasLayer, active_back_button: Button, invoking_button: TextureButton) -> void:
	for overlay in overlays:
		overlay.visible = overlay == active_overlay
	_invoking_button = invoking_button
	active_back_button.call_deferred("grab_focus")


func _hide_overlays() -> void:
	for overlay in overlays:
		overlay.visible = false
	if _invoking_button != null and is_instance_valid(_invoking_button):
		_invoking_button.call_deferred("grab_focus")


func _is_overlay_open() -> bool:
	for overlay in overlays:
		if overlay.visible:
			return true
	return false


func _on_button_focus(button: Control) -> void:
	_update_hand_position(button)
	hand_icon.visible = true


func _on_button_resized(button: Control) -> void:
	if button.has_focus():
		_update_hand_position(button)


func _update_hand_position(button: Control) -> void:
	var button_rect := button.get_global_rect()

	hand_icon.global_position = Vector2(
		button_rect.end.x + HAND_ICON_OFFSET,
		button_rect.position.y + (button_rect.size.y - hand_icon.size.y) / 2
	)


func _on_bell_button_pressed() -> void:
	print("BELL PRESSED")
	finished.emit("next_customer")
