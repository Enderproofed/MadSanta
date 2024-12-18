extends RigidBody2D

var speed = 250
var direction = -1
var enemy = true

func _ready() -> void:
	pass 


func _process(delta: float) -> void:
	pass

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if Globals.state == Globals.PLAYING:
		global_rotation = 0
		linear_velocity.x = speed * direction
	else: linear_velocity = Vector2.ZERO
	
	if $floor.is_colliding():
		var floorPosition = $floor.get_collision_point().y-$collision.shape.size.y/2
		if global_position.y < floorPosition:
			global_position.y = floorPosition
			linear_velocity.y = 0

func left_touched(body: Node2D) -> void:
	direction = 1
	$skin.scale.x = -1.5


func right_touched(body: Node2D) -> void:
	direction = -1
	$skin.scale.x = 1.5
