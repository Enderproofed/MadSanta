extends Projectile

var dead = false
var active = false

func _ready() -> void:
	await Globals.timer(0.1)
	active = true
	await get_tree().create_timer(5).timeout
	die()

func die():
	if !dead:
		dead = true
		linear_velocity = Vector2.ZERO
		gravity_scale = 0
		var explosion = preload("res://Scenes/explosion.tscn").instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		get_parent().add_child(explosion)
		explosion.position = position
		$Animations.play("die")
		await Globals.timer(0.3)
		queue_free()

func collision(body: Node2D) -> void:
	if active:die()
