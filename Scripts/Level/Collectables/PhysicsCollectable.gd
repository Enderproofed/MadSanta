class_name PhysicsCollectable extends CharacterBody2D

var collectable_map = {
	E.COLLECT.COIN: "uid://bawf6rrfoul0i",
	E.COLLECT.SNOWFLAKE: "uid://c86r2jrovbcdf",
	E.COLLECT.ICE_SHARD: "uid://6ydg47mvcxcl",
	E.COLLECT.FIRE_SHARD: "uid://dbiwksccqorqa"
}

var collectable: E.COLLECT

func _ready() -> void:
	if collectable:
		var instance: Collectable = load(collectable_map[collectable]).instantiate()
		instance.id = -1
		instance.to_delete_on_collect.append(self)
		instance.set_activation_timer(0.75)
		add_child(instance)

func _physics_process(delta: float) -> void:
	velocity.y -= Globals.gravity
	
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal()) * 0.4
	
