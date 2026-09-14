extends CanvasLayer

signal dialog_complete

@onready var dialog_box: Control = $DialogBox
@onready var dialog_text: Label = $DialogBox/DialogText

var dialog_lines: Array[String] = []
var current_line_index: int = 0
var is_dialog_active: bool = false

func _ready() -> void:
	dialog_box.visible = false
	start_dialog(["This is the live dialog test", "This is a second line."])


func start_dialog(lines: Array[String]) -> void:
	#get_tree().paused = true # test how this works
	dialog_lines = lines
	current_line_index = 0 
	is_dialog_active = true
	dialog_box.visible = true
	dialog_text.text = dialog_lines[current_line_index]


func _input(event ):
	if not dialog_box:
		return
	if event.is_action_pressed("ui_accept"):
		advance_dialog()
		


func advance_dialog():
	if current_line_index < dialog_lines.size() -1:
		current_line_index += 1
		dialog_text.text = dialog_lines[current_line_index]
	else:
		#get_tree().paused = false
		is_dialog_active = false
		dialog_box.visible = false
		# So we should advance to the desk here
		dialog_complete.emit()
	
