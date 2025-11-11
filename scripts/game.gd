extends Node2D

@export_file("*.tscn") var player_scene = "res://scenes/player.tscn"
@onready var enemy_manager = $EnemyManager

var player: Player

func _init() -> void:
	player = load(player_scene).instantiate()
	Global.player_position = player.position
	add_child(player)

func _ready() -> void:
	enemy_manager.attack_player.connect(AttackPlayer)

func AttackPlayer(damage: int) -> void:
	player.reduce_health(damage)
