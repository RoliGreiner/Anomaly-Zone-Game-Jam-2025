extends CharacterBody2D
class_name Enemy

@export var speed: int = 2000
@export var max_health: int = 100
@export var health: float
@export var damage: float = 10.0
@export var distance_from_player: int = 30
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var healt_bar: ProgressBar = $healthBar

signal attack_player
signal died

func _init() -> void:
	pass

func _ready() -> void:
	health = max_health
	healt_bar.max_value = max_health
	healt_bar.value = health
	
	navigation_agent.path_desired_distance = 10.0
	navigation_agent.target_desired_distance = 10.0
	
	ActorSetup.call_deferred()

func _physics_process(delta):
	velocity = Vector2.ONE
	
	navigation_agent.target_position = Global.player_position
	
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	
	if navigation_agent.distance_to_target() > distance_from_player:
		velocity = current_agent_position.direction_to(next_path_position) * speed * delta
		move_and_slide()

func Create(spawn_position: Vector2) -> void:
	position = spawn_position

func ActorSetup() -> void:
	await get_tree().physics_frame
	
	navigation_agent.target_position = Global.player_position

func ReduceHealth(amount: int):
	health -= amount
	healt_bar.value = health
	if health <= 0:
		var exp_drop: int = randi_range(5, max_health / 10)
		died.emit(exp_drop)
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		print("Attack player")
		attack_player.emit(damage)
