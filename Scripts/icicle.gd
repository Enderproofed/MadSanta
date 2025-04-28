extends Projectile

func _ready() -> void:
	$trail.process_material = $trail.process_material.duplicate()
	await get_tree().create_timer(0.01).timeout
	$trail.process_material.set_param(ParticleProcessMaterial.PARAM_ANGLE, Vector2(-rotation_degrees-90, -rotation_degrees-90))
	await get_tree().create_timer(5).timeout
	die()

func _process(delta: float) -> void:
	pass

func die():
	$Animations.play("die")
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	await Globals.timer(0.3)
	queue_free()

func collision(body: Node2D) -> void:
	die()
