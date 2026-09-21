extends Projectile

var animation_timer = 0.3
var excluded_colliders = []

var explosion_load = load("uid://jwqgxrh0deom")

func _physics_process(delta: float) -> void:
	if dead:
		if animation_timer <= 0:
			queue_free()
			return
		animation_timer -= delta
	else:
		velocity.y -= Globals.gravity
		var collision: KinematicCollision2D = move_and_collide(velocity * delta)
		if collision:
			on_collision(collision.get_collider())

func _ready() -> void:
	damage = 10 # const

func on_die():
	velocity = Vector2.ZERO
	call_deferred("add_explosion")
	$Animations.play("die")

func add_explosion():
	var explosion = explosion_load.instantiate()
	explosion.position = position
	get_parent().add_child(explosion)

func on_collision(body: Node2D) -> void:
	if body in excluded_colliders: return
	
	if body.has_method("take_damage"):
		body.take_damage(damage)
	die()
