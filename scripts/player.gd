extends CharacterBody2D

@export var speed: int = 500
@export var current_state: states = states.MOVE
@export var dodge_speed: int = 20;

var dodge_couldown: bool = false


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

func move_state(delta: float):
	move(delta)
	
	if Input.is_action_just_pressed("dodge") and $DodgeCouldown.is_stopped():
		current_state = states.DODGE

func dodge_state(delta: float):
	move(delta)
	
	velocity *= dodge_speed
	current_state = states.MOVE
	$DodgeCouldown.start(5)

func move(delta: float):
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed * delta * 50
