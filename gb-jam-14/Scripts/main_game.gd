extends Node

@onready var main_menu_root: Control = $MainMenuLayer/MainMenuRoot
@onready var splash_screen: Node2D = $SplashScreenLayer/splash_screen
@onready var world: Node2D = $World

const FIRST_LEVEL_LOAD = "encounter"

func _ready() -> void:
	main_menu_root.hide()
	splash_screen.startup_finished.connect(_on_splash_finished)
	main_menu_root.start_game.connect(_on_game_start)


func _on_splash_finished() -> void:
	splash_screen.hide()
	main_menu_root.show()


func _on_game_start() -> void:
	main_menu_root.hide()
	world.load_level(FIRST_LEVEL_LOAD)
