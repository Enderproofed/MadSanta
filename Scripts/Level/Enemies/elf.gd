@tool
extends Enemy

const RELOAD_SPEED = 2

var present_load = load("uid://p5j6vnx6wwu1")

var reload = 0

func _ready() -> void:
	super()
	set_health(200)

func _process(delta: float) -> void:
	super(delta)
	reload = max(0, reload - delta)
	if alerted:
		shoot()

func get_type(): return Type.ELF

func on_alert():
	reload = RELOAD_SPEED

func shoot():
	if reload == 0 and Globals.player != null:
		reload = RELOAD_SPEED
		shoot_present()

func shoot_present():
	var present_projectile = present_load.instantiate()
	present_projectile.excluded_colliders.append(self)
	var projectiles: Node2D = get_node("../../Projectiles") if get_parent().get_parent().has_node("Projectiles") else get_node("../../../Projectiles")
	var distance_to_player = Globals.player.global_position.x - global_position.x
	var direction = Vector2(distance_to_player, -700 - abs(distance_to_player)).normalized()
	present_projectile.velocity = direction * 600.0
	present_projectile.global_position = global_position + direction*40
	projectiles.add_child(present_projectile)
