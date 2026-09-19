class_name HandIcon
extends TextureRect

const CURSOR_OFFSET := 4


func track(control: Control) -> void:
	control.focus_entered.connect(show_at.bind(control))
	control.resized.connect(follow.bind(control))


func show_at(control: Control) -> void:
	var button_rect := control.get_global_rect()
	global_position = Vector2(
		button_rect.end.x + CURSOR_OFFSET,
		button_rect.position.y + (button_rect.size.y - size.y) / 2
	)
	visible = true


func follow(control: Control) -> void:
	if control.has_focus():
		show_at(control)
