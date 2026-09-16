extends Node2D

signal finished(next_level: String)

@onready var result_label: Label = $ResultLabel
@onready var totals_label: Label = $TotalsLabel

var world


func _ready() -> void:
	call_deferred("_populate")

func _populate() -> void:
	if world == null:
		return

	var state: Dictionary = world.get_day_state()
	var won: bool = state["game_won"]
	result_label.text = "YOU MADE IT!" if won else "YOU LOST"
	totals_label.text = "STOLEN $%d / $%d" % [state["stolen_total"], state["weekly_steal_target"]]
