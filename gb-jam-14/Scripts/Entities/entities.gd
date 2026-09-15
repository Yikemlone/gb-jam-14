extends Node2D

const NPC_SCENE = preload("res://Scenes/Entities/npc.tscn")

var npcs: Array[Node2D] = []


func create_npcs() -> void:
	for i in range(5):
		var npc = NPC_SCENE.instantiate()
		add_child(npc)
		npcs.append(npc)


func get_random_npc() -> Node2D:
	return npcs.pick_random()
