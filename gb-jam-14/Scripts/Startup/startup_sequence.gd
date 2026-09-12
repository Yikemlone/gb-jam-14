extends Node2D

signal startup_finished

@export var play_startup_sequence: bool = true

var animation_player: AnimationPlayer

func _ready() -> void:
	animation_player = $Text/AnimationPlayer
	if play_startup_sequence:
		animation_player.play("Startup")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Startup":
		startup_finished.emit()
