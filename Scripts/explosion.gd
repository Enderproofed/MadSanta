extends HitBoxEnemy

func _ready() -> void:
	$Animation.play("explode")
	await Globals.timer(0.6)
	queue_free()
