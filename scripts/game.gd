extends Node2D

@export_file("*.tscn") var player_scene = "res://scenes/player.tscn"
@export_file("*.tscn") var bullet_scene
@onready var enemy_manager = $EnemyManager
@export_file("*.tscn") var enemy_types: PackedStringArray

var player: Player

func _init() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	player = load(player_scene).instantiate()
	Global.player_position = player.position
	add_child(player)

func _process(delta: float) -> void:
	%Label.text = "%.1fs till next wave" % $EnemySpawnerCooldown.time_left

func _ready() -> void:
	enemy_manager.attack_player.connect(AttackPlayer)

func _input(event: InputEvent) -> void:
	if event.is_action("shoot"):
		var bullet: Node2D = load(bullet_scene).instantiate()
		bullet.position = Global.player_position
		bullet.set("target", get_global_mouse_position())
		add_child(bullet)

func AttackPlayer(damage: int) -> void:
	player.reduce_health(damage)

func _on_enemy_spawner_cooldown_timeout() -> void:
	print("cooldown timeout")
	SpawnEnemies()

func SpawnEnemies() -> void:
	for i in range(randi_range(5, 20) * player.level):
		var enemy: Enemy = load(enemy_types[0]).instantiate()
		enemy_manager.SpawnEnemy(enemy, player.level)
