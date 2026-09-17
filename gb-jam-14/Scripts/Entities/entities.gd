extends Node2D

const NPC_SCENE = preload("res://Scenes/Entities/npc.tscn")

const PLACEHOLDER_SOUND_EFFECT = preload("res://Assets/Audio/SFX/nintendo-game-boy-startup.mp3")

const ROSTER: Array = [
	{"id": "karen", "name": "Karen", "face": preload("res://Assets/Concept art/karen.png"), "position_y": 71.0, "sound_effect": PLACEHOLDER_SOUND_EFFECT, "dialog_set": null},
	{"id": "ivan", "name": "Ivan", "face": preload("res://Assets/Concept art/ivan.png"), "position_y": 71.0, "sound_effect": PLACEHOLDER_SOUND_EFFECT, "dialog_set": null},
	{"id": "jojo", "name": "Jojo", "face": preload("res://Assets/Concept art/pomp_youth.png"), "position_y": 71.0, "sound_effect": PLACEHOLDER_SOUND_EFFECT, "dialog_set": preload("res://Resources/Dialog/jojo_dialog2.tres")},
	{"id": "steve", "name": "Steve", "face": preload("res://Assets/Concept art/steve.png"), "position_y": 75.0, "sound_effect": PLACEHOLDER_SOUND_EFFECT, "dialog_set": null},
	{"id": "igor", "name": "Igor", "face": preload("res://Assets/Concept art/igor.png"), "position_y": 71.0, "sound_effect": PLACEHOLDER_SOUND_EFFECT, "dialog_set": null},
	{"id": "susie", "name": "Susie", "face": preload("res://Assets/Concept art/susie.png"), "position_y": 80.0, "sound_effect": PLACEHOLDER_SOUND_EFFECT, "dialog_set": preload("res://Resources/Dialog/susie_dialog.tres")},
]

var npcs: Array[Node2D] = []


func create_npcs() -> void:
	for entry in ROSTER:
		var npc: Node2D = NPC_SCENE.instantiate()
		add_child(npc)
		npc.setup_identity(entry["name"], entry["face"], entry.get("position_y", 71.0), entry.get("sound_effect", PLACEHOLDER_SOUND_EFFECT), entry.get("dialog_set", null))
		npcs.append(npc)


func set_active_npc(active: Node2D) -> void:
	for npc in npcs:
		if npc == active:
			npc.randomize_visit()
			npc.set_context(NPCContext.Type.DESK)
		else:
			npc.set_context(NPCContext.Type.HIDDEN)


func hide_all_npcs() -> void:
	for npc in npcs:
		npc.set_context(NPCContext.Type.HIDDEN)


func get_random_npc(exclude: Node2D = null) -> Node2D:
	if npcs.size() <= 1:
		return npcs.pick_random()

	var picked: Node2D = npcs.pick_random()
	while picked == exclude:
		picked = npcs.pick_random()
	return picked
