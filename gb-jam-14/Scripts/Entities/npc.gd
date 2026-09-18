extends Node2D

const AMOUNT_STEP := 5

@export var npc_name: String = ""
@export var dialogue: Array[String] = []

var transaction_type: NPCContext.Transaction = NPCContext.Transaction.WITHDRAW
var balance: int = 100
var transaction_amount: int = 20
var sound_effect: AudioStream
var dialog_set: NPCDialogSet
var wealth: NPCContext.Wealth = NPCContext.Wealth.AVERAGE

@onready var sprite: Sprite2D = $Sprite2D

var presence: NPCContext.Presence = NPCContext.Presence.HIDDEN


func setup_identity(npc_name_value: String, face_texture: Texture2D, position_y: float = 71.0, sound_effect_stream: AudioStream = null, dialog_set_resource: NPCDialogSet = null, wealth_value: NPCContext.Wealth = NPCContext.Wealth.AVERAGE) -> void:
	npc_name = npc_name_value
	sprite.texture = face_texture
	sprite.position = Vector2(80.0, position_y)
	sound_effect = sound_effect_stream
	dialog_set = dialog_set_resource
	wealth = wealth_value


# Called every spawn to roll a fresh request + matching dialogue.
func randomize_visit() -> void:
	transaction_type = NPCContext.Transaction.values().pick_random()
	var bracket: Dictionary = NPCContext.WEALTH_BRACKETS[wealth]
	balance = _roll_bracket(bracket, "balance")
	transaction_amount = _roll_transaction_amount(bracket, balance, transaction_type)
	dialogue = build_dialogue()


func _roll_transaction_amount(bracket: Dictionary, current_balance: int, transaction_type_value: NPCContext.Transaction) -> int:
	match transaction_type_value:
		NPCContext.Transaction.DEPOSIT:
			return _roll_bracket(bracket, "deposit")
		NPCContext.Transaction.WITHDRAW:
			var rolled := _roll_bracket(bracket, "withdraw")
			return mini(rolled, maxi(current_balance, 5))
	return 0


func _roll_bracket(bracket: Dictionary, prefix: String) -> int:
	return _roll_stepped_amount(int(bracket[prefix + "_min"]), int(bracket[prefix + "_max"]))


func _roll_stepped_amount(minimum_amount: int, maximum_amount: int) -> int:
	var steps := floori(float(maximum_amount - minimum_amount) / AMOUNT_STEP)
	return randi_range(0, steps) * AMOUNT_STEP + minimum_amount


func build_dialogue() -> Array[String]:
	return [
		NPCContext.get_greeting_options(dialog_set).pick_random(),
		NPCContext.get_request_options(transaction_type, dialog_set).pick_random().replace("{amt}", str(transaction_amount)),
		NPCContext.get_closing_options(dialog_set).pick_random(),
	]


func set_presence(new_presence: NPCContext.Presence) -> void:
	presence = new_presence
	print("NPC presence changed to: ", presence)
	_update_visuals()


func _update_visuals() -> void:
	match presence:
		NPCContext.Presence.HIDDEN:
			sprite.visible = false
			print("NPC sprite hidden")

		NPCContext.Presence.AT_DESK:
			sprite.visible = true
			print("NPC sprite visible")
