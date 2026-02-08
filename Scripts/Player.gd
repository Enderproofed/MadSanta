@tool
extends RigidBody2D

const laser_preload = preload("res://Scenes/Laser.tscn")

const JUMP_TIME = 0.25

var speed = 375.0
var rolling_speed = 625.0
var acc = 0.12
var jump_speed = 600.0
var jump_extra_speed = 100.0
var jump_timer = 0
var jump_queued = false
var extra = 1.0
var velocity = Vector2()
var gravity = 35.0
var on_ground = false
var save
var safe_ground = 0
var ground = false
var normal_v = 0
var paused = false
var shoot_cooldown_snowball = 0
var shoot_cooldown_icicle = 0
var laser_time_total = 3.0
var laser_time_left = 3.0
var laser_fill_per_second = 0.15
var laser_knockback = 3

const MAX_SPEED = 900.0
const KNOCKBACK_MODIFIER = 0.1
const MINIMUM_LASER_TIME = 1
const NORMAL_LASER = "NORMAL_LASER"
const SELECTION_LASER = "SELECTION_LASER"

@onready var ui: UI = get_node("/root/Main/Overlay/UI")
@onready var healthbar: Bar = get_node("/root/Main/Overlay/UI/LevelOverlay/HealthBar")
@onready var laserbar: Bar = get_node("/root/Main/Overlay/UI/LevelOverlay/LaserBar")

@onready var floor_position = $floor.position
@onready var floor2_position = $floor2.position
@onready var right_position = $right.position
@onready var left_position = $left.position
@onready var top_position = $top.position
@onready var cam: Camera2D = $Cam
@onready var init_collision_mask = collision_mask

@export var health = 100

var shooting = false
var laser: Laser = null
var laser_firing = false
var laser_type = NORMAL_LASER
var laser_stop_queued = false
var current_laser_knockback = Vector2.ZERO

const init_reload_snowball = 0.6
const init_reload_icicle = 0.45
const init_speed_snowball = 750
const init_speed_icicle = 1000
#affected by upgrades
var reload_snowball = init_reload_snowball
var reload_icicle = init_reload_icicle
var damage_snowball = 15
var damage_icicle = 10
var speed_snowball = init_speed_snowball
var speed_icicle = init_speed_icicle

#states
var rolling = false

func upgrade_update():
	for item in Globals.upgrades.keys():
		for upgrade in Globals.upgrades[item]:
			upgrade_updated(item, Globals.upgrade_name_map.find_key(upgrade))

func upgrade_updated(item: Globals.CHEST_ITEMS, upgrade: Globals.UPGRADE):
	var upgrades = Globals.upgrades[item][Globals.get_upgrade_name(upgrade)]-1
	if item == Globals.CHEST_ITEMS.SNOWBALL:
		if upgrade == Globals.UPGRADE.STRENGTH:
			damage_snowball = 15 + upgrades * 5   # result: 15, 20, 25, 30, 35, 40, 45, 50...
		if upgrade == Globals.UPGRADE.RELOAD:
			reload_snowball = upgrade_step(upgrades, init_reload_snowball, [4, 8, 12], [-0.05, -0.025, -0.02, -0.01])
	if item == Globals.CHEST_ITEMS.ICICLE:
		if upgrade == Globals.UPGRADE.STRENGTH:
			damage_icicle = 10 + upgrades * 4   # result: 10, 14, 18, 22, 26, 30, 34, 38...
		if upgrade == Globals.UPGRADE.RELOAD:
			reload_icicle = upgrade_step(upgrades, init_reload_icicle, [4, 8, 12], [-0.04, -0.02, -0.015, -0.01])
		if upgrade == Globals.UPGRADE.SPEED:
			speed_icicle = upgrade_step(upgrades, init_speed_icicle, [4, 8, 12], [150, 100, 75, 50])

func upgrade_step(upgrades: int, init_value: float, thresholds: Array[int], factors: Array[float]) -> float:
	var result = init_value
	for i in range(thresholds.size()):
		var threshold = thresholds[i]
		var difference = thresholds[i] if i==0 else thresholds[i]-thresholds[i-1]
		if upgrades > threshold:
			result += difference * factors[i]
		else:
			result += (difference - (threshold - upgrades)) * factors[i]
			break
	var max_threshold = thresholds[thresholds.size()-1]
	if upgrades > max_threshold and factors.size() > thresholds.size():
		result += (upgrades - max_threshold) * factors[factors.size()-1]
	return result

func _init() -> void:
	if Engine.is_editor_hint(): return
	Globals.player = self

func _ready() -> void:
	#test
	#for i in range(30):
		#var result = 0
		#if i <= 4: result = 0.6 - i * 0.05
		#elif i <= 8: result = 0.6 - 4 * 0.05 - (i - 4) * 0.025
		#elif i <= 12: result = 0.6 - 4 * 0.05 - 4 * 0.025 - (i-8) * 0.02
		#else: result = 0.6 - 4 * 0.05 - 4 * 0.025 - 4 * 0.02 - (i-12) * 0.01
		#print("i = ", i, " : static = ", result, ", function = ", upgrade_step(i, 0.6, [4, 8, 12], [-0.05, -0.025, -0.02, -0.01]))
	if Engine.is_editor_hint(): return
	health = 100
	healthbar.init_progress(health)
	laserbar.init_progress(laser_time_total)
	laserbar.update_value(laser_time_left)
	$Snowman.show()
	$Snowball.hide()
	#$Line2D.hide()
	
	Globals.add_listener(Globals.UPGRADE_BOUGHT, Callable(self, "upgrade_updated"))
	upgrade_update()

func _process(delta):
	if Engine.is_editor_hint():
		#$floor.position = Vector2(-$col.shape.size.x/2+1, $col.shape.height/2)
		#$floor2.position = Vector2($col.shape.size.x/2-1, $col.shape.height/2)
		#$right.position.x = $col.shape.size.x/2
		#$left.position.x = -$col.shape.size.x/2
		#$top.position.y = -$col.shape.height/2
		return
	if Globals.level != null:
		if position.y >= cam.limit_bottom:
			die()
	
	if !Globals.isPaused():
		timers(delta)
		shoot_handling(delta)
		fall_through_one_way()
	else:
		$Line2D.modulate.a = 0
	
	if rolling:
		$Snowball.rotation_degrees += linear_velocity.x * delta
	var snowball_visible = rolling and abs(velocity.x) > speed
	$Snowball.visible = snowball_visible
	$Snowman.visible = !snowball_visible

func fall_through_one_way():
	if Input.is_action_just_pressed("ui_down"):
		set_collision(init_collision_mask - 16) # 16 = bit value of 5 -> one way platform collision layer
	if Input.is_action_just_released("ui_down"):
		set_collision(init_collision_mask)

func set_collision(value):
	collision_mask = value
	$floor.collision_mask = value
	$floor2.collision_mask = value

func timers(delta):
	jump_timer = max(jump_timer - delta, 0)
	safe_ground = max(safe_ground - delta,0)
	if on_ground:
		safe_ground = 0.05
	ground = safe_ground > 0.0
	shoot_cooldown_snowball = max(shoot_cooldown_snowball - delta, 0)
	shoot_cooldown_icicle = max(shoot_cooldown_icicle - delta, 0)

func shoot_handling(delta):
	if Input.is_action_pressed("shoot") and get_parent().has_node("Projectiles"):
		shoot(delta)
	else: shooting = false
	if Input.is_action_just_released("shoot"):
		stop_laser()
	if Globals.selected_weapon == Globals.CHEST_ITEMS.SNOWBALL:
		if (get_global_mouse_position() - position).normalized().y < -0.2:
			$Line2D.modulate.a = min($Line2D.modulate.a + 0.05, 1)
		else:$Line2D.modulate.a = max($Line2D.modulate.a - 0.05, 0)
		if $Line2D.modulate.a > 0:
			shoot_preview_trail()
	else: $Line2D.modulate.a = 0
	if Input.is_action_pressed("laser"):
		start_laser(false)
	if Input.is_action_just_released("laser"):
		stop_laser()
	if laser_stop_queued and laser_time_left < laser_time_total - MINIMUM_LASER_TIME:
		stop_laser()
	if laser_firing:
		shoot_laser(delta)
	load_laser(delta)

func load_laser(delta):
	if laser == null:
		laser_time_left = min(laser_time_total, laser_time_left + delta * laser_fill_per_second)
		if Globals.debug_mode: laser_time_left = laser_time_total
	laserbar.update_value(laser_time_left)

func stop_laser():
	if laser != null and laser_firing:
		if laser_time_left > laser_time_total - MINIMUM_LASER_TIME:
			laser_stop_queued = true
		else:
			actually_stop_laser()

func actually_stop_laser():
	laser.stop(true)
	laser_firing = false
	current_laser_knockback = Vector2.ZERO

func start_laser(fromSelection):
	if !Globals.is_collected(Globals.CHEST_ITEMS.LASER) or shooting: return
	if laser_time_left == laser_time_total and laser == null:
		laser = laser_preload.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		if fromSelection:
			laser.thickness *= 0.75
			laser.spread /= 2
			laser.total_laser_damage /= 4
		add_child(laser)
		laser_firing = true
		laser_type = SELECTION_LASER if fromSelection else NORMAL_LASER

func shoot_laser(delta):
	if laser != null:
		laser.global_rotation = 0
		laser.look_at(get_global_mouse_position())
		var laser_reduction = delta if laser_type == NORMAL_LASER else delta/2
		laser_time_left = max(0, laser_time_left - laser_reduction)
		var direction = global_position - get_global_mouse_position()
		current_laser_knockback = direction * laser_knockback * laser.get_real_strength() * KNOCKBACK_MODIFIER
		if laser_time_left == 0:
			stop_laser()
		#print("Laser's rotation is: ", laser.rotation_degrees)

func shoot_snowball():
	var snowball_projectile = preload("res://Scenes/snowball.tscn").instantiate()
	var direction = (get_global_mouse_position() - position).normalized()
	snowball_projectile.linear_velocity = direction * 1000
	snowball_projectile.global_position = global_position + direction*50
	snowball_projectile.damage = damage_snowball
	get_node("../Projectiles").add_child(snowball_projectile)

func shoot_icicle():
	var icicle_projectile = preload("res://Scenes/icicle.tscn").instantiate()
	var direction = (get_global_mouse_position() - global_position).normalized()
	direction = direction.rotated((randf()-0.5)*0.1)
	icicle_projectile.linear_velocity = direction * speed_icicle
	icicle_projectile.look_at(direction)
	icicle_projectile.global_position = global_position + direction*50
	icicle_projectile.damage = damage_icicle
	get_node("../Projectiles").add_child(icicle_projectile)

func shoot_preview_trail():
	$Line2D.points = [Vector2.ZERO]
	var direction = (get_global_mouse_position() - position).normalized()
	var trail_velocity = direction * 32
	var point_position = direction * 50
	for i in range(35):
		$Line2D.add_point(point_position)
		trail_velocity.y += 1.85
		point_position += trail_velocity

func shoot(delta):
	if Globals.selected_weapon not in Globals.collected_items or ui.hovering_over_overlay_buttons(): return
	if Globals.selected_weapon == Globals.CHEST_ITEMS.LASER:
		start_laser(true)
	else: stop_laser()
	if laser_firing: return
	shooting = true
	if Globals.selected_weapon == Globals.CHEST_ITEMS.SNOWBALL and shoot_cooldown_snowball == 0:
		shoot_cooldown_snowball = reload_snowball
		shoot_snowball()
	if Globals.selected_weapon == Globals.CHEST_ITEMS.ICICLE and shoot_cooldown_icicle == 0:
		shoot_cooldown_icicle = reload_icicle
		shoot_icicle()

func _integrate_forces(state):
	if Engine.is_editor_hint():return
	
	$floor.global_position = global_position + floor_position
	$floor2.global_position = global_position + floor2_position
	$right.global_position = global_position + right_position
	$left.global_position = global_position + left_position
	$top.global_position = global_position + top_position
	
	#for child in get_children():
		#if child.get("global_rotation"):
			#child.global_rotation = 0
	global_rotation = 0
	
	paused = Globals.isPaused()
	if paused:
		if !save:save = velocity
		linear_velocity = Vector2.ZERO
		return
	elif save and Globals.state == "playin": 
		velocity = save
		save = null
	
	on_ground = $down.has_overlapping_bodies()
	
	var left = Input.is_action_pressed("ui_left")
	var right = Input.is_action_pressed("ui_right")
	
	if Input.is_action_just_pressed("jump"):
		jump_queued = true
	if jump_queued and (ground or on_ground) and Input.is_action_pressed("jump"):
		jump_queued = false
		jump_timer = JUMP_TIME
		start_jump()
	if jump_timer > 0 and Input.is_action_pressed("jump"):
		jump()
	else: jump_timer = 0
	
	rolling = Input.is_action_pressed("ui_down") and (left or right) and on_ground
	
	if on_ground:
		if extra < 1.02: velocity.y = min(velocity.y,0)
		velocity.x = lerp(velocity.x, (int(right)-int(left)) * (speed if !rolling else rolling_speed), acc)
	else:
		velocity.y += gravity
		velocity.x = lerp(velocity.x, (int(right)-int(left)) * speed, (acc/3))
	
	normal_v = velocity.x * extra
	linear_velocity.x = normal_v
	linear_velocity.y = min(velocity.y, speed+100)
	linear_velocity += current_laser_knockback
	
	extra = lerp(extra,1.0,0.1)
	
	#if normal_v < 0:$skin.scale.x = -1
	#if normal_v > 0:$skin.scale.x = 1
	
	if $floor.is_colliding() or $floor2.is_colliding():
		var floorPosition = max($floor.get_collision_point().y, $floor2.get_collision_point().y)-$col.shape.height/2
		if global_position.y + velocity.y/60 >= floorPosition:
			global_position.y = floorPosition
			linear_velocity.y = 0
			velocity.y = 0
	if $left.is_colliding():
		var leftPosition = $left.get_collision_point().x+$col.shape.radius
		if global_position.x + velocity.x/60 <= leftPosition:
			global_position.x = leftPosition
			linear_velocity.x = 0
			velocity.x = 0
	if $right.is_colliding():
		var rightPosition = $right.get_collision_point().x-$col.shape.radius
		if global_position.x + velocity.x/60 >= rightPosition:
			global_position.x = rightPosition
			linear_velocity.x = 0
			velocity.x = 0
	if $top.is_colliding() and !($top.get_collider() is StaticBody2D and $top.get_collider().name == "OneWayBody"):
		var top_pos = $top.get_collision_point().y + $col.shape.height/2
		print(global_position.y <= top_pos, ", ", global_position.y, ", ", top_pos)
		if global_position.y <= top_pos:
			velocity.y = -velocity.y * 0.25
			linear_velocity.y = -linear_velocity.y * 0.25
			global_position.y = top_pos + 0.01
		

func add_impulse(impulse: Vector2):
	velocity += impulse
	set_velocity(velocity + impulse)

func set_velocity(velocity: Vector2):
	self.velocity = velocity
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED

func jump():
	const build_up_time = 0.05
	const build_up_start_amplifier = 0.5
	if jump_timer < JUMP_TIME - build_up_time:
		velocity.y = -jump_speed
	else:
		var amplifier = lerp(build_up_start_amplifier, 1.0, (JUMP_TIME - jump_timer) / build_up_time)
		velocity.y = -jump_speed * amplifier

func start_jump():
	extra = 1.5
	$Jump.play()

func take_damage(amount: int) -> void:
	health = health - amount 
	if health <= 0:
		die()
	$Hurt.play("hurt")
	Globals.call_action(Globals.HEALTH, health)

func die():
	$Snowball.visible = false
	$Snowman.visible = true
	$Snowman/Dead/DieAnimation.play("die")
	Globals.playerDied()
