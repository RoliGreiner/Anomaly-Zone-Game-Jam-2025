extends CharacterBody2D

var target: Vector2
var direction: Vector2
var speed: float = 8000

func _ready() -> void:
	direction = position.direction_to(target)
	$PointLight2D.enabled = true
	$AnimationPlayer.play("ignite")

func _physics_process(delta: float) -> void:
	if $ThrowTime.time_left < 0.9:
		$CollisionShape2D.set_deferred("disabled", false)
	if $ThrowTime.is_stopped():
		$CollisionShape2D.set_deferred("disabled", true)
	if not $ThrowTime.is_stopped():
		velocity = direction * speed * delta
		velocity.normalized()
		move_and_slide()

func _on_alive_time_timeout() -> void:
	$AnimationPlayer.play_backwards("ignite")
	await $AnimationPlayer.animation_finished
	queue_free()

func _on_throw_time_timeout() -> void:
	$Flare.z_index = -1
