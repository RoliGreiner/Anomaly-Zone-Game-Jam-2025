extends CharacterBody2D

@export var damage: int = 200
var target: Vector2
var direction: Vector2
var speed: float = 8000

func _ready() -> void:
	direction = position.direction_to(target)

func _physics_process(delta: float) -> void:
	if $ThrowTime.time_left < 0.9:
		$CollisionShape2D.set_deferred("disabled", false)
	if $ThrowTime.is_stopped():
		$CollisionShape2D.set_deferred("disabled", true)
	if not $ThrowTime.is_stopped():
		velocity = direction * speed * delta
		velocity.normalized()
		move_and_slide()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	$PointLight2D.enabled = false

func _on_fuze_timer_timeout() -> void:
	$Grenade.visible = false
	var bodies_inside = $ExplosionRadius.get_overlapping_bodies()
	for body in bodies_inside:
		if body is Enemy or body is Player:
			body.ReduceHealth(damage)
	
	$AudioStreamPlayer2D.play()
	$PointLight2D.enabled = true
	$AnimationPlayer.play("explode")
	await $AudioStreamPlayer2D.finished
	queue_free()

func _on_throw_time_timeout() -> void:
	$Grenade.z_index = -1
