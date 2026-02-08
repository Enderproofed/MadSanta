class_name Enemy extends RigidBody2D

const BASE_ACCELERATION = 0.05
const AIR_ACCELERATION = 0.01
const ALERT_DISTANCE = 400.0
const ACTIVATION_DISTANCE = 1200.0
const UNALERT_TIME = 3
const ALERT_JUMP = 400

var alerted_speed_aplifier = 1.3
var base_speed = 150.0
var speed = base_speed
var direction = -1
var alerted = false
var active = false
var activated = false
var alert_counter = 0
var acceleration = BASE_ACCELERATION
var left_edge = false
var right_edge = false
var stunning = 1.0
var unalert_counter = 0
var alert_jump = null

var fully_initialized = false

@onready var healthbar: HealthBar = $EnemyBase/Healthbar
@onready var player_detect: RayCast2D = $EnemyBase/PlayerDetect
@onready var start_pos = global_position
@onready var base: EnemyBase = $EnemyBase

var health
var max_health

@export var door: Door
@export var border_set: BorderSet
@export var activated_by: Node2D

var multi_death_door_listener

func _init() -> void:
	if Engine.is_editor_hint(): return
	await Globals.timer(0.5)
	fully_initialized = true

func get_enemy_name() -> String:
	return $EnemyBase/Label.text

func set_health(health: float):
	self.health = health
	self.max_health = health
	healthbar.init_health(health)

func _process(delta: float) -> void:
	if not_activated(): 
		set_activated(false)
		return
	
	alert_counter = max(alert_counter - delta, 0)
	unalert_counter = max(unalert_counter - delta, 0)
	if linear_velocity.x < -2:
		$skin.scale.x = 1.5
		$walk.speed_scale = linear_velocity.x/100.0
		$walk.play("walk")
	elif linear_velocity.x > 2:
		$skin.scale.x = -1.5
		$walk.speed_scale = linear_velocity.x/100.0
		$walk.play("walk")
	else:
		$walk.stop()
		if self is Gnome:
			$skin/skin.frame = 0
		else: $skin.frame = 0
	
	left_edge = !$EnemyBase/Left.is_colliding()
	right_edge = !$EnemyBase/Right.is_colliding()
	
	if Globals.player != null and self is not Gnome:
		var distance_to_player = Globals.player.global_position - global_position
		if left_edge and distance_to_player.y > -distance_to_player.x:
			left_edge = false
		if right_edge and distance_to_player.y > distance_to_player.x:
			right_edge = false

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not_activated(): 
		linear_velocity = Vector2.ZERO
		global_position = start_pos
		set_deferred("process_mode", PROCESS_MODE_DISABLED)
		return
	
	global_rotation = 0
	if Globals.player != null and fully_initialized:
		var distance_to_player = position.distance_to(Globals.player.position)
		active = distance_to_player < ACTIVATION_DISTANCE
		#if distance_to_player < ALERT_DISTANCE:
		player_detect.target_position = Globals.player.global_position - global_position
		if player_detect.is_colliding() and player_detect.get_collider() == Globals.player:
			alert()
		else: unalert()
		#if distance_to_player > ALERT_DISTANCE * 1.5: unalert()
		
		if alerted:
			direction = 1 if position.x < Globals.player.position.x else -1
			$skin.scale.x = -1.5 if direction == 1 else 1.5
	
	if !Globals.isPaused() and active:
		if alert_counter <= 0:
			linear_velocity.x = lerp(linear_velocity.x, speed * direction, acceleration)
			if self is not Gnome:
				if left_edge: linear_velocity.x = max(0, linear_velocity.x)
				if right_edge: linear_velocity.x = min(linear_velocity.x, 0)
	else: linear_velocity = Vector2.ZERO
	
	if $floor.is_colliding() and alert_counter <= 0:
		acceleration = 0.07
		var floorPosition = $floor.get_collision_point().y - ($collision.shape.size.y/2 * $EnemyBase.scale.y)
		if global_position.y > floorPosition:# and jump_counter == 0:
			global_position.y = floorPosition
			linear_velocity.y = 0
	else:
		acceleration = 0.01
	
	if alert_jump != null:
		linear_velocity.y = alert_jump
		alert_jump = null

func left_touched(body: Node2D) -> void:
	if is_queued_for_deletion(): return
	direction = 1
	jump_obstacle()

func right_touched(body: Node2D) -> void:
	if is_queued_for_deletion(): return
	direction = -1
	jump_obstacle()

func jump_obstacle():
	if alerted and self != null and $ground != null and !$ground.get_overlapping_bodies().is_empty(): 
		alert_jump = -ALERT_JUMP
		unalert_counter += 0.5

func take_damage(amount: float, from_player = true) -> void:
	if is_queued_for_deletion() or not_activated(): return
	if from_player:
		alert()
	
	health = health - amount 
	healthbar.health = health
	if health <= 0:
		die()
	
	linear_velocity.x = lerp(linear_velocity.x, 0.0, stunning)
	$hurt.stop()
	$hurt.play("hurt")
	
	if amount >= 1:
		var bounds = $EnemyBase/Bounds.get_global_rect()
		var damage_pos = Vector2(randf() * bounds.size.x, randf() * bounds.size.y) + (bounds.position - global_position)
		add_alert("-" + str(int(amount)), damage_pos, randf_range(-20, 20), randf_range(0.4, 0.7), 1.6)

func die():
	if self == null or is_queued_for_deletion(): return
	if door != null:
		door.open(self)
	if multi_death_door_listener != null:
		multi_death_door_listener.call(self)
	if border_set != null:
		border_set.set_border()
	Globals.enemies_killed += 1
	queue_free()

func alert():
	unalert_counter = UNALERT_TIME
	if !alerted:
		on_alert()
		alerted = true
		alert_counter = 1
		add_alert("!")
		base.get_node("EyeFlash/Flash").play("flash")
		linear_velocity.x = 0
		speed = base_speed * alerted_speed_aplifier

# implemented by sub classes (actual enemy classes)
func on_alert():
	pass

func unalert():
	if alerted and unalert_counter <= 0:
		alerted = false
		speed = base_speed
		add_alert("?")
		for body in $left.get_overlapping_bodies(): left_touched(body)
		for body in $right.get_overlapping_bodies(): right_touched(body)

func add_alert(text, pos = Vector2(8, -16), rot = 0, size = 1, playback_speed = 1):
	var alertInstance = preload("res://Scenes/alert.tscn").instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	alertInstance.position = pos
	alertInstance.rotation_degrees = rot
	alertInstance.scale = Vector2(size, size)
	alertInstance.get_node("Label").text = text
	alertInstance.get_node("Animation").speed_scale = playback_speed
	add_child(alertInstance)

func not_activated():
	return activated_by != null and !activated

func activate():
	set_activated(true)
	set_deferred("process_mode", PROCESS_MODE_INHERIT)

func set_activated(value):
	$collision.disabled = !value
	$EnemyBase/HitBoxEnemy/CollisionShape2D.disabled = !value
	$EnemyBase/HurtBoxEnemy/CollisionShape2D.disabled = !value
	if value: activated = true
