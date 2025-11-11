extends CharacterBody2D
class_name Enemy

@export var speed: int = 1000
@export var damage: float = 10.0
@export var distance_from_player: int = 30
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

signal attack_player

func _init() -> void:
	var pos_x: float = Global.player_position.x + randf_range(-300, 300)
	var pos_y: float = Global.player_position.y + randi_range(-300, 300)
	position = Vector2(pos_x, pos_y)

func _ready() -> void:
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

func ActorSetup() -> void:
	await get_tree().physics_frame
	
	navigation_agent.target_position = Global.player_position

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		print("Attack player")
		attack_player.emit(damage)
