extends Control

signal start_game

@onready var button_container: VBoxContainer = $VBoxContainer
@onready var hand_icon: TextureRect = $HandIcon

@onready var buttons: Array[Button] = [
	$VBoxContainer/StartGameButton,
	$"VBoxContainer/CreditsButton",
	$"VBoxContainer/ExitGameButton"
]

const HAND_ICON_OFFSET = 4

func _ready():
	for button in button_container.get_children():
		button.focus_entered.connect(_on_button_focus.bind(button))
		button.resized.connect(_on_button_resized.bind(button))

	# Don't grab focus while hidden (menu starts hidden under the splash).
	hand_icon.visible = false
	for button in buttons:
		button.focus_mode = Control.FOCUS_NONE


func show_menu() -> void:
	show()
	hand_icon.visible = false
	for button in buttons:
		button.focus_mode = Control.FOCUS_ALL
	buttons[0].grab_focus()


func hide_menu() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	if focused != null and buttons.has(focused):
		focused.release_focus()
	for button in buttons:
		button.focus_mode = Control.FOCUS_NONE
	hide()


func _on_button_focus(button: Button):
	_update_hand_position(button)
	hand_icon.visible = true


# This is here because of the funny first time load where the size isn't defind
# causing the icon to be placed incorrectly until the user moves the input
func _on_button_resized(button: Button):
	if button.has_focus():
		_update_hand_position(button)


func _update_hand_position(button: Button):
	var button_rect := button.get_global_rect()
	hand_icon.global_position = Vector2(
		button_rect.end.x + HAND_ICON_OFFSET,
		button_rect.position.y + (button_rect.size.y - hand_icon.size.y) / 2
	)


func _on_start_game_button_pressed() -> void:
	# Ignore presses while hidden
	if not visible:
		return
	print("Changing level")
	start_game.emit()


func _on_credits_button_pressed() -> void:
	print("Remove if not used")
	pass # Replace with function body.


func _on_exit_game_button_pressed() -> void:
	get_tree().quit()
