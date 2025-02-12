extends HitBoxEnemy

func _ready() -> void:
	$Animation.play("explode")
	await Globals.timer(0.4)
	queue_free()
