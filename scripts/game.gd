extends Node2D

@export_file("*.tscn") var player_scene = "res://scenes/player.tscn"
@export_file("*.tscn") var bullet_scene = "res://scenes/bullet.tscn"
@onready var enemy_manager = $EnemyManager
@export_file("*.tscn") var enemy_types: PackedStringArray

var player: Player

func _init() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	player = load(player_scene).instantiate()
	player.shooting.connect(PlayerShooting)
	player.damaged.connect(UpdateHealt)
	Global.player_position = player.position
	add_child(player)

func _process(delta: float) -> void:
	%Label.text = "%.1fs till next wave" % $EnemySpawnerCooldown.time_left
	UpdateMag()
	UpdateHealt()

func _ready() -> void:
	enemy_manager.attack_player.connect(AttackPlayer)

func AttackPlayer(damage: int) -> void:
	player.reduce_health(damage)

func _on_enemy_spawner_cooldown_timeout() -> void:
	print("cooldown timeout")
	SpawnEnemies()

func SpawnEnemies() -> void:
	for i in range(randi_range(5, 20) * player.level):
		var enemy: Enemy = load(enemy_types[0]).instantiate()
		enemy_manager.SpawnEnemy(enemy, player.level)

func PlayerShooting() -> void:
	var bullet: Node2D = load(bullet_scene).instantiate()
	var target_position = get_global_mouse_position()
	
	bullet.position = Global.player_position
	bullet.set("target", target_position)
	bullet.look_at(target_position)
	add_child(bullet)

func UpdateMag() -> void:
	$CanvasLayer/HBoxContainer/Mag.text = "%d/%d" % [player.mag_size, player.bullet_left]

func UpdateHealt() -> void:
	$CanvasLayer/HBoxContainer/Healt.text = "%d/%.1f" % [player.max_health, player.healt]
