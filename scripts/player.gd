extends CharacterBody2D
class_name Player

@export var speed: int = 2000
@export var healt: float = 100.0
@export var damage: float = 20.0
@export var dodge_speed: int = 50
@export var current_state: states = states.IDLE
@export var crosshair: Sprite2D

enum states {
	IDLE,
	MOVE,
	DODGE,
}

func _process(delta: float) -> void:
	crosshair.position = get_local_mouse_position()
	if $DodgeCouldown.is_stopped():
		$Label.text = "You can dodge"
	else:
		var text = "%.1fs" % $DodgeCouldown.time_left
		$Label.text = text

func _physics_process(delta: float) -> void:
	match current_state:
		states.IDLE:
			idle_state(delta)
		states.MOVE:
			move_state(delta)
		states.DODGE:
			dodge_state(delta)
	
	velocity.normalized()
	move_and_slide()
	Global.player_position = position

func idle_state(delta: float) -> void:
	if Input.get_vector("left", "right", "up", "down") != Vector2.ONE:
		print("State changed to %s" % current_state)
		current_state = states.MOVE

func move_state(delta: float) -> void:
	move(delta)
	
	if Input.is_action_just_pressed("dodge") and $DodgeCouldown.is_stopped():
		current_state = states.DODGE
	elif Input.is_action_pressed("sprint") and current_state != states.DODGE:
		velocity *= 1.5

func dodge_state(delta: float):
	$CollisionShape2D.disabled = true
	move(delta)
	velocity *= dodge_speed
	current_state = states.MOVE
	$CollisionShape2D.disabled = false
	$DodgeCouldown.start(5)

func move(delta: float) -> void:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed * delta

func reduce_health(amount: int) -> void:
	healt -= amount
	print("Player is damaged with: %.2f" % amount)
	print("Currant health: %.2f" % healt)
	if healt <= 0:
		get_tree().quit()
