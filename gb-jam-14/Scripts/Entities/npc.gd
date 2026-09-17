extends Node2D

@export var npc_name: String = ""
@export var dialogue: Array[String] = []

var context: NPCContext.Context = NPCContext.Context.WITHDRAW
var balance: int = 100
var context_amount: int = 20
var sound_effect: AudioStream
var dialog_set: NPCDialogSet

@onready var sprite: Sprite2D = $Sprite2D

var display_context: NPCContext.Type = NPCContext.Type.HIDDEN


func setup_identity(npc_name_value: String, face_texture: Texture2D, position_y: float = 71.0, sound_effect_stream: AudioStream = null, dialog_set_resource: NPCDialogSet = null) -> void:
	npc_name = npc_name_value
	sprite.texture = face_texture
	sprite.position = Vector2(80.0, position_y)
	sound_effect = sound_effect_stream
	dialog_set = dialog_set_resource


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
	var greeting_pool: Array[String] = DialogLines.GREETINGS
	if dialog_set != null and not dialog_set.greetings.is_empty():
		greeting_pool = dialog_set.greetings
	var closing_pool: Array[String] = DialogLines.CLOSINGS
	if dialog_set != null and not dialog_set.closings.is_empty():
		closing_pool = dialog_set.closings
	return [
		greeting_pool.pick_random(),
		NPCContext.get_request_options(context, dialog_set).pick_random().replace("{amt}", str(context_amount)),
		closing_pool.pick_random(),
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
