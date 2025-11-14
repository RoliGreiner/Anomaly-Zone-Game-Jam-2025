extends Control

@export_file("*.tscn") var game_scene
@export var main: Control
@export var options: Control


func _ready() -> void:
	main.settings.connect(SwapView)
	main.start_game.connect(StartGame)
	options.back.connect(SwapView)
	
	main.visible = true
	options.visible = false

func SwapView() -> void:
	main.visible = not main.visible
	options.visible = not options.visible

func StartGame() -> void:
	get_tree().change_scene_to_file(game_scene)
