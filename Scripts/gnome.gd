extends RigidBody2D

var base_speed = 250.0
var speed = base_speed
var direction = -1
var enemy = true
var alerted = false
var alertCountdown = 0

const alertDistance = 500.0

func _ready() -> void:
	pass

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
		if distance_to_player < alertDistance:
			alert()
			direction = 1 if position.x < Globals.player.position.x else -1
		else: 
			alerted = false
			speed = base_speed
		

func alert():
	if !alerted:
		alerted = true
		alertCountdown = 1
		var alertInstance = preload("res://Scenes/alert.tscn").instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		alertInstance.position = Vector2(0, -24)
		add_child(alertInstance)
		linear_velocity.x = 0
		print("ALARM")
		speed = base_speed * 1.8
	

func left_touched(body: Node2D) -> void:
	direction = 1


func right_touched(body: Node2D) -> void:
	direction = -1
