extends Node2D

signal finished(next_level: String)

@onready var dialog_manager: CanvasLayer = $DialogManager

var npc: Node2D


func setup(npc_instance: Node2D) -> void:
	npc = npc_instance


func _ready() -> void:
	dialog_manager.dialog_complete.connect(_on_dialog_complete)
	call_deferred("_start_dialog")


func _start_dialog() -> void:
	if npc == null:
		push_error("Encounter started without an NPC.")
		return

	dialog_manager.start_dialog(npc.dialogue)


func _on_dialog_complete() -> void:
	finished.emit("desk")
