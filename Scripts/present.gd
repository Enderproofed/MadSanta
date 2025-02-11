extends Projectile

var dead = false

func die():
	if !dead:
		dead = true
		linear_velocity = Vector2.ZERO
		gravity_scale = 0
		var explosion = preload("res://Scenes/explosion.tscn").instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		get_parent().add_child(explosion)
		explosion.position = position
		super()

func collision(body: Node2D) -> void:
	die()
