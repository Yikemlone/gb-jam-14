extends Node2D

signal finished(next_level: String)

@onready var day_label: Label = $DayLabel
@onready var register_label: Label = $RegisterLabel
@onready var target_label: Label = $TargetLabel
@onready var verdict_label: Label = $VerdictLabel
@onready var start_hint: Label = $StartHint

var world


func _ready() -> void:
	call_deferred("_populate")


func _populate() -> void:
	if world == null:
		return

	var state: Dictionary = world.get_day_state()
	day_label.text = "DAY %d" % state["current_day"]
	register_label.text = "CASH: $%d" % state["register_money"]
	target_label.text = "STEAL: $%d" % state["steal_target"]

	if state["last_verdict"] != "":
		verdict_label.visible = true
		verdict_label.text = state["last_verdict"]


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		finished.emit("desk")
