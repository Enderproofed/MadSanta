class_name Enemy extends RigidBody2D

const BASE_ACCELERATION = 0.05
const AIR_ACCELERATION = 0.01
const ALERT_DISTANCE = 400.0
const ACTIVATION_DISTANCE = 800.0

var alerted_speed_aplifier = 1.3
var base_speed = 150.0
var speed = base_speed
var direction = -1
var enemy = true
var alerted = false
var active = false
var activated = false
var alertCountdown = 0
var acceleration = BASE_ACCELERATION
var left_edge = false
var right_edge = false
var stunning = 1.0

@onready var healthbar: HealthBar = $EnemyBase/Healthbar
var health
var max_health

@export var door: Door
@export var activated_by: Node2D

func get_enemy_name() -> String:
	return $EnemyBase/Label.text

func set_health(health: float):
	self.health = health
	self.max_health = health
	healthbar.init_health(health)

func _process(delta: float) -> void:
	if activated_by != null and activated != true: return
	
	alertCountdown = max(alertCountdown - delta, 0)
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
	
	var distance_to_player = Globals.player.global_position - global_position
	if left_edge and distance_to_player.y > -distance_to_player.x:
		left_edge = false
	if right_edge and distance_to_player.y > distance_to_player.x:
		right_edge = false

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if activated_by != null and activated != true: return
	
	global_rotation = 0
	if Globals.player != null:
		var distance_to_player = position.distance_to(Globals.player.position)
		active = distance_to_player < ACTIVATION_DISTANCE
		if distance_to_player < ALERT_DISTANCE:
			alert()
			direction = 1 if position.x < Globals.player.position.x else -1
			$skin.scale.x = -1.5 if direction == 1 else 1.5
		if distance_to_player > ALERT_DISTANCE * 1.5: unalert()
	
	if !Globals.isPaused() and active:
		if alertCountdown <= 0:
			linear_velocity.x = lerp(linear_velocity.x, speed * direction, acceleration)
			if left_edge: linear_velocity.x = max(0, linear_velocity.x)
			if right_edge: linear_velocity.x = min(linear_velocity.x, 0)
	else: linear_velocity = Vector2.ZERO
	
	if $floor.is_colliding() and alertCountdown <= 0:
		acceleration = 0.07
		var floorPosition = $floor.get_collision_point().y-$collision.shape.size.y/2
		if global_position.y < floorPosition:
			global_position.y = floorPosition
			linear_velocity.y = 0
	else:
		acceleration = 0.01

func left_touched(body: Node2D) -> void:
	direction = 1

func right_touched(body: Node2D) -> void:
	direction = -1
	
func take_damage(amount: int) -> void:
	health = health - amount 
	healthbar.health = health
	if health <= 0:
		die()
	
	linear_velocity.x = lerp(linear_velocity.x, 0.0, stunning)
	$hurt.stop()
	$hurt.play("hurt")

func die():
	if door != null:
		door.open()
	Globals.enemies_killed += 1
	queue_free()

func alert():
	if !alerted:
		alerted = true
		alertCountdown = 1
		var alertInstance = preload("res://Scenes/alert.tscn").instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		alertInstance.position = Vector2(0, -24)
		add_child(alertInstance)
		linear_velocity.x = 0
		speed = base_speed * alerted_speed_aplifier

func unalert():
	alerted = false
	speed = base_speed

func activate():
	activated = true
