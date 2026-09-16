extends Node2D

signal startup_finished

var skip_enabled: bool = false

@onready var startup_animation: Node2D = $"Startup Animation"

func _ready() -> void:
	startup_animation.startup_finished.connect(_on_startup_animation_finished)


# Eats menu inputs while the splash is up so they can't reach hidden menu buttons.
func _input(event: InputEvent) -> void:
	if skip_enabled or not visible:
		return
	if event.is_action_pressed("ui_accept") \
	or event.is_action_pressed("ui_select") \
	or event.is_action_pressed("ui_up") \
	or event.is_action_pressed("ui_down") \
	or event.is_action_pressed("ui_left") \
	or event.is_action_pressed("ui_right") \
	or event.is_action_pressed("ui_focus_next") \
	or event.is_action_pressed("ui_focus_prev"):
		get_viewport().set_input_as_handled()


func _on_startup_animation_finished() -> void:
	startup_finished.emit()
