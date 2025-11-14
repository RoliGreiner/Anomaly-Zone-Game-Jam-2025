extends CharacterBody2D
class_name Player

@export var level: int = 1
@export var speed: int = 3500
@export var max_health: float = 100.0
@export var healt: float = 100.0
@export var damage: float = 20.0
@export var rpm: int = 600
@export var mag_size: int = 30
@export var bullet_left: int
@export var dodge_speed: int = 50
@export var current_state: states = states.IDLE
@export var crosshair: Sprite2D

var is_reloading = false

enum states {
	IDLE,
	MOVE,
	DODGE,
}

signal shooting
signal damaged

func _init() -> void:
	bullet_left = mag_size

func _ready() -> void:
	$GunShooting.wait_time = 60.0 / rpm

func _process(delta: float) -> void:
	crosshair.position = get_local_mouse_position()
	if $Reloading.is_stopped():
		$ReloadingTimeLabel.text = ""
	else:
		var text = "Reloading %.1fs" % $Reloading.time_left
		$ReloadingTimeLabel.text = text
	
	if $DodgeCouldown.is_stopped():
		$DodgeCooldownLabel.text = "You can dodge"
	else:
		var text = "%.1fs" % $DodgeCouldown.time_left
		$DodgeCooldownLabel.text = text

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

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reload") and $Reloading.is_stopped():
		Reloading()

func idle_state(delta: float) -> void:
	if Input.get_vector("left", "right", "up", "down") != Vector2.ONE:
		print("State changed to %s" % states.keys()[current_state])
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
	damaged.emit()
	print("Player is damaged with: %.2f" % amount)
	print("Currant health: %.2f" % healt)
	if healt <= 0:
		get_tree().quit()

func _on_gun_shooting_timeout() -> void:
	if Input.is_action_pressed("shoot") and (current_state != states.DODGE) and (bullet_left > 0) and not is_reloading:
		shooting.emit()
		bullet_left -= 1
		if bullet_left == 0:
			Reloading()

func _on_reloading_timeout() -> void:
	bullet_left = mag_size
	is_reloading = false

func Reloading() -> void:
	is_reloading = true
	$Reloading.start()
	
