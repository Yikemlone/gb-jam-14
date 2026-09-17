extends CanvasLayer

signal dialog_complete

@onready var dialog_box: Control = $DialogBox
@onready var dialog_text: Label = $DialogBox/DialogText
@onready var confirm_sound_player: AudioStreamPlayer = $ConfirmSound

var dialog_lines: Array[String] = []
var current_line_index: int = 0
var is_dialog_active: bool = false

func _ready() -> void:
	dialog_box.visible = false


func start_dialog(new_dialog_lines: Array[String], confirm_sound: AudioStream = null) -> void:
	dialog_lines = new_dialog_lines
	current_line_index = 0
	is_dialog_active = true
	if confirm_sound != null:
		confirm_sound_player.stream = confirm_sound
	# FIXED: Unhide the layer itself — desk.tscn instanced it with visible=false,
	# FIXED: which kept the box hidden even though the box was set visible below.
	visible = true
	dialog_box.visible = true
	dialog_text.text = dialog_lines[current_line_index]
	_play_confirm_sound()


func _input(event: InputEvent) -> void:
	if not is_dialog_active:
		return
	if event.is_action_pressed("ui_accept"):
		advance_dialog()


func advance_dialog() -> void:
	if not is_dialog_active:
		return
	get_viewport().set_input_as_handled()
	_play_confirm_sound()
	if current_line_index < dialog_lines.size() - 1:
		current_line_index += 1
		dialog_text.text = dialog_lines[current_line_index]
	else:
		is_dialog_active = false
		dialog_box.visible = false
		dialog_complete.emit()


func _play_confirm_sound() -> void:
	if confirm_sound_player.stream != null:
		confirm_sound_player.stop()
		confirm_sound_player.play()