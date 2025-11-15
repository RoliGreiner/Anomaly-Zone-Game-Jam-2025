extends CharacterBody2D

var target: Vector2
var direction: Vector2
var speed: float = 20000

func _ready() -> void:
	direction = position.direction_to(target)
	$Timer.start()

func _physics_process(delta: float) -> void:
	velocity = direction * speed * delta
	velocity.normalized()
	move_and_slide()

func _on_timer_timeout() -> void:
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is StaticBody2D:
		queue_free()
	if body is Enemy:
		body.ReduceHealth(20)
		queue_free()
