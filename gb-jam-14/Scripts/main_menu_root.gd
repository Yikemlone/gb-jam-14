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

	# Assuming we have the array above always beinging with the start button this should be fine.
	buttons[0].grab_focus() 


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
	print("Changing level")
	start_game.emit()


func _on_credits_button_pressed() -> void:
	print("Remove if not used")
	pass # Replace with function body.


func _on_exit_game_button_pressed() -> void:
	get_tree().quit()
