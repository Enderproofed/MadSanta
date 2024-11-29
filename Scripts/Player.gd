@tool
extends RigidBody2D

var speed = 550.0
var acc = 0.12
var jump_speed = 800.0
var jump_extra_speed = 100.0
var extra = 1.0
var extra2 = Vector2.ZERO
var velocity = Vector2()
var wall_jumping = true
var gravity = 35.0
var on_ground = false
var left_col = false
var right_col = false
var save
var safe_jump = 0
var safe_ground = 0
var safe_sound = 0
var ded = false
var ground = false
var normal_v = 0
var movin = true
var paused = false
var tilemap

func _process(delta):
	if Engine.is_editor_hint():
		$floor.position.x = -$col.shape.size.x/2
		$floor.position.y = $col.shape.size.y/2
		$floor2.position = $col.shape.size/2
		return
	movin = true
	
	safe_ground = max(safe_ground - delta,0)
	
	if Input.is_action_just_pressed("jump"):
		safe_jump = true
	if on_ground:
		safe_ground = 0.05
	
	if safe_ground > 0.0:ground = true
	else:ground = false 
	

func _integrate_forces(state):
	if Engine.is_editor_hint():return
	for child in get_children():
		if child.get("global_rotation"):
			child.global_rotation = 0
	
	if Globals.state == "pause":
		if !save:save = velocity
		linear_velocity = Vector2.ZERO
		
	if save and Globals.state == "playin":
		velocity = save
		save = null
	
	#if Globals.state != "playin":
		#$A.stop(false)
		#
		#return
	
	if paused:return
	
	on_ground = false
	left_col = false
	right_col = false
	
	if $left.is_colliding():
		var col = $left.get_collider()
		var pos = $left.get_collision_point()
		if col is TileMap or col is StaticBody2D:
			if global_position.x < pos.x+$col.shape.extents.x+2:
				left_col = true
	if $right.is_colliding():
		var col = $right.get_collider()
		var pos = $right.get_collision_point()
		if col is TileMap or col is StaticBody2D:
			if global_position.x > pos.x-$col.shape.extents.x-2:
				right_col = true
	
	extra2 = Vector2.ZERO
	for body in $down.get_overlapping_bodies():
		if body is TileMap or body is StaticBody2D:
			on_ground = true
			if body.get("velocity"):
				body.player = self
#				global_position += body.get("velocity")
				tilemap = body
				extra2 = body.get("velocity")
	
	var left = Input.is_action_pressed("ui_left")
	var right = Input.is_action_pressed("ui_right")
	
	
	if on_ground:
		if abs(normal_v) > 1.0:
			$A.play("walk")
		else:
			$A.play("idle")
	else:
		if (left_col and left) or (right_col and right):
			$A.stop()
			$skin.frame = 21
		else:
			$A.stop()
			if velocity.y < -200:$skin.frame = 20
			elif velocity.y > 200:$skin.frame = 27
			else:
				if velocity.y < 0:$skin.frame = 25
				else:$skin.frame = 26
	

	
	if left_col:
		#if left and !$down.get_overlapping_bodies():
			#if safe_jump and Input.is_action_pressed("jump") and wall_jumping:
				#wall_jump("left")
			#play()
			#velocity.y = min(velocity.y,50+Globals.time_speed)
		velocity.x = max(velocity.x,0)
		left = false
	if right_col:
		#if right and !on_ground:
			#if safe_jump and Input.is_action_pressed("jump") and wall_jumping:
				#wall_jump("right")
			#play()
			#velocity.y = min(velocity.y,50*Globals.time_speed)
		velocity.x = min(velocity.x,0)
		right = false
	
	#if ground:
	if safe_jump and Input.is_action_pressed("jump"):
		safe_jump = false
		jump()
	if on_ground:
		if extra < 1.02:velocity.y = min(velocity.y,0)
		velocity.x = lerp(velocity.x,(int(right)-int(left)) * speed,acc)
	else:
		velocity.y += gravity
		velocity.x = lerp(velocity.x,(int(right)-int(left)) * speed,(acc/3))
	
	
	normal_v = velocity.x * extra
	if extra2:linear_velocity.x = normal_v + extra2.x
	else:linear_velocity.x = normal_v
	
	extra = lerp(extra,1.0,0.1)
	
	if normal_v < 0:$skin.scale.x = -1
	if normal_v > 0:$skin.scale.x = 1
	
	if $floor.is_colliding():
		global_position.y = min(global_position.y,$floor.get_collision_point().y-$col.shape.extents.y)
	if $floor2.is_colliding():
		global_position.y = min(global_position.y,$floor2.get_collision_point().y-$col.shape.extents.y)
	if $left.is_colliding():
		global_position.x = max(global_position.x,$left.get_collision_point().x+$col.shape.extents.x)
	if $right.is_colliding():
		global_position.x = min(global_position.x,$right.get_collision_point().x-$col.shape.extents.x)
	if $top.is_colliding():
		if global_position.y < $top.get_collision_point().y+$col.shape.extents.y:
			velocity.y = max(velocity.y,0)
		global_position.y = max(global_position.y,$top.get_collision_point().y+$col.shape.extents.y)
	
	linear_velocity.y = min(velocity.y ,speed+100)
	#print("Velocity.y: ", linear_velocity.y)

#func wall_jump(dir):
	#play_sound(-15,rand_range(1.1,1.4),"8bit-jump")
	#extra = 1
	#velocity.y = -jump_speed*1
	#if dir == "left":
		#velocity.x = speed * 2# * Globals.time_speed
	#if dir == "right":
		#velocity.x = -speed * 2# * Globals.time_speed
	

#func play_sound(db,pitch,sound):
	#var sound_inst = preload("res://Scenes/Sound2.tscn").instance()
	#sound_inst.sound = sound
	#sound_inst.pitch = pitch
	#sound_inst.db = db
	#add_child(sound_inst)

func jump():
	#play_sound(-10,randf_range(0.8,1.2),"8bit-jump")
	velocity.y = -jump_speed
	extra = 1.5
	safe_jump = 0
	#for body in $down.get_overlapping_bodies():if body is TileMap:$down/wall3.emitting = true
	#$down/wall3.look_at(global_position+velocity)
	#for frames in range(5):
		#yield(get_tree(),"physics_frame")
	#$down/wall3.emitting = false
	

#func die():
	#if !ded:
		#ded = true
		#Globals.deaths += 1
		#velocity = Vector2.ZERO
		#deactivate3()
		#var sound = preload("res://Scenes/Sound2.tscn").instance()
		#sound.sound = "explosion"
		#sound.db = -10
		#sound.pitch = 1
		#add_child(sound)
		#
		#var e = preload("res://Scenes/explosion.tscn").instance()
		#e.global_position = global_position
		#$"/root/Main".add_child(e)
		#
		#yield(get_tree().create_timer(0.7),"timeout")
		#
		#Globals.respawn()
		#ded = false

func deactivate():
	hide()
	$cam.smoothing_enabled = false
	position = Vector2.ZERO
	$col.disabled = true
	$floor.enabled = false
	$right.enabled = false
	$left.enabled = false
	$top.enabled = false
	
func deactivate2():
	hide()
	position = Vector2.ZERO
	$col.disabled = true
	$floor.enabled = false
	$right.enabled = false
	$left.enabled = false
	$top.enabled = false

func deactivate3():
	paused = true
	hide()
	$col.disabled = true
	$floor.enabled = false
	$right.enabled = false
	$left.enabled = false
	$top.enabled = false

#func activate():
	#paused = false
	#show()
	#$col.disabled = false
	#ded = false
	#yield(get_tree(),"physics_frame")
	#$cam.smoothing_enabled = true
	#$floor.enabled = true
	#$right.enabled = true
	#$left.enabled = true
	#$top.enabled = true
