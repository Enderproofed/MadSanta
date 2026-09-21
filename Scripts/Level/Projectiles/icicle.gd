extends Projectile

var actually_die_timer = 3

func _ready() -> void:
	super._ready()
	await get_tree().create_timer(0.01).timeout
	$trail.process_material.set_param(ParticleProcessMaterial.PARAM_ANGLE, Vector2(-rotation_degrees+90, -rotation_degrees+90))

func _physics_process(delta: float) -> void:
	if dead:
		if actually_die_timer <= 0: queue_free()
		actually_die_timer -= delta
		return
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision:
		on_collision(collision.get_collider())

#func on_die():
	#velocity = Vector2.ZERO

func on_collision(body: Node2D) -> void:
	#if !dead and body != null:
	if body.has_method("take_damage") and body is not BrickWall:
		body.take_damage(damage)
	$trail.emitting = false
	var texture = $Texture
	remove_child(texture)
	body.add_child(texture)
	add_colision(body, texture)
	if texture != null:
		texture.global_position = global_position + velocity.normalized() * 5
		texture.global_rotation_degrees = global_rotation_degrees - 90
		texture.global_scale = global_scale
		texture.get_node("Animations").play("die")
	die()

func add_colision(toCheck, addTo):
	if toCheck is StaticBody2D or toCheck is TileMapLayer:
		var staticBody = StaticBody2D.new()
		var collisionShape = CollisionShape2D.new()
		var rectangleShape = RectangleShape2D.new()
		rectangleShape.size = Vector2(24/2, 24)
		collisionShape.set_shape(rectangleShape)
		staticBody.add_child(collisionShape)
		addTo.add_child(staticBody)
