extends Node2D

@onready var level_slot: Node2D = $Level

# Loading all our scenes
var level_scenes := {
	"encounter": preload("res://Scenes/Gameplay/encounter.tscn"),
	"desk": preload("res://Scenes/Gameplay/desk.tscn"),
}

func load_level(level_name: String):
	# clear out old level
	for child in level_slot.get_children():
		child.queue_free()

	var new_level = level_scenes[level_name].instantiate()
	new_level.finished.connect(_on_level_finished)
	level_slot.add_child(new_level)

func _on_level_finished(next_level: String):
	load_level(next_level)
