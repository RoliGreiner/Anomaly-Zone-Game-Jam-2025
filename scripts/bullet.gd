extends CharacterBody2D

var target: Vector2
var direction: Vector2
var speed: float = 5000

func _ready() -> void:
	direction = position.direction_to(target)
	$Timer.start()

func _physics_process(delta: float) -> void:
	velocity = direction * speed * delta
	velocity.normalized()
	move_and_slide()

func _on_timer_timeout() -> void:
	queue_free()
