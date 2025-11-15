extends Node

@export var number_of_enemies: int = 5
@export var min_spawn_distance: int = 300
@export var max_spawn_distance: int = 400
@export var navigation_region: NavigationRegion2D
var rnd_position: Vector2
var enemies_alive: Array[Enemy]

signal attack_player(damage: float)
signal enemy_killed(exp: int)

func PlayerIsAttacked(damage: float):
	attack_player.emit(damage)

func SpawnEnemy(enemy: Enemy, player_level: int):
	rnd_position = GenerateSpawnPosition()
	
	while not SpawnpointIsOnMap(rnd_position):
		rnd_position = GenerateSpawnPosition()
	
	print("[Debug: spawn]player position: %d, %d" % [Global.player_position.x, Global.player_position.y])
	print("[Debug: spawn]enemy spawned at: %d, %d" % [rnd_position.x, rnd_position.y])
	print("[Debug: spawn]distance from player: %d" % SpawnDistanceFromPlayer(rnd_position))
	
	enemy.Create(rnd_position)
	enemy.attack_player.connect(PlayerIsAttacked)
	enemy.died.connect(EnemyDied)
	enemies_alive.append(enemy)
	add_child(enemy)
	
func GenerateSpawnPosition() -> Vector2: #Donat spawn area :)
	var r = randf_range(min_spawn_distance, max_spawn_distance)
	var theta = randf_range(0, 1) * 2 * PI
	var x = Global.player_position.x + r * cos(theta)
	var y = Global.player_position.y + r * sin(theta)
	
	return Vector2(x, y)

func SpawnDistanceFromPlayer(spawn_position: Vector2) -> float:
	return sqrt(pow(spawn_position.x - Global.player_position.x, 2) + pow(spawn_position.y - Global.player_position.y, 2))

func SpawnpointIsOnMap(spawn_point: Vector2) -> bool:
	var map = NavigationServer2D.region_get_map(navigation_region)
	var closest_point = NavigationServer2D.map_get_closest_point(map, spawn_point)
	var delta = closest_point - spawn_point
	return delta.is_zero_approx()

func EnemyDied(exp: int) -> void:
	for i in range(enemies_alive.size()):
		if not is_instance_valid(enemies_alive[i]):
			enemies_alive.remove_at(i)
			break
	enemy_killed.emit(exp)
