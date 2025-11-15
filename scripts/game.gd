extends Node2D

@export_file("*.tscn") var player_scene = "res://scenes/player.tscn"
@export_file("*.tscn") var bullet_scene = "res://scenes/bullet.tscn"
@export_file("*.tscn") var grenade_scene = "res://scenes/grenade.tscn"
@export var enemy_manager: Node
@export_file("*.tscn") var enemy_types: PackedStringArray

var player: Player

func _init() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	player = load(player_scene).instantiate()
	player.shooting.connect(PlayerShooting)
	player.stats_update.connect(UpdateStats)
	player.throwing_grenade.connect(ThrowingGrenade)
	Global.player_position = player.position
	add_child(player)

func _process(delta: float) -> void:
	%Label.text = "%.1fs till next wave" % $EnemySpawnerCooldown.time_left
	UpdateStats()

func _ready() -> void:
	player.position = $SpawnPoint.position
	enemy_manager.attack_player.connect(AttackPlayer)
	enemy_manager.enemy_killed.connect(EnemyKilled)

func AttackPlayer(damage: int) -> void:
	player.ReduceHealth(damage)

func _on_enemy_spawner_cooldown_timeout() -> void:
	print("cooldown timeout")
	SpawnEnemies()

func SpawnEnemies() -> void:
	for i in range(randi_range(5, 10) + player.level * randi_range(1, 5)):
		var enemy: Enemy = load(enemy_types[0]).instantiate()
		enemy_manager.SpawnEnemy(enemy, player.level)

func PlayerShooting() -> void:
	var bullet: Node2D = load(bullet_scene).instantiate()
	var target_position = get_global_mouse_position()
	
	bullet.position = Global.player_position
	bullet.set("target", target_position)
	bullet.look_at(target_position)
	add_child(bullet)

func ThrowingGrenade() -> void:
	var grenade: Node2D = load(grenade_scene).instantiate()
	var target_position = get_global_mouse_position()
	
	grenade.position = player.position
	grenade.set("target", target_position)
	add_child(grenade)

func EnemyKilled(exp: int) -> void:
	player.GainExp(exp)

func UpdateStats() -> void:
	UpdateMag()
	UpdateHealt()
	UpdateLevel()
	UpdateExp()
	UpdateGrenade()

func UpdateMag() -> void:
	%Mag.text = " Magazine %d/%d" % [player.mag_size, player.bullet_left]

func UpdateHealt() -> void:
	%Healt.text = "HP %d/%.1f" % [player.max_health, player.healt]

func UpdateLevel() -> void:
	%Level.text = "%d Lvl" % player.level

func UpdateExp() -> void:
	%ProgressBar.value = player.current_exp / player.exp_to_next_level

func UpdateGrenade() -> void:
	if player.grenade_cooldown.is_stopped():
		%Grenade.get_node("Label").text = "Grenade available"
	else:
		%Grenade.get_node("Label").text = "%.1fs" % player.grenade_cooldown.time_left
