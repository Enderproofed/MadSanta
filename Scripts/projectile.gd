class_name Projectile extends RigidBody2D

func _ready() -> void:
	await get_tree().create_timer(5).timeout
	die()

func die():
	$Animations.play("die")
	await Globals.timer(0.3)
	queue_free()

func collision(body: Node2D) -> void:
	die()
