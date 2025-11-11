extends Node

@export var number_of_enemies: int = 5
@export_file("*.tscn") var enemy_scene
var player_position: Vector2

func _ready() -> void:
	
	for i in range(number_of_enemies):
		var enemy: Enemy = load(enemy_scene).instantiate()
		enemy.Create(%Player.position)
		add_child(enemy)

func _process(delta: float) -> void:
	player_position = %Player.position
