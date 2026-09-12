extends Node

@onready var main_menu_root: Control = $MainMenuLayer/MainMenuRoot
@onready var splash_screen: Node2D = $SplashScreenLayer/splash_screen
@onready var level_root: Node2D = $World/Level

var current_level: Node = null


func _ready() -> void:
	main_menu_root.hide()
	splash_screen.startup_finished.connect(_on_splash_finished)
	main_menu_root.start_game.connect(_on_game_start)


func _on_splash_finished() -> void:
	splash_screen.hide()
	main_menu_root.show()


func _on_game_start() -> void:
	main_menu_root.hide()

	# Deffiently can be improved for more dynamic level loading options, but it'll do
	var level_scene = preload("res://Scenes/counter.tscn")
	load_level(level_scene)


func load_level(level_scene: PackedScene) -> void:
	if current_level:
		current_level.queue_free()

	current_level = level_scene.instantiate()
	level_root.add_child(current_level)
