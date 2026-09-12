extends Node2D

signal startup_finished

@onready var startup_animation: Node2D = $"Startup Animation"

func _ready() -> void:
	startup_animation.startup_finished.connect(_on_startup_animation_finished)


func _on_startup_animation_finished() -> void:
	startup_finished.emit()
