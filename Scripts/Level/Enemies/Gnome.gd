@tool
class_name Gnome
extends Enemy

const size_healths = [100, 200, 400]
const size_speeds = [150.0, 110.0, 70.0]
const size_self_stunning = [0.1, 0.3, 0.5]
const size_knockback = [400, 700, 1100]

var player_above = false
var next_random_jump = 3.0

@export_range(1,3) var size = 1

func _ready() -> void:
	editor_stuff()
	if !Engine.is_editor_hint():
		set_health(get_health())
		alerted_speed_aplifier = 1.8 * size
		if name.contains("BigBoi"):
			Texts.BIG_GNOME[0] = "Das ist " + get_enemy_name() + "..."
		knockback = get_knockback()
		stunning = get_self_stunning()
		base_speed = get_speed()
		speed = base_speed
		super()

func get_type(): return Type.GNOME

func is_boss():
	return size == 3

func get_health() -> int:
	return get_size_property("size_healths")

func get_self_stunning() -> float:
	return get_size_property("size_self_stunning")

func get_knockback() -> int:
	return get_size_property("size_knockback")

func get_speed() -> float:
	return get_size_property("size_speeds")

func get_size_property(property_name: String):
	var size_properties:Array = get(property_name)
	if size == null or size <= 0:
		return size_properties[0]
	elif size > size_properties.size():
		return size_properties[size_properties.size() - 1]
	else:
		return size_properties[size - 1]

func editor_stuff():
	$EnemyBase.scale = Vector2(size, size)
	#$EnemyBase/Healthbar.scale = Vector2(1.0/size, 1.0/size)
	$Collision.scale = Vector2(size, size)
	$Skin.scale = Vector2(1.5, 1.5) * size

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): editor_stuff()
	else:
		super(delta)
		gnome_process(delta)
		if size >= 3: big_boi_process(delta)

func gnome_process(delta: float) -> void:
	pass

func big_boi_process(delta: float) -> void:
	if not_activated() or !State.is_playing(): return
	if alerted:
		next_random_jump = max(0, next_random_jump-delta)
	if next_random_jump == 0:
		next_random_jump = randf_range(3.0, 10.0)
		jump_obstacle()
	
	if Globals.player != null:
		var distance_to_player = Globals.player.global_position - global_position
		var above = distance_to_player.y < 0
		if randf() <= 0.2 and above and !player_above: # jump together with player at a chance of 20%
			jump_obstacle()
		player_above = above
