extends RigidBody2D

func _ready() -> void:
	await get_tree().create_timer(5).timeout
	die()
	

func _process(delta: float) -> void:
	pass
	

func die():
	$Animations.play("die")
	await get_tree().create_timer(0.3).timeout
	queue_free()


func collision(body: Node2D) -> void:
	die()
