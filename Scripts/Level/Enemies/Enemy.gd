class_name Enemy extends CharacterBody2D

enum Type {
	UNDEFINED,
	GNOME,
	ELF,
	SNOW_MONSTER,
	MAD_SANTA
}

const BASE_ACCELERATION = 0.05
const AIR_ACCELERATION = 0.01
const ALERT_DISTANCE = 400.0
const ACTIVATION_DISTANCE = 1200.0
const UNALERT_TIME = 3
const HIT_COOLDOWN = 0.5
const JUMP_SPEED = 425 # 2 blocks = 600

var alerted_speed_aplifier = 1.3
var base_speed = 150.0
var speed = base_speed
var direction = -1
var alerted = false
var on_screen = false
var activated = false
var alert_counter = 0
var acceleration = BASE_ACCELERATION
var left_edge = false
var right_edge = false
var stunning = 1.0
var unalert_counter = 0
var alert_jump = null
var knockback = 300
var damage = 10
var hit_counter = 0
var has_name = true
var random_name = true
var enemy_name = "Dummy name"

var fully_initialized = false

var physics_collectable_load = load("uid://dhkqrwrqdwsx5")

@onready var healthbar: HealthBar = $EnemyBase/Healthbar
@onready var player_detect: RayCast2D = $EnemyBase/PlayerDetect
@onready var start_pos = global_position
@onready var base: EnemyBase = $EnemyBase
@onready var hitbox: HitBox = $EnemyBase/Hitbox

var health
var max_health

@export var border_set: BorderSet
@export var activated_by: Node2D
@export var contains_collectable = false:
	set(value):
		contains_collectable = value
		draw_outline()
@export var collectable: E.COLLECT:
	set(value):
		collectable = value
		draw_outline()
@export var collectable_amount = 2
@export var extra_health = 0

var death_door_listeners: Array[Callable] = []
var boss_bar: BossBar

func get_type(): return Type.UNDEFINED
func is_type(type: Type):
	return type == get_type()

const boss_types = [Type.SNOW_MONSTER, Type.MAD_SANTA]
func is_boss():
	return get_type() in boss_types
func boss_bar_count():
	if !is_boss(): return 0
	elif get_type() == Type.MAD_SANTA: return 3
	else: return 1

func _init() -> void:
	if Engine.is_editor_hint(): return
	await Globals.timer(0.5)
	fully_initialized = true

func _ready() -> void:
	draw_outline()
	hitbox.damage = damage
	hitbox.knockback = knockback
	SignalBus.player_died.connect(player_died)
	$EnemyBase/VisibilityRect.connect("screen_entered", screen_entered)
	$EnemyBase/VisibilityRect.connect("screen_exited", screen_exited)
	if is_boss():
		healthbar.queue_free()


func screen_entered():
	on_screen = true
	if is_boss():
		add_bossbar()

func screen_exited():
	on_screen = false
	if boss_bar != null:
		boss_bar.queue_free()

func add_bossbar():
	if LevelOverlay.current:
		var displayed_name = enemy_name if !enemy_name.is_empty() else str(tr(E.enum_to_string(Type, get_type())), " (", tr("UNNAMED"), ")")
		boss_bar = LevelOverlay.current.add_bossbar(displayed_name, health, max_health, boss_bar_count())
		boss_bar.visible = !(not_activated() or !on_screen)

const outline_map: Dictionary = {
	E.COLLECT.COIN: Color(0.8, 0.8, 1, 0.8),
	E.COLLECT.SNOWFLAKE: Color(5, 5, 5),
	E.COLLECT.ICE_SHARD: Color(0.7, 0.95, 5),
	E.COLLECT.FIRE_SHARD: Color(5, 0.75, 0.4, 0.8),
}
func draw_outline() -> void:
	var mat: ShaderMaterial = $Skin.material
	mat.set_shader_parameter("line_thickness", 0.69 if contains_collectable else 0.0)
	if contains_collectable:
		mat.set_shader_parameter("line_color", outline_map[collectable])

func get_enemy_name() -> String:
	return $EnemyBase/Label.text

func set_health(health: float):
	var new_health = health if !extra_health else health + extra_health
	self.health = new_health
	self.max_health = new_health
	if !is_boss():
		healthbar.init_health(new_health)

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if not_activated(): 
		set_activated(false)
		return
	
	hit_counter = max(hit_counter - delta, 0)
	alert_counter = max(alert_counter - delta, 0)
	unalert_counter = max(unalert_counter - delta, 0)
	if velocity.x < -2:
		if !alerted: $Skin.scale.x = abs($Skin.scale.x)
		$WalkAnimation.speed_scale = velocity.x/100.0
		$WalkAnimation.play("walk")
	elif velocity.x > 2:
		if !alerted: $Skin.scale.x = -abs($Skin.scale.x)
		$WalkAnimation.speed_scale = velocity.x/100.0
		$WalkAnimation.play("walk")
	else:
		$WalkAnimation.stop()
		$Skin.frame = 0
	
	left_edge = !$EnemyBase/Left.is_colliding()
	right_edge = !$EnemyBase/Right.is_colliding()
	
	if Globals.player != null and is_type(Type.GNOME) and alerted:
		var distance_to_player = Globals.player.global_position - global_position
		if left_edge and distance_to_player.y > -distance_to_player.x:
			left_edge = false
		if right_edge and distance_to_player.y > distance_to_player.x:
			right_edge = false

func can_hit():
	return hit_counter <= 0

func knock_back(bounce_normal: Vector2, bounce_ratio: float, normal_amount: float):
	velocity = velocity.bounce(bounce_normal) * bounce_ratio + bounce_normal.normalized() * normal_amount

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if not_activated(): 
		velocity = Vector2.ZERO
		global_position = start_pos
		set_deferred("process_mode", PROCESS_MODE_DISABLED)
		return
	
	var not_alert_frozen = alert_counter <= 0
	
	if Globals.player != null and fully_initialized:
		var distance_to_player = position.distance_to(Globals.player.position)
		player_detect.target_position = (Globals.player.global_position - global_position).normalized() * ALERT_DISTANCE * 2.5
		if player_detect.is_colliding() and player_detect.get_collider() == Globals.player:
			alert()
		else: unalert()
		
		if alerted:
			direction = 1 if position.x < Globals.player.position.x else -1
			$Skin.scale.x = -abs($Skin.scale.x) if direction == 1 else abs($Skin.scale.x)
	
	if State.is_playing_or_player_dead() and on_screen:
		if boss_bar != null: boss_bar.visible = true
		if not_alert_frozen:
			velocity.x = lerp(velocity.x, speed * direction, acceleration)
			if !alerted:
				if left_edge: left_touched(null)
				if right_edge: right_touched(null)
			elif !is_type(Type.GNOME):
				if left_edge: velocity.x = max(0, velocity.x)
				if right_edge: velocity.x = min(velocity.x, 0)
		else: velocity.x = 0
		
		velocity.y -= Globals.gravity
		var collision: KinematicCollision2D = move_and_collide(velocity * delta, true)
		if collision:
			var difference_to_right = collision.get_normal().distance_to(Vector2(1, 0))
			if difference_to_right < 0.01: left_touched()
			if difference_to_right > 1.98: right_touched()
		move_and_slide()
		
		if is_on_floor() and not_alert_frozen:
			acceleration = 0.07
		else: acceleration = 0.01
		
	else:
		velocity = Vector2.ZERO
		if boss_bar != null: boss_bar.visible = false
	

func is_alert_freeze():
	return alert_counter <= 0

func left_touched(body: Node2D = null) -> void:
	if body != self: set_direction(1)

func right_touched(body: Node2D = null) -> void:
	if body != self: set_direction(-1)

func set_direction(dir: int):
	if is_queued_for_deletion(): return
	direction = dir
	velocity.x = max(0, velocity.x) if dir >= 0 else min(0, velocity.x)
	jump_obstacle()

func jump_obstacle():
	if unalert_counter > 0 and self != null and is_type(Type.GNOME) and is_on_floor(): 
		velocity.y = -JUMP_SPEED
		print(velocity.y)
		unalert_counter += 0.5

func take_damage(amount: float, from_player = true) -> void:
	if is_queued_for_deletion() or not_activated() or !on_screen: return
	if from_player:
		alert()
	
	health = health - amount 
	
	if is_boss():
		if boss_bar != null: boss_bar.set_health(health)
	else: healthbar.health = health
	
	if amount >= 1:
		var bounds = $EnemyBase/Bounds.get_global_rect()
		var damage_pos = Vector2(randf() * bounds.size.x, randf() * bounds.size.y) + (bounds.position - global_position)
		add_alert("-" + str(int(amount)), damage_pos, randf_range(-20, 20), randf_range(0.4, 0.7), 1.6)
	
	if health <= 0:
		die()
	
	velocity.x = lerp(velocity.x, 0.0, stunning)
	$HurtAnimation.stop()
	$HurtAnimation.play("hurt")
	

func die():
	if self == null or is_queued_for_deletion(): return
	for listener in death_door_listeners:
		listener.call(self)
	if border_set != null:
		border_set.set_border()
	Globals.enemies_killed += 1
	spawn_collectables()
	if boss_bar != null: boss_bar.queue_free()
	queue_free()

func spawn_collectables():
	if contains_collectable and collectable and collectable_amount > 0:
		for i in range(collectable_amount):
			var physics_collectable: PhysicsCollectable = physics_collectable_load.instantiate()
			physics_collectable.collectable = collectable
			physics_collectable.velocity = Vector2(0, -1).rotated(deg_to_rad(randi_range(-30, 30))) * randi_range(150, 700)
			physics_collectable.global_position = global_position
			get_parent().add_child(physics_collectable)

func alert():
	unalert_counter = UNALERT_TIME
	if !alerted and Globals.player and !Globals.player.dead:
		on_alert()
		print("alerted")
		alerted = true
		alert_counter = 1
		add_alert("!")
		base.get_node("EyeFlash/Flash").play("flash")
		velocity.x = 0
		speed = base_speed * alerted_speed_aplifier

# implemented by sub classes (actual enemy classes)
func on_alert():
	pass

func player_died():
	unalert(false)

func dealt_damage_to_player(player: Player):
	velocity.x = 0
	if player.dead:
		$EnemyBase/SpeakBubble.visible = true

func unalert(show_question_mark = true):
	if alerted and (unalert_counter <= 0 or !show_question_mark):
		print("unalert")
		alerted = false
		speed = base_speed
		if show_question_mark: add_alert("?")
		else: base.get_node("EyeFlash/Flash").play("flash")

func add_alert(text, pos = Vector2(8, -16), rot = 0, size = 1, playback_speed = 1):
	var alertInstance = load("res://Scenes/Alerts/WorldAlert.tscn").instantiate()
	alertInstance.position = global_position + pos
	alertInstance.rotation_degrees = rot
	alertInstance.scale = Vector2(size, size)
	alertInstance.get_node("Label").text = text
	alertInstance.get_node("Animation").speed_scale = playback_speed
	get_parent().add_child(alertInstance)

func not_activated():
	return activated_by != null and !activated

func activate():
	set_activated(true)
	set_deferred("process_mode", PROCESS_MODE_INHERIT)

func set_activated(value):
	$Collision.disabled = !value
	if value: activated = true
