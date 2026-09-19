class_name DeskOverlay
extends CanvasLayer

signal closed(overlay: DeskOverlay)
signal control_focused(control: Control)
signal control_resized(control: Control)

@onready var back_button: Button = $BackButton


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	track(back_button)


func open() -> void:
	visible = true
	focus_first()


func close() -> void:
	visible = false


func focus_first() -> void:
	back_button.call_deferred("grab_focus")


func track(control: Control) -> void:
	control.focus_entered.connect(_on_tracked_focus.bind(control))
	control.resized.connect(_on_tracked_resized.bind(control))


static func chain_vertical(controls: Array, loop_back: Control) -> void:
	var previous: Control = null
	for control in controls:
		control.focus_neighbor_top = previous.get_path() if previous != null else NodePath("")
		if previous != null:
			previous.focus_neighbor_bottom = control.get_path()
		previous = control
	if previous == null:
		loop_back.focus_neighbor_top = NodePath("")
	else:
		previous.focus_neighbor_bottom = loop_back.get_path()
		loop_back.focus_neighbor_top = previous.get_path()
	loop_back.focus_neighbor_bottom = NodePath("")


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
		get_viewport().set_input_as_handled()


func _on_tracked_focus(control: Control) -> void:
	control_focused.emit(control)


func _on_tracked_resized(control: Control) -> void:
	control_resized.emit(control)


func _on_back_pressed() -> void:
	closed.emit(self)
