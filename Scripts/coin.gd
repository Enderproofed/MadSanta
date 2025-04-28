extends Area2D

var collected = false

func _on_body_entered(body: Node2D) -> void:
	if body == Globals.player or body is Projectile:
		if !collected:
			collected = true
			$CollectAnimation.play("collect")
			Globals.coins += 1
