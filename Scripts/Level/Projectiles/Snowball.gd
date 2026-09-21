class_name Snowball extends Projectile

static var time_after_colision = 2
static var bounciness = 0.8
static var bounces = 1

var mass = 1
var hits = 0
var collision_fade_timer = time_after_colision

func _physics_process(delta: float) -> void:
	if dead: return
	velocity.y -= Globals.gravity
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision:
		hits += 1
		velocity = velocity.bounce(collision.get_normal()) * bounciness
		#velocity = velocity.normalized() * velocity.length() * bounciness
		var normal = collision.get_normal().normalized()
		velocity += normal * normal.dot(collision.get_collider_velocity().normalized()) * collision.get_collider_velocity().length()
		print(normal * normal.dot(collision.get_collider_velocity().normalized()) * collision.get_collider_velocity().length())
		on_collide(collision.get_collider())
		if hits == bounces + 1:
			die()
		if collision.get_collider_velocity().length() > 0.01:
			move_and_slide()
	
	if hits > 0:
		rotation_degrees += velocity.x * 1.3 * delta
		#$trail.process_material.set_param(ParticleProcessMaterial.PARAM_ANGLE, Vector2(rotation_degrees, rotation_degrees))
		if collision_fade_timer <= 0:
			die()
		collision_fade_timer -= delta

func on_collide(body: Node2D):
	if dead: return
	if body is BrickWall:
		body.take_damage(damage * mass)
	elif body is not Player and body.has_method("take_damage"):
		body.take_damage(damage)

func _ready() -> void:
	super._ready()
	adjust_size()

func adjust_size():
	var size_vector = Vector2(size, size)
	$collision.scale = size_vector
	$Snowball.scale = size_vector
	var mat: ParticleProcessMaterial = $trail.process_material
	mat.scale_min = 3 * size
	mat.scale_max = 3 * size

func on_die():
	$trail.emitting = false
	$collision.disabled = true
	$Animations.play("die")
