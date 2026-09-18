extends Node2D

const NPC_SCENE = preload("res://Scenes/Entities/npc.tscn")

const PLACEHOLDER_SOUND_EFFECT = preload("res://Assets/Audio/SFX/nintendo-game-boy-startup.mp3")

const ROSTER: Array = [
	{"id": "karen", "name": "Karen", "face": preload("res://Assets/Concept art/karen.png"), "position_y": 71.0, "sound_effect": PLACEHOLDER_SOUND_EFFECT, "dialog_set": null, "wealth": NPCContext.Wealth.RICH},
	{"id": "ivan", "name": "Ivan", "face": preload("res://Assets/Concept art/ivan.png"), "position_y": 71.0, "sound_effect": PLACEHOLDER_SOUND_EFFECT, "dialog_set": null, "wealth": NPCContext.Wealth.AVERAGE},
	{"id": "jojo", "name": "Jojo", "face": preload("res://Assets/Concept art/pomp_youth.png"), "position_y": 71.0, "sound_effect": PLACEHOLDER_SOUND_EFFECT, "dialog_set": preload("res://Resources/Dialog/jojo_dialog2.tres"), "wealth": NPCContext.Wealth.AVERAGE},
	{"id": "steve", "name": "Steve", "face": preload("res://Assets/Concept art/steve.png"), "position_y": 75.0, "sound_effect": PLACEHOLDER_SOUND_EFFECT, "dialog_set": null, "wealth": NPCContext.Wealth.AVERAGE},
	{"id": "igor", "name": "Igor", "face": preload("res://Assets/Concept art/igor.png"), "position_y": 71.0, "sound_effect": PLACEHOLDER_SOUND_EFFECT, "dialog_set": null, "wealth": NPCContext.Wealth.RICH},
	{"id": "susie", "name": "Susie", "face": preload("res://Assets/Concept art/susie.png"), "position_y": 80.0, "sound_effect": PLACEHOLDER_SOUND_EFFECT, "dialog_set": preload("res://Resources/Dialog/susie_dialog.tres"), "wealth": NPCContext.Wealth.POOR},
]

var npcs: Array[Node2D] = []


func create_npcs() -> void:
	for entry in ROSTER:
		var npc: Node2D = NPC_SCENE.instantiate()
		add_child(npc)
		npc.setup_identity(entry["name"], entry["face"], entry.get("position_y", 71.0), entry.get("sound_effect", PLACEHOLDER_SOUND_EFFECT), entry.get("dialog_set", null), entry.get("wealth", NPCContext.Wealth.AVERAGE))
		npcs.append(npc)


func set_active_npc(active: Node2D) -> void:
	for npc in npcs:
		if npc == active:
			npc.randomize_visit()
			npc.set_presence(NPCContext.Presence.AT_DESK)
		else:
			npc.set_presence(NPCContext.Presence.HIDDEN)


func hide_all_npcs() -> void:
	for npc in npcs:
		npc.set_presence(NPCContext.Presence.HIDDEN)


func get_random_npc(exclude: Node2D = null) -> Node2D:
	if npcs.size() <= 1:
		return npcs.pick_random()

	var picked: Node2D = npcs.pick_random()
	while picked == exclude:
		picked = npcs.pick_random()
	return picked
