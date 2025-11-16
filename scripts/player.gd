extends CharacterBody2D
class_name Player

@export_group("Player stats")
@export var level: int = 1
@export var speed: int = 3500
@export var max_health: float = 100.0
@export var healt: float = 100.0
@export var current_exp: int = 0
@export var exp_to_next_level: float = 100
@export var damage: float = 20.0
@export var rpm: int = 600
@export var mag_size: int = 30
@export var bullet_left: int = 30
@export var dodge_speed: int = 50
@export var current_state: states = states.IDLE

@export_category("Cooldown")
@export var grenade_cooldown: Timer
@export var reloading_time: Timer
@export var dodge_cooldown: Timer
@export var shooting_time: Timer
@export var flare_cooldown: Timer

@export_category("etc")
@export var crosshair: Sprite2D

var is_reloading = false

enum states {
	IDLE,
	MOVE,
	SPRINT,
	DODGE,
}

signal shooting
signal throwing_grenade
signal throwing_flare
signal stats_update

func _init() -> void:
	bullet_left = mag_size

func _ready() -> void:
	shooting_time.wait_time = 60.0 / rpm

func _process(delta: float) -> void:
	crosshair.position = get_local_mouse_position()
	$Flashlight.rotation = position.angle_to_point(crosshair.position * 100)
	$muzzle.rotation = position.angle_to_point(crosshair.position * 100)
	
	if reloading_time.is_stopped():
		$ReloadingTimeLabel.text = ""
	else:
		$ReloadingTimeLabel.text = "Reloading %.1fs" % reloading_time.time_left
	
	if dodge_cooldown.is_stopped():
		$DodgeCooldownLabel.text = "You can dodge"
	else:
		$DodgeCooldownLabel.text = "%.1fs" % dodge_cooldown.time_left

func _physics_process(delta: float) -> void:
	match current_state:
		states.IDLE:
			idle_state(delta)
		states.MOVE:
			move_state(delta)
		states.SPRINT:
			sprint_state(delta)
		states.DODGE:
			dodge_state(delta)
	
	velocity.normalized()
	move_and_slide()
	Global.player_position = position

func _input(event: InputEvent) -> void:
	if Input.get_vector("left", "right", "up", "down") == Vector2.ZERO and current_state != states.IDLE:
		current_state = states.IDLE
		print("State changed to %s" % states.keys()[current_state])
		$Running.stop()
		$Walk.stop()
	
	if Input.get_vector("left", "right", "up", "down") != Vector2.ZERO and current_state == states.IDLE:
		current_state = states.MOVE
		print("State changed to %s" % states.keys()[current_state])
		$Running.stop()
		$Walk.play()
	
	if Input.is_action_pressed("sprint") and current_state != states.SPRINT:
		current_state = states.SPRINT
		print("State changed to %s" % states.keys()[current_state])
		$Running.play()
		$Walk.stop()
	
	if Input.is_action_just_pressed("dodge") and dodge_cooldown.is_stopped():
		current_state = states.DODGE
		print("State changed to %s" % states.keys()[current_state])
		$Running.stop()
		$Walk.stop()
	
	if event.is_action_pressed("reload") and reloading_time.is_stopped():
		Reloading()
	if event.is_action("throw_grenade") and grenade_cooldown.is_stopped():
		throwing_grenade.emit()
		grenade_cooldown.start()
	if event.is_action("throw_flare") and flare_cooldown.is_stopped():
		throwing_flare.emit()
		flare_cooldown.start()

func idle_state(delta: float) -> void:
	velocity = Vector2.ZERO

func move_state(delta: float) -> void:
	move(delta)

func sprint_state(delta: float) -> void:
	move(delta)
	velocity *= 1.5

func dodge_state(delta: float):
	$CollisionShape2D.disabled = true
	move(delta)
	velocity *= dodge_speed
	position += velocity / 500
	current_state = states.MOVE
	$CollisionShape2D.disabled = false
	dodge_cooldown.start()

func move(delta: float) -> void:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed * delta

func ReduceHealth(amount: int) -> void:
	healt -= amount
	stats_update.emit()
	print("Player is damaged with: %.2f" % amount)
	print("Currant health: %.2f" % healt)
	if healt <= 0:
		get_tree().quit()

func _on_gun_shooting_timeout() -> void:
	if Input.is_action_pressed("shoot") and (current_state != states.DODGE) and (bullet_left > 0) and not is_reloading:
		$muzzle.enabled = true
		await get_tree().create_timer(0.05).timeout
		$muzzle.enabled = false
		$GunShot.play()
		shooting.emit()
		bullet_left -= 1
		if bullet_left == 0:
			Reloading()

func _on_reloading_timeout() -> void:
	bullet_left = mag_size
	is_reloading = false

func Reloading() -> void:
	$Reloading.play()
	is_reloading = true
	reloading_time.start()

func GainExp(amount: int) -> void:
	current_exp += amount
	if current_exp >= exp_to_next_level:
		NewLevel()
	stats_update.emit()

func NewLevel() -> void:
	print("Next level")
	level += 1
	current_exp -= exp_to_next_level
	exp_to_next_level *= 1.2
	
	damage += randi_range(10, 20)
	speed += 50
	max_health += randi_range(10, 30)
	healt = max_health
