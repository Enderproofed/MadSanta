@tool
class_name Player extends CharacterBody2D

var laser_load = load("uid://bf2llq05hfk8m")
var icicle_load = load("uid://byruqbxri55ls")
var snowball_load = load("uid://cf6ewm62kcask")

const JUMP_TIME = 0.25
const ICICLE_TRAIL_START_COLOR = Color(1, 1, 1, 0.5)

var speedrun_stunned = true
var speedrun_time = 1000.0
var time_started = false
var level_time = 0.0
var new_ghost_frames: Array[GhostFrame] = []

var flight = false
var flight_timer = 0.0
var flight_wait_timer = 0.0
var flight_tap_timer = 0.0
const flight_accel = 0.15

var speed = 375.0
var rolling_speed = 625.0
const rolling_stunning = 0.75
var rolling_timer = 0

var acc = 0.12
var jump_speed = 500.0   # 600.0 = super jump
var jump_extra_speed = 100.0
var jump_timer = 0
var jump_queued = false
var extra = 1.0
var on_ground = false
var save
var safe_ground = 0
var ground = false
var normal_v = 0
var paused = false
var shoot_cooldown_snowball = 0
var shoot_cooldown_icicle = 0
var laser_time_left = 3.0
var laser_knockback = 3
var displayed_bounces = 1
var body_damage = 35

var last_one_way
var falling_one_way

const MAX_SPEED = 900.0
const KNOCKBACK_MODIFIER = 0.1
const MINIMUM_LASER_TIME = 1
const coin_health_bonus = 10

@onready var ui: UI = get_node("/root/Main/Overlay/UI")
@onready var level_overlay: LevelOverlay = LevelOverlay.current
# U havin issues here? Just make the player use components -> When it does not have health, it doesn't load this:
@onready var healthbar: Bar = level_overlay.get_node("HealthBar") if level_overlay else null
@onready var laserbar: Bar = level_overlay.get_node("LaserBar") if level_overlay else null
@onready var overlay_wings: Node2D = level_overlay.get_node("Wings/Wings") if level_overlay else null
@onready var overlay_speedrun_timer: Label = level_overlay.get_node("SpeedrunTimer") if level_overlay else null
@onready var overlay_speedrun_animation: AnimationPlayer = level_overlay.get_node("SpeedrunCounter/Animation") if level_overlay else null

@onready var projectiles_container: Node2D = get_node("../Projectiles")
@onready var level: Level = get_parent()

@onready var health_component: HealthComponent = %HealthComponent

@onready var init_collision_mask = collision_mask

@export var cam_active = true
@export var health = 100
var max_health = health

var shooting = false
var laser: Laser = null
var laser_firing = false
var laser_stop_queued = false
var current_laser_knockback = Vector2.ZERO

#affected by upgrades
var reload_snowball = Upgrades.init_reload_snowball
var reload_icicle = Upgrades.init_reload_icicle
var damage_snowball = 15
var damage_icicle = 10
var speed_snowball = Upgrades.init_speed_snowball
var speed_icicle = Upgrades.init_speed_icicle
var size_snowball = Upgrades.init_size_snowball
var size_icicle = Upgrades.init_size_icicle
var degrees_icicle = Upgrades.init_degrees_icicle
var laser_fill_per_second = Upgrades.init_laser_fill_per_second
var laser_time_total = Upgrades.init_laser_time_total
var laser_spread = Upgrades.init_laser_spread
var laser_strength = Upgrades.init_laser_strength
var flight_time = Upgrades.init_flight_time
var flight_wait_time = Upgrades.init_flight_wait_time
var flight_speed = Upgrades.init_flight_speed

var current_speed_snowball = Upgrades.init_speed_snowball

#states
var rolling = false:
	set(value):
		rolling = value
		var shape: CapsuleShape2D = $col.shape
		shape.height = 36 if rolling else 48
		$col.position.y = 3 if rolling else 0

func upgrade_update():
	for item in Globals.upgrades.keys():
		for upgrade in Globals.upgrades[item]:
			upgrade_updated(item, Upgrades.upgrade_name_map.find_key(upgrade))


func upgrade_updated(item: E.CHEST_ITEMS, upgrade: Upgrades.Type):
	if !Upgrades.upgrades_variable_map[item].has(upgrade): return
	
	var upgrades = Upgrades.fetch_upgrade_amount(item, upgrade)
	
	var upgrade_variable_name = Upgrades.upgrades_variable_map[item][upgrade]
	set(upgrade_variable_name, Upgrades.upgrade_effect(item, upgrade, upgrades))
	
	if item == E.CHEST_ITEMS.SNOWBALL:
		if upgrade == Upgrades.Type.SIZE:
			$TestSnowball.scale = Vector2(size_snowball, size_snowball)
		elif upgrade == Upgrades.Type.SPEED:
			current_speed_snowball = speed_snowball
		elif upgrade == Upgrades.Type.BOUNCES:
			Snowball.bounces = displayed_bounces
		shoot_preview_trail(true)
	elif item == E.CHEST_ITEMS.ICICLE and upgrade == Upgrades.Type.SPREAD: shoot_preview_trail(true)
	elif item == E.CHEST_ITEMS.LASER:
		if upgrade == Upgrades.Type.SPEED and laserbar:
			laserbar.update_max_value(laser_time_total, 20)
			laser_time_left = laserbar.value

func _init() -> void:
	if Engine.is_editor_hint(): return
	Globals.player = self
	#simulation(20)

func _collected(collectable_type: E.COLLECT):
	if collectable_type == E.COLLECT.COIN:
		heal(coin_health_bonus)

func _ready() -> void:
	if Engine.is_editor_hint(): return
	$col.z_index = 10
	$TestSnowball.show()
	SignalBus.collected.connect(_collected)
	SignalBus.upgrades_reset.connect(upgrade_update)
	health = 100
	if level_overlay:
		healthbar.init_progress(health)
		laserbar.init_progress(laser_time_total)
		laserbar.update_value(laser_time_left)
		overlay_speedrun_timer.visible = false
		overlay_speedrun_animation.play("RESET")
	$Snowman.show()
	$Snowball.hide()
	if projectiles_container == null:
		add_projectiles_container()
	$Prediction.hide()
	$Wings.hide()
	
	SignalBus.upgrade_bought.connect(upgrade_updated)
	upgrade_update()
	Globals.player_cam = $Cam
	if !cam_active: $Cam.enabled = false 
	await get_tree().physics_frame
	$Cam.position_smoothing_enabled = true
	speedrun_stunned = State.equals(State.SPEEDRUN_MINIGAME)
	if speedrun_stunned:
		overlay_speedrun_animation.play("Count")
		await Globals.timer(4)
		speedrun_stunned = false
		overlay_speedrun_timer.visible = true
		time_started = true
	else:
		time_started = true

func _process(delta):
	if Engine.is_editor_hint() or speedrun_stunned: return
	if Globals.level != null and Globals.player_cam != null:
		if position.y >= Globals.player_cam.limit_bottom:
			die()
	
	fall_through_one_way()
	if State.is_playing():
		shoot_handling(delta)
		snowball_adjust()
		if overlay_wings: flight_handling(delta)
	
	var snowball_visible = rolling or is_rolling_stunned()
	$Snowball.visible = snowball_visible
	$Snowman.visible = !snowball_visible

var intermediate_velocity = velocity
var average_delta = 0.016
var deltas60 = [average_delta]
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or dead: return
	
	# used for preview trail, might be boilerplate and there is a framerate independent solution
	deltas60.append(delta)
	if deltas60.size() > 60:
		deltas60.pop_front()
	average_delta = 0
	for delta1 in deltas60:
		average_delta += delta1
	average_delta /= float(deltas60.size())
	
	paused = !State.is_playing() or speedrun_stunned
	if paused:
		if !save: save = intermediate_velocity
		velocity = Vector2.ZERO
		return
	elif save: 
		intermediate_velocity = save
		save = null
	
	var left = Input.is_action_pressed("ui_left")
	var right = Input.is_action_pressed("ui_right")
	var up = Input.is_action_pressed("jump")
	var down = Input.is_action_pressed("ui_down")
	
	if !(Globals.debug_mode or Globals.has_wings()): flight = false
	$Wings.visible = flight
	if flight:
		rolling = false
		var target_velocity = Vector2(float(right) - float(left), float(down) - float(up)).normalized() * flight_speed
		intermediate_velocity = lerp(intermediate_velocity, target_velocity, flight_accel)
		velocity = intermediate_velocity
		move_and_slide()
		timers(delta)
		return
	
	var floor_collider = $FloorRay.get_collider()
	if floor_collider != null and falling_one_way == null and floor_collider.get_parent() is OneWayPlatform:
		last_one_way = floor_collider
	
	var collision: KinematicCollision2D = move_and_collide(velocity * delta, true)
	#var simulated_normal = Vector2(0, -1) if !colision else colision.get_normal()
	if collision:
		if rolling:# and (collision.get_normal().y >= -0.001 or velocity.y > abs(velocity.x)) and !is_rolling_stunned():
			kissed_wall(collision.get_collider(), collision.get_normal())
		elif rolling: print(collision.get_normal())
		
	if is_on_ceiling():
		jump_timer = 0
	
	if Input.is_action_just_pressed("jump"):
		jump_queued = true
	if jump_queued and (ground or on_ground) and up:
		jump_queued = false
		jump_timer = JUMP_TIME
		start_jump()
	if jump_timer > 0 and up:
		jump()
	else: jump_timer = 0
	
	if down:# and (left or right):# and (abs(linear_velocity.x) > speed-25 or is_rolling_stunned()):
		if on_ground:
			rolling = true
	elif !is_rolling_stunned():
		rolling = false
		
	
	var target_direction = int(right)-int(left)
	var target_speed = rolling_speed if rolling else speed # and on_ground
	var target_acceleration = acc
	if rolling: target_acceleration /= 3
	if !on_ground: target_acceleration /= 3
	intermediate_velocity.y -= Globals.gravity
	if !is_rolling_stunned(): 
		intermediate_velocity.x = lerp(intermediate_velocity.x, target_direction * target_speed, target_acceleration)
	
	intermediate_velocity.y = min(intermediate_velocity.y, MAX_SPEED) # max falling speed
	
	extra = lerp(extra,1.0,0.1)
	velocity = intermediate_velocity * Vector2(extra, 1) + current_laser_knockback
	#print("before: ", velocity.x)
	move_and_slide()
	#print("after: ", velocity.x)
	# adjust, if there was a colision
	intermediate_velocity.x = clamp(intermediate_velocity.x, -abs(velocity.x), abs(velocity.x))
	intermediate_velocity.y = clamp(intermediate_velocity.y, -abs(velocity.y), abs(velocity.y))
	on_ground = is_on_floor()
	if rolling:
		$Snowball.rotation_degrees += velocity.x * delta * 1.2
	
	timers(delta)

func is_rolling_stunned() -> bool:
	return rolling_timer > 0.0

func kissed_wall(wall, normal):
	var current_speed = velocity.length()
	var normal_difference = normal.distance_to(Vector2(0, 1))
	var is_floor = normal_difference < 0.01 or normal_difference > 1.98
	if !is_floor:
		if on_ground:
			setVelocity(Vector2(normal.x, -1.75).normalized() * intermediate_velocity.length(), true)
		else:
			setVelocity(intermediate_velocity.bounce(normal) * 0.8, true)
	else:
		setVelocity(intermediate_velocity.bounce(normal) * Vector2(1, 0.4), true)
	
	rolling_timer = rolling_stunning * (current_speed / 400.0)
	if is_floor:
		rolling_timer *= 0.25
	if current_speed > speed:
		jump_timer = 0
		if wall is BrickWall:
			wall.take_damage(current_speed*0.75)
		if wall is Enemy:
			wall.take_damage(current_speed / MAX_SPEED * body_damage)
		Globals.shake_intensity = 6 * current_speed / speed
		Globals.shake_effect()
		await Globals.timer(rolling_timer, true)
		Globals.stop_shake_effect()

func add_impulse(impulse: Vector2):
	velocity += impulse
	setVelocity(velocity + impulse)

func setVelocity(new_velocity: Vector2, also_set_actual = false):
	intermediate_velocity = new_velocity
	if intermediate_velocity.length() > MAX_SPEED:
		intermediate_velocity = new_velocity.normalized() * MAX_SPEED
	if also_set_actual: velocity = intermediate_velocity

func knock_back(bounce_normal: Vector2, bounce_ratio: float, normal_amount: float):
	setVelocity(velocity.bounce(bounce_normal) * bounce_ratio + bounce_normal.normalized() * normal_amount, true)

func jump():
	const build_up_time = 0.05
	const build_up_start_amplifier = 0.5
	if jump_timer < JUMP_TIME - build_up_time:
		intermediate_velocity.y = -jump_speed
	else:
		var amplifier = lerp(build_up_start_amplifier, 1.0, (JUMP_TIME - jump_timer) / build_up_time)
		intermediate_velocity.y = -jump_speed * amplifier

func start_jump():
	extra = 1.5
	$Jump.play()

func flight_handling(delta):
	overlay_wings.visible = Globals.has_wings()
	if !(Globals.debug_mode or Globals.has_wings()): return
	if Globals.debug_mode: 
		flight_wait_timer = 0
		flight_timer = flight_time
	
	if flight_wait_timer <= 0.0 and Input.is_action_just_pressed("jump"):
		if flight_tap_timer > 0.0 and !is_rolling_stunned():
			flight_tap_timer = 0.0
			flight = !flight
			if flight:
				flight_timer = flight_time
				$Wings/Animation.play("RESET")
			else: flight_wait_timer = flight_wait_time
		else: flight_tap_timer = 0.5
	
	if flight:
		if flight_timer <= 2.0:
			$Wings/Animation.play("indicator")
		if flight_timer <= 0.0:
			flight = false
			flight_wait_timer = flight_wait_time
	
	# Overlay display
	var ratio = (flight_wait_time - flight_wait_timer) / flight_wait_time
	if flight_wait_timer <= 0:
		overlay_wings.modulate = Color(1.05, 1.05, 1.05)
		overlay_wings.get_node("Halo").modulate = Color(2, 2, 1)
		overlay_wings.get_node("WingLeft/Animation").play("flap")
		overlay_wings.get_node("WingRight/Animation").play("flap")
		overlay_wings.get_node("../ReloadTimer").text = ""
	else:
		overlay_wings.get_node("WingLeft/Animation").play("RESET")
		overlay_wings.get_node("WingRight/Animation").play("RESET")
		overlay_wings.modulate = lerp(Color(0, 0, 0, 0.5), Color(0.9, 0.9, 0.9, 0.9), ratio)
		overlay_wings.get_node("Halo").modulate = Color(1, 1, 1)
		overlay_wings.get_node("../ReloadTimer").text = str(int(flight_wait_timer) + 1, "s")

func snowball_adjust():
	if Input.is_action_pressed("SnowballAdjust"):
		var modifier = int(Input.is_action_just_pressed("mouse_up")) - int(Input.is_action_just_pressed("mouse_down"))
		current_speed_snowball = clamp(current_speed_snowball + modifier * 10, 200, speed_snowball)

func add_projectiles_container():
	projectiles_container = Node2D.new()
	projectiles_container.name = "Projectiles"
	add_sibling(projectiles_container)
	get_parent().add_child(projectiles_container)
	if !has_node("../Projectiles"): # Not there? Try again. Parent probably not ready yet
		print("Waiting for parent to ready up!")
		await get_tree().physics_frame
		get_parent().add_child(projectiles_container)

func fall_through_one_way():
	#if Input.is_action_just_pressed("ui_down"):
		#set_collision(init_collision_mask - 16) # 16 = bit value of 5 -> one way platform collision layer
	#if Input.is_action_just_released("ui_down"):
		#set_collision(init_collision_mask)
	
	if last_one_way != null and !(rolling and abs(velocity.x) > 10):
		if Input.is_action_just_pressed("ui_down"):
			falling_one_way = last_one_way
			last_one_way = null
			add_collision_exception_with(falling_one_way)
	if falling_one_way != null:
		if Input.is_action_just_released("ui_down"):
			remove_collision_exception_with(falling_one_way)
			falling_one_way = null
		

func set_collision(value):
	collision_mask = value

const timer_names = [
	"jump_timer", "safe_ground", "shoot_cooldown_snowball", "shoot_cooldown_icicle",
	"rolling_timer", "flight_tap_timer", "flight_timer", "flight_wait_timer", "speedrun_time"
]
func timers(delta):
	for timer_name in timer_names:
		do_timer(timer_name, delta)
	if on_ground:
		safe_ground = 0.05
	ground = safe_ground > 0.0
	if State.equals(State.SPEEDRUN_MINIGAME):
		overlay_speedrun_timer.text = Globals.time_to_str(speedrun_time)
	if time_started:
		level_time += delta
		if int(level_time * Level.GHOST_FRAMES_PER_SECOND) > int((level_time - delta) * Level.GHOST_FRAMES_PER_SECOND):
			new_ghost_frames.append(GhostFrame.init(level_time, position, flight, rolling, $Snowball.rotation_degrees))
		level.update_ghost(level_time)

func do_timer(variable_name: String, delta):
	set(variable_name, max(get(variable_name) - delta, 0))

func shoot_handling(delta):
	if Input.is_action_pressed("mouse_left") and get_parent().has_node("Projectiles") and !rolling:
		shoot(delta)
	else: shooting = false
	if Input.is_action_just_released("mouse_left"):
		stop_laser()
	if Globals.selected_weapon in E.weapons_with_trail:
		$Prediction.modulate.a = 1
		#$Prediction.modulate.a = min($Prediction.modulate.a + 0.05, 1)
		#if $Prediction.modulate.a > 0:
		shoot_preview_trail(false)
	else: $Prediction.modulate.a = 0
	if Input.is_action_pressed("laser"):
		start_laser()
	if Input.is_action_just_released("laser"):
		stop_laser()
	if laser_stop_queued and laser_time_left < laser_time_total - MINIMUM_LASER_TIME or rolling:
		stop_laser()
	if laser_firing:
		shoot_laser(delta)
	load_laser(delta)

func load_laser(delta):
	if laserbar == null: return
	if laser == null:
		laser_time_left = min(laser_time_total, laser_time_left + delta * laser_fill_per_second)
		if Globals.debug_mode: laser_time_left = laser_time_total
	laserbar.update_value(laser_time_left)

func stop_laser():
	if laser != null and laser_firing:
		if laser_time_left > laser_time_total - MINIMUM_LASER_TIME and !Globals.debug_mode:
			laser_stop_queued = true
		else:
			actually_stop_laser()

func actually_stop_laser():
	laser.stop(true)
	laser_firing = false
	laser_stop_queued = false
	current_laser_knockback = Vector2.ZERO

func start_laser():
	if !Globals.is_collected(E.CHEST_ITEMS.LASER) or shooting or rolling: return
	if laser_time_left == laser_time_total and laser == null:
		laser = laser_load.instantiate()
		laser.spread = laser_spread
		laser.strength = laser_strength
		add_child(laser)
		laser_firing = true

func shoot_laser(delta):
	if laser != null:
		laser.global_rotation = 0
		laser.look_at(get_global_mouse_position())
		laser_time_left = max(0, laser_time_left - delta)
		if Globals.debug_mode: laser_time_left = laser_time_total
		var direction = global_position - get_global_mouse_position()
		current_laser_knockback = direction * laser_knockback * laser.get_real_strength() * KNOCKBACK_MODIFIER
		if laser_time_left == 0:
			stop_laser()
		#print("Laser's rotation is: ", laser.rotation_degrees)

func shoot_snowball():
	var snowball_projectile = snowball_load.instantiate()
	var direction = (get_global_mouse_position() - position).normalized()
	snowball_projectile.velocity = direction * current_speed_snowball / size_snowball
	snowball_projectile.global_position = global_position + direction * snowball_spawn_dist()
	snowball_projectile.damage = damage_snowball * size_snowball
	snowball_projectile.size = size_snowball
	snowball_projectile.mass = Globals.upgrades[E.CHEST_ITEMS.SNOWBALL][Upgrades.get_upgrade_name(Upgrades.Type.SIZE)]
	projectiles_container.add_child(snowball_projectile)

func shoot_icicle():
	var icicle_projectile = icicle_load.instantiate()
	var direction = (get_global_mouse_position() - global_position).normalized()
	direction = direction.rotated(deg_to_rad((randf()-0.5) * degrees_icicle * 2))
	icicle_projectile.velocity = direction * speed_icicle
	icicle_projectile.look_at(direction)
	icicle_projectile.global_position = global_position + direction*50
	icicle_projectile.damage = damage_icicle
	projectiles_container.add_child(icicle_projectile)

func shoot(delta):
	if Globals.selected_weapon not in Globals.collected_items or ui.hovering_over_overlay_buttons(): return
	if laser_firing: return
	shooting = true
	if Globals.selected_weapon == E.CHEST_ITEMS.SNOWBALL and shoot_cooldown_snowball == 0:
		shoot_cooldown_snowball = reload_snowball
		shoot_snowball()
	if Globals.selected_weapon == E.CHEST_ITEMS.ICICLE and shoot_cooldown_icicle == 0:
		shoot_cooldown_icicle = reload_icicle
		shoot_icicle()

func snowball_spawn_dist() -> float:
	return max(50, size_snowball * 2 * 16) # 16 = base radius -> "collision"(-shape)

var last_mouse_position = Vector2()
var total_distance = 0.0
const step = 120
func shoot_preview_trail(use_last_position = false): # approximated delta, as it would fluctuate too much -> might want to take average in future
	$Prediction.visible = Globals.draw_preview and Globals.selected_weapon in E.weapons_with_trail and !rolling
	var mouse_pos = get_global_mouse_position() if !use_last_position else last_mouse_position
	last_mouse_position = mouse_pos
	if !$Prediction.visible: return
	
	var delta = average_delta
	var direction = (mouse_pos - position).normalized()
	
	if Globals.selected_weapon == E.CHEST_ITEMS.SNOWBALL: shoot_snowball_preview_trail(delta, direction)
	if Globals.selected_weapon == E.CHEST_ITEMS.ICICLE: shoot_icicle_preview_trail(direction)

func shoot_snowball_preview_trail(delta, direction):
	var point_position = direction * snowball_spawn_dist()
	$TestSnowball.position = point_position
	var snowball_velocity = direction * current_speed_snowball / size_snowball
	$Prediction.points = [Vector2.ZERO]
	add_point(point_position)
	var hits = 0
	var second_last_hit_distance = 0.0 
	total_distance = 0.0
	var die_timer = Snowball.time_after_colision
	for i in range(step):
		snowball_velocity.y -= Globals.gravity
		if hits > 0:
			if die_timer <= 0:
				break
			die_timer -= delta
		var collision: KinematicCollision2D = $TestSnowball.move_and_collide(snowball_velocity * delta)
		if collision:
			var snowball_radius = size_snowball * 16 # 16 = base radius -> "collision"(-shape)
			add_point(collision.get_position() - global_position + collision.get_normal() * snowball_radius)
			snowball_velocity = snowball_velocity.bounce(collision.get_normal())
			snowball_velocity = snowball_velocity.normalized() * snowball_velocity.length() * Snowball.bounciness
			if hits == displayed_bounces:
				add_point(point_position + collision.get_travel())
				break
			hits += 1
			second_last_hit_distance = total_distance
			point_position += collision.get_travel()
		else:
			point_position += snowball_velocity * delta
			add_point(point_position)
	
	$TestSnowball.position = Vector2(-10000, 10000) # Gaaaaanz ganz weit weg schicken hehe
	
	var gradient: Gradient = $Prediction.gradient
	gradient.offsets = [0.0, float(second_last_hit_distance) / float(total_distance), 1.0]
	gradient.colors = [Color.WHITE, Color.WHITE, Color.TRANSPARENT]
	
	var curve: Curve = $Prediction.width_curve
	curve.set_point_value(1, 1.0)

const trail_length = 1000
func shoot_icicle_preview_trail(direction):
	var gradient: Gradient = $Prediction.gradient
	gradient.offsets = [0.0, 0.05, 1.0]
	gradient.colors = [ICICLE_TRAIL_START_COLOR, ICICLE_TRAIL_START_COLOR, Color.TRANSPARENT]
	
	var spread = (tan(deg_to_rad(degrees_icicle)) * trail_length * 0.2) + 1
	var curve: Curve = $Prediction.width_curve
	curve.max_value = spread
	curve.set_point_value(1, spread)
	print(spread)
	
	$Prediction.points = [Vector2.ZERO]
	add_point(direction * 50)
	for i in range(1, trail_length / 50):
		add_point(direction * 50 * i)

var last_point = Vector2.ZERO
func add_point(point: Vector2):
	$Prediction.add_point(point)
	total_distance += last_point.distance_to(point)
	last_point = point

func take_damage(amount: int) -> void:
	if dead: return
	health = health - amount 
	if health <= 0 and !Globals.debug_mode:
		die()
	$Hurt.play("hurt")
	SignalBus.health.emit(health)

func heal(amount: int):
	health = min(health + amount, max_health)
	SignalBus.health.emit(health)

var dead = false
func die():
	if !dead:
		rolling = false
		rolling_timer = 0
		dead = true
		collision_layer = 0
		collision_mask = 0
		$col.disabled = true
		$Snowball.hide()
		$Snowman.show()
		$Wings.hide()
		$Prediction.hide()
		$Snowman/Dead/DieAnimation.play("die")
		Globals.playerDied()
		velocity = Vector2.ZERO
		intermediate_velocity = Vector2.ZERO
		SignalBus.player_died.emit()

func set_snow_ratio(ratio: float):
	Globals.player.get_node("Snow").amount_ratio = ratio
