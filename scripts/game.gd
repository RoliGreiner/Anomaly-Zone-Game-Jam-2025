extends Node2D

@export_file("*.tscn") var player_scene = "res://scenes/player.tscn"
@export_file("*.tscn") var bullet_scene
@onready var enemy_manager = $EnemyManager

var player: Player

func _init() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	player = load(player_scene).instantiate()
	Global.player_position = player.position
	add_child(player)

func _input(event: InputEvent) -> void:
	if event.is_action("shoot"):
		var bullet: Node2D = load(bullet_scene).instantiate()
		bullet.position = Global.player_position
		bullet.set("target", get_global_mouse_position())
		add_child(bullet)

func _ready() -> void:
	enemy_manager.attack_player.connect(AttackPlayer)

func AttackPlayer(damage: int) -> void:
	player.reduce_health(damage)
