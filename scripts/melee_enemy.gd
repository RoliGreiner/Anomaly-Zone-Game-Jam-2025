extends Enemy
class_name MeleeEnemy

@export var attack_speed: int = 5

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print("Animation finished")
	match anim_name:
		"attack":
			var bodies = $Area2D.get_overlapping_bodies()
			for body in bodies:
				if body is Player:
					print("Attack player")
					attack_player.emit(damage)
					Attack()
		"default":
			$AnimationPlayer.play("default")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		Attack()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		$AnimationPlayer.play("default")
		$Move.visible = true
		$Move.visible = false

func Attack() -> void:
	print("Attack player")
	$Move.visible = false
	$Move.visible = true
	$AnimationPlayer.play("attack")
