extends Node

@export var number_of_enemies: int = 5
@export_file("*.tscn") var enemy_scene

signal attack_player(damage: int)

func _ready() -> void:
	for i in range(number_of_enemies):
		var enemy: Enemy = load(enemy_scene).instantiate()
		enemy.attack_player.connect(PlayerIsAttacked)
		add_child(enemy)

func PlayerIsAttacked(damage: float):
	attack_player.emit(damage)
