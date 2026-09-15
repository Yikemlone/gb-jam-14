extends Node2D

@onready var level_slot: Node2D = $Level
@onready var entities: Node2D = $Entities

var current_npc: Node2D

var level_scenes := {
	"encounter": preload("res://Scenes/Levels/encounter.tscn"),
	"desk": preload("res://Scenes/Levels/desk.tscn"),
}


func start_game() -> void:
	entities.create_npcs()
	current_npc = entities.get_random_npc()
	current_npc.set_context(NPCContext.Type.ENCOUNTER)
	load_level("encounter")


func load_level(level_name: String):
	for child in level_slot.get_children():
		child.queue_free()

	var new_level = level_scenes[level_name].instantiate()
	
	if level_name == "encounter":
		new_level.setup(current_npc)

	new_level.finished.connect(_on_level_finished)
	level_slot.add_child(new_level)


func get_current_npc() -> Node2D:
	return current_npc


# WIP
#func transition_to(next_level: String, npc_context: NPCContext.Type) -> void:
	#current_npc.set_context(npc_context)
	#load_level(next_level)


func _on_level_finished(next_level: String):
	match next_level:
		"desk":
			current_npc.set_context(NPCContext.Type.DESK)
		"encounter":
			current_npc.set_context(NPCContext.Type.ENCOUNTER)

	load_level(next_level)
