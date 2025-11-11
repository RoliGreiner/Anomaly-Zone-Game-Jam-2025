extends CharacterBody2D
class_name Player

@export var speed: float = 2000.0
@export var healt: float = 100.0
@export var damage: float = 20.0
@export var dodge_speed: float = 50.0;
@export var current_state: states = states.MOVE

enum states {
	MOVE,
	DODGE,
}

func _process(delta: float) -> void:
	if $DodgeCouldown.is_stopped():
		$Label.text = "You can dodge"
	else:
		var text = "%.0fs" % $DodgeCouldown.time_left
		$Label.text = text

func _physics_process(delta: float) -> void:
	match current_state:
		states.MOVE:
			move_state(delta)
		states.DODGE:
			dodge_state(delta)
	
	velocity.normalized()
	move_and_slide()
	Global.player_position = position
	$CollisionShape2D.disabled = false

func move_state(delta: float):
	move(delta)
	
	if Input.is_action_just_pressed("dodge") and $DodgeCouldown.is_stopped():
		current_state = states.DODGE

func dodge_state(delta: float):
	$CollisionShape2D.disabled = true
	move(delta)
	
	velocity *= dodge_speed
	current_state = states.MOVE
	$DodgeCouldown.start(5)

func move(delta: float):
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed * delta

func reduce_health(amount: int) -> void:
	healt -= amount
	print("Player is damaged with: %.2f" % amount)
	print("Currant health: %.2f" % healt)
	if healt <= 0:
		get_tree().quit()
