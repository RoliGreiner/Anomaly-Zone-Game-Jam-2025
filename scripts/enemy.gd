extends CharacterBody2D
class_name Enemy

@export var speed: float = 1000.0
@export var damage: float = 10.0
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

signal attack_player

func _ready() -> void:
	navigation_agent.path_desired_distance = 10.0
	navigation_agent.target_desired_distance = 10.0
	
	actor_setup.call_deferred()

func _physics_process(delta):
	velocity = Vector2.ONE
	
	set_movement_target(Global.player_position)
	
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	
	if navigation_agent.distance_to_target() > 30:
		velocity = current_agent_position.direction_to(next_path_position) * speed * delta
		move_and_slide()

func Create() -> void:
	var pos_x: float = Global.player_position.x + randf_range(-300, 300)
	var pos_y: float = Global.player_position.y + randi_range(-300, 300)
	position = Vector2(pos_x, pos_y)

func actor_setup():
	await get_tree().physics_frame
	
	set_movement_target(Global.player_position)

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body)
	if body is Player:
		print("Attack player")
		attack_player.emit(damage)
