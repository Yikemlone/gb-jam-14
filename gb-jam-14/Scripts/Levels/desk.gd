extends Node2D

signal finished(next_level: String)

@onready var hand_icon: TextureRect = $HandIcon
@onready var cash_register_button: TextureButton = $Buttons/CashRegisterButton
@onready var customer_book_button: TextureButton = $Buttons/CustomerBookButton
@onready var bank_statement_button: TextureButton = $Buttons/BankStatementButton
@onready var cash_button: TextureButton = $Buttons/CashButton
@onready var bell_button: TextureButton = $Buttons/BellButton

const HAND_ICON_OFFSET := 4

@onready var buttons: Array[TextureButton] = [
	bell_button,
	customer_book_button,
	bank_statement_button,
	cash_button,
	cash_register_button
]


func _ready() -> void:
	for button in buttons:
		button.focus_entered.connect(_on_button_focus.bind(button))
		button.resized.connect(_on_button_resized.bind(button))

	# Set vertical focus navigation
	for i in range(buttons.size()):
		if i > 0:
			buttons[i].focus_neighbor_top = buttons[i - 1].get_path()

		if i < buttons.size() - 1:
			buttons[i].focus_neighbor_bottom = buttons[i + 1].get_path()

	call_deferred("_set_initial_focus")


func _set_initial_focus() -> void:
	bell_button.grab_focus()


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
	finished.emit("encounter")
