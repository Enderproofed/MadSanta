extends Projectile

func _ready() -> void:
	await Globals.timer(5)
	die()

func collision(body: Node2D) -> void:
	die()

func die():
	$Animations.play("die")
	await Globals.timer(0.3)
	queue_free()
