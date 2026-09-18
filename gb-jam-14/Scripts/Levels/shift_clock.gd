extends Node
class_name ShiftClock

const DAY_SECONDS: float = 60.0
const SHIFT_START_MINUTES: int = 9 * 60
const DISPLAY_STEP_MINUTES: int = 10

signal time_updated(text: String)
signal finished

var shift_length_minutes: int = 8 * 60

var duration: float = DAY_SECONDS
var time_left: float = DAY_SECONDS
var _last_display_min: int = -1


func reset() -> void:
	time_left = duration
	_last_display_min = -1


func tick(delta: float) -> void:
	if time_left <= 0.0:
		return
	time_left = maxf(0.0, time_left - delta)
	_emit_if_changed()
	if time_left <= 0.0:
		finished.emit()


func get_shift_minutes(seconds_left: float) -> int:
	var clamped: float = clampf(seconds_left, 0.0, duration)
	var elapsed: float = duration - clamped
	var worked: int = int(elapsed / duration * float(shift_length_minutes))
	return SHIFT_START_MINUTES + clampi(worked, 0, shift_length_minutes)


func get_display_minutes(seconds_left: float) -> int:
	var raw: int = get_shift_minutes(seconds_left)
	if seconds_left <= 0.0:
		return SHIFT_START_MINUTES + shift_length_minutes
	var offset: int = raw - SHIFT_START_MINUTES
	return SHIFT_START_MINUTES + (offset / DISPLAY_STEP_MINUTES) * DISPLAY_STEP_MINUTES


func get_shift_text(seconds_left: float) -> String:
	var total: int = get_display_minutes(seconds_left)
	var hour24: int = total / 60
	var mins: int = total % 60
	var suffix: String = "AM" if total < 12 * 60 else "PM"
	var hour12: int = hour24 % 12
	if hour12 == 0:
		hour12 = 12
	return "%d:%02d %s" % [hour12, mins, suffix]


func get_shift_end_minutes() -> int:
	return SHIFT_START_MINUTES + shift_length_minutes


func get_shift_end_text() -> String:
	return get_shift_text(0.0)


func _emit_if_changed() -> void:
	var current: int = get_display_minutes(time_left)
	if current == _last_display_min:
		return
	_last_display_min = current
	time_updated.emit(get_shift_text(time_left))
