extends Node2D

const NPC_SCENE = preload("res://Scenes/Entities/npc.tscn")

const ROSTER: Array = [
	{"name": "Karen", "face": preload("res://Assets/Concept art/karen.png")},
	{"name": "Ivan", "face": preload("res://Assets/Concept art/ivan.png")},
	{"name": "Jojo", "face": preload("res://Assets/Concept art/pomp_youth.png")},
	{"name": "Steve", "face": preload("res://Assets/Concept art/steve.png")},
	{"name": "Igor", "face": preload("res://Assets/Concept art/igor.png")},
	{"name": "Susie", "face": preload("res://Assets/Concept art/susie.png")},
]

var npcs: Array[Node2D] = []


func create_npcs() -> void:
	for entry in ROSTER:
		var npc: Node2D = NPC_SCENE.instantiate()
		add_child(npc)
		npc.setup_identity(entry["name"], entry["face"])
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
