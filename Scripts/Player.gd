@tool
extends RigidBody2D

var speed = 550.0
var acc = 0.12
var jump_speed = 800.0
var jump_extra_speed = 100.0
var extra = 1.0
var velocity = Vector2()
var gravity = 35.0
var on_ground = false
var save
var safe_jump = 0
var safe_ground = 0
var ground = false
var normal_v = 0
var paused = false
var reload = 0.25
var shoot_cooldown = 0
@onready var healthbar = $healthbar
@export var health = 100
func _process(delta):
	if Engine.is_editor_hint():
		$floor.position = Vector2(-$col.shape.size.x/2+1, $col.shape.size.y/2)
		$floor2.position = Vector2($col.shape.size.x/2-1, $col.shape.size.y/2)
		$right.position.x = $col.shape.size.x/2
		$left.position.x = -$col.shape.size.x/2
		$top.position.y = -$col.shape.size.y/2
		return
	
	safe_ground = max(safe_ground - delta,0)
	
	if on_ground:
		safe_ground = 0.05
	
	if safe_ground > 0.0:ground = true
	else:ground = false 
	
	
	shoot_cooldown = max(shoot_cooldown - delta, 0)
	if Input.is_action_pressed("shoot") and get_parent().has_node("Projectiles"):
		if Globals.state != Globals.PAUSED:
			shoot()
	

func shoot():
	if shoot_cooldown == 0:
		shoot_cooldown = reload
		var snowball_projectile = preload("res://Scenes/snowball.tscn").instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		get_node("../Projectiles").add_child(snowball_projectile)
		var direction = (get_global_mouse_position() - position).normalized()
		snowball_projectile.linear_velocity = direction * 1000
		snowball_projectile.global_position = global_position + direction*50

func _integrate_forces(state):
	if Engine.is_editor_hint():return
	
	if Input.is_action_just_pressed("jump"):
		safe_jump = true
	
	$floor.global_position = global_position + Vector2(-$col.shape.size.x/2+1, $col.shape.size.y/2-1)
	$floor2.global_position = global_position + Vector2($col.shape.size.x/2-1, $col.shape.size.y/2-1)
	$right.global_position = global_position + Vector2($col.shape.size.x/2-1, 0)
	$left.global_position = global_position + Vector2(-$col.shape.size.x/2+1, 0)
	$top.global_position = global_position + Vector2(0, -$col.shape.size.y/2+1)
	
	for child in get_children():
		if child.get("global_rotation"):
			child.global_rotation = 0
	
	if Globals.state == "PAUSED":
		paused = true
		if !save:save = velocity
		linear_velocity = Vector2.ZERO
	else: paused = false
	
	if save and Globals.state == "playin":
		velocity = save
		save = null
	
	if paused:return
	
	on_ground = $down.has_overlapping_bodies()
	
	var left = Input.is_action_pressed("ui_left")
	var right = Input.is_action_pressed("ui_right")
	
	if safe_jump and (ground or on_ground) and Input.is_action_pressed("jump"):
		safe_jump = false
		jump()
	if on_ground:
		if extra < 1.02:velocity.y = min(velocity.y,0)
		velocity.x = lerp(velocity.x,(int(right)-int(left)) * speed,acc)
	else:
		velocity.y += gravity
		velocity.x = lerp(velocity.x,(int(right)-int(left)) * speed,(acc/3))
	
	
	normal_v = velocity.x * extra
	linear_velocity.x = normal_v
	linear_velocity.y = min(velocity.y ,speed+100)
	
	extra = lerp(extra,1.0,0.1)
	
	if normal_v < 0:$skin.scale.x = -1
	if normal_v > 0:$skin.scale.x = 1
	
	if $floor.is_colliding() or $floor2.is_colliding():
		var floorPosition = max($floor.get_collision_point().y, $floor2.get_collision_point().y)-$col.shape.size.y/2
		if global_position.y + velocity.y/60 >= floorPosition:
			global_position.y = floorPosition
			linear_velocity.y = 0
			velocity.y = 0
	if $left.is_colliding():
		var leftPosition = $left.get_collision_point().x+$col.shape.size.x/2
		if global_position.x + velocity.x/60 <= leftPosition:
			global_position.x = leftPosition
			linear_velocity.x = 0
			velocity.x = 0
	if $right.is_colliding():
		var rightPosition = $right.get_collision_point().x-$col.shape.size.x/2
		if global_position.x + velocity.x/60 >= rightPosition:
			global_position.x = rightPosition
			linear_velocity.x = 0
			velocity.x = 0
	if $top.is_colliding():
		if global_position.y < $top.get_collision_point().y+$col.shape.extents.y:
			velocity.y = max(velocity.y,0)
		global_position.y = max(global_position.y,$top.get_collision_point().y+$col.shape.extents.y)
	

func jump():
	velocity.y = -jump_speed
	extra = 1.5
	safe_jump = 0
	

func enemy_entered(body: Node2D) -> void:
	if body.get("enemy") == true:
		velocity = (global_position - body.global_position).normalized() * 150
		
func _ready() -> void:
	health = 100
	healthbar.init_health(health)
	
func take_damage(amount: int) -> void: 
	healthbar.health = health - amount
	print("Damage: ", amount)
