extends RigidBody2D

var base_speed = 250.0
var speed = base_speed
var direction = -1
var enemy = true
var alerted = false
var alertCountdown = 0

const ALERT_DISTANCE = 400.0
@onready var healthbar 
var health

func _ready() -> void:
	healthbar = $Healthbar
	health = 100
	healthbar.init_health(health)

func _process(delta: float) -> void:
	alertCountdown = max(alertCountdown - delta, 0)
	if linear_velocity.x < 1:
		$skin.scale.x = 1.5
	if linear_velocity.x > 1:
		$skin.scale.x = -1.5
	

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	global_rotation = 0
	if Globals.state == Globals.PLAYING:
		if alertCountdown <= 0:
			linear_velocity.x = lerp(linear_velocity.x, speed * direction, 0.1)
	else: linear_velocity = Vector2.ZERO
	
	if $floor.is_colliding() and alertCountdown <= 0:
		var floorPosition = $floor.get_collision_point().y-$collision.shape.size.y/2
		if global_position.y < floorPosition:
			global_position.y = floorPosition
			linear_velocity.y = 0
	
	if Globals.player != null:
		var distance_to_player = position.distance_to(Globals.player.position)
		if distance_to_player < ALERT_DISTANCE:
			alert()
			direction = 1 if position.x < Globals.player.position.x else -1
		else: unalert()
		

func alert():
	if !alerted:
		$walk.stop()
		alerted = true
		alertCountdown = 1
		var alertInstance = preload("res://Scenes/alert.tscn").instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		alertInstance.position = Vector2(0, -24)
		add_child(alertInstance)
		linear_velocity.x = 0
		print("ALARM")
		speed = base_speed * 1.8
		$skin.frame = 0
		await Globals.timer(1)
		$walk.play("walk")
		$walk.speed_scale = 1.8

func unalert():
	alerted = false
	speed = base_speed
	$walk.speed_scale = 1

func left_touched(body: Node2D) -> void:
	direction = 1

func right_touched(body: Node2D) -> void:
	direction = -1
	
func take_damage(amount: int) -> void:
	health = health - amount 
	healthbar.health = health
	if health <= 0:
		queue_free()
	
	linear_velocity.x = 0
	$hurt.stop()
	$hurt.play("hurt")
