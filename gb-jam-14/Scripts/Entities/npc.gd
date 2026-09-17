extends Node2D

@export var npc_name: String = ""
@export var dialogue: Array[String] = []

var context: NPCContext.Context = NPCContext.Context.WITHDRAW
var balance: int = 100
var context_amount: int = 20

@onready var sprite: Sprite2D = $Sprite2D

var display_context: NPCContext.Type = NPCContext.Type.HIDDEN


func setup_identity(p_name: String, p_texture: Texture2D) -> void:
	npc_name = p_name
	sprite.texture = p_texture


# Called every spawn to roll a fresh request + matching dialogue.
func randomize_visit() -> void:
	context = NPCContext.Context.values().pick_random()
	balance = (randi() % 51 + 10) * 5
	context_amount = (randi() % 20 + 1) * 5
	# Makes it so they can't request more than they own. May remove for some
	# gameplay depth later on
	if context == NPCContext.Context.WITHDRAW:
		context_amount = mini(context_amount, balance)
	dialogue = build_dialogue()


func build_dialogue() -> Array[String]:
	return [
		DialogLines.GREETINGS.pick_random(),
		NPCContext.get_request_options(context).pick_random().replace("{amt}", str(context_amount)),
		DialogLines.CLOSINGS.pick_random(),
	]


func set_context(new_context: NPCContext.Type) -> void:
	display_context = new_context
	print("NPC context changed to: ", display_context)
	_update_visuals()


func _update_visuals() -> void:
	match display_context:
		NPCContext.Type.HIDDEN:
			sprite.visible = false
			print("NPC sprite hidden")

		NPCContext.Type.DESK:
			sprite.visible = true
			print("NPC sprite visible")
