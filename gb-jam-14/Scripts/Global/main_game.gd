extends Node

@onready var main_menu_root: Control = $MainMenuLayer/MainMenuRoot
@onready var splash_screen: Node2D = $SplashScreenLayer/splash_screen
@onready var world: Node2D = $World

const FIRST_LEVEL_LOAD = "day"

# This is to keep track of input
var splash_done: bool = false

func _ready() -> void:
	main_menu_root.hide_menu()
	splash_screen.startup_finished.connect(_on_splash_finished)
	main_menu_root.start_game.connect(_on_game_start)


func _on_splash_finished() -> void:
	splash_done = true
	splash_screen.hide()
	main_menu_root.show_menu()


func _on_game_start() -> void:
	if not splash_done:
		return
	main_menu_root.hide_menu()
	world.start_game()
