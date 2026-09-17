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

const HAND_ICON_OFFSET := 4

var npc: Node2D
var world
var _dialog_started: bool = false

@onready var buttons: Array[TextureButton] = [
	bell_button,
	customer_book_button,
	bank_statement_button,
	cash_button,
	cash_register_button
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

	_set_vertical_focus_navigation()
	dialog_manager.dialog_complete.connect(_on_dialog_complete)
	call_deferred("_start_dialog")


func _on_time_updated(text: String) -> void:
	timer_label.text = text


func _set_vertical_focus_navigation() -> void:
	for i in range(buttons.size()):
		if i > 0:
			buttons[i].focus_neighbor_top = buttons[i - 1].get_path()

		if i < buttons.size() - 1:
			buttons[i].focus_neighbor_bottom = buttons[i + 1].get_path()


func _start_dialog() -> void:
	if _dialog_started:
		return
	_dialog_started = true

	if npc == null:
		push_error("Desk started without an NPC.")
		dialog_manager.start_dialog(["..."])
		return

	dialog_manager.start_dialog(npc.dialogue)


func _on_dialog_complete() -> void:
	for button in buttons:
		button.disabled = false
	cash_register_button.grab_focus()


func _on_button_focus(button: TextureButton) -> void:
	_update_hand_position(button)
	hand_icon.visible = true


func _on_button_resized(button: TextureButton) -> void:
	if button.has_focus():
		_update_hand_position(button)


func _update_hand_position(button: TextureButton) -> void:
	var button_rect := button.get_global_rect()

	hand_icon.global_position = Vector2(
		button_rect.end.x + HAND_ICON_OFFSET,
		button_rect.position.y + (button_rect.size.y - hand_icon.size.y) / 2
	)


func _on_bell_button_pressed() -> void:
	print("BELL PRESSED")
	finished.emit("next_customer")
