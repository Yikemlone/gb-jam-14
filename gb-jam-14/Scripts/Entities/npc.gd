extends Node2D

@onready var sprite: ColorRect = $ColorRect

@export var npc_name: String = "Unnamed Customer"
@export var dialogue: Array[String] = [
	"Good morning.",
	"I'd like to make a withdrawal.",
	"Here is my account book."
]

var context: NPCContext.Type = NPCContext.Type.HIDDEN


func set_context(new_context: NPCContext.Type) -> void:
	context = new_context
	print("NPC context changed to: ", context)
	_update_visuals()


func _update_visuals() -> void:
	match context:
		NPCContext.Type.HIDDEN:
			sprite.visible = false
			print("NPC sprite hidden")

		NPCContext.Type.DESK:
			sprite.visible = true
			print("NPC sprite visible")
