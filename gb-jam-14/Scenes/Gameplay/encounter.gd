extends Node2D

signal finished(next_level: String)

@onready var dialog_manager: CanvasLayer = $DialogManager

func _ready() -> void:
	dialog_manager.dialog_complete.connect(_on_dialog_complete)

func _on_dialog_complete() -> void:
	finished.emit("desk")
