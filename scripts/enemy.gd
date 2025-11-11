extends CharacterBody2D
class_name Enemy

@export var speed: float = 1000.0
@export var damage: float = 10.0
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	navigation_agent.path_desired_distance = 2.0
	navigation_agent.target_desired_distance = 2.0
	
	actor_setup.call_deferred()

func Create(playerPos: Vector2) -> void:
	position = Vector2(playerPos.x + randi_range(-100, 100), playerPos.y + randi_range(-100, 100))

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("Player attacked")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(get_parent().get("player_position"))

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func _physics_process(delta):
	set_movement_target(get_parent().get("player_position"))
	
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	
	velocity = current_agent_position.direction_to(next_path_position) * speed * delta
	move_and_slide()
