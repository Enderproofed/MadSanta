extends Projectile

var last_pos = position
var col_from_ray = false

func _ready() -> void:
	super._ready()
	$area.collision_mask = collision_mask
	$ColPrediction.collision_mask = collision_mask
	await get_tree().create_timer(0.01).timeout
	$trail.process_material.set_param(ParticleProcessMaterial.PARAM_ANGLE, Vector2(-rotation_degrees+90, -rotation_degrees+90))
	await get_tree().create_timer(5).timeout
	die()

func _process(delta: float) -> void:
	if !dead and $ColPrediction.is_colliding():
		var travelled_last_frame = position.distance_to(last_pos)
		var distance_to_collision = $ColPrediction.global_position.distance_to($ColPrediction.get_collision_point())
		print("travelled: ", travelled_last_frame, "distance_till", distance_to_collision)
		if distance_to_collision < travelled_last_frame:
			col_from_ray = true
			global_position = $ColPrediction.get_collision_point() - linear_velocity.normalized() * 5
			collision($ColPrediction.get_collider())
	last_pos = position

func die():
	if !dead:
		dead = true
		#process_mode = PROCESS_MODE_DISABLED
		angular_velocity = 0
		linear_velocity = Vector2.ZERO
		await Globals.timer(3)
		queue_free()

func collision(body: Node2D) -> void:
	print("Collision with ", body)
	if !dead and body != null:
		$trail.emitting = false
		if col_from_ray:
			var texture = $Texture
			remove_child(texture)
			body.add_child(texture)
			if texture != null:
				texture.global_position = global_position
				texture.global_rotation_degrees = global_rotation_degrees - 90
				texture.global_scale = global_scale
				texture.get_node("Animations").play("die")
		else:
			$Texture/Animations.play("die_fast")
		die()
