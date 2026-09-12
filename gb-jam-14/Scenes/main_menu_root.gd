extends Control

signal start_game


func _on_start_game_button_pressed() -> void:
	print("Changing level")
	start_game.emit()


func _on_credits_button_pressed() -> void:
	print("Remove if not used")
	pass # Replace with function body.


func _on_exit_game_button_pressed() -> void:
	get_tree().quit()
