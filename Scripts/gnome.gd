@tool
class_name Gnome
extends Enemy

@export_range(1,3) var size = 1

func _ready() -> void:
	editor_stuff()
	if !Engine.is_editor_hint():
		set_health(get_health())
		alerted_speed_aplifier = 1.8 * size
		if name.contains("BigBoi"):
			Texts.BIG_GNOME[0] = "Das ist " + get_enemy_name() + "..."
		$EnemyBase/HitBoxEnemy.knockback = get_knockback()
		stunning = get_self_stunning()

func get_health() -> int:
	match size:
		1: return 100
		2: return 200
		3: return 400
	return 100

func get_self_stunning() -> float:
	match size:
		1: return 0.1
		2: return 0.3
		3: return 0.5
	return 0.1

func get_knockback() -> int:
	match size:
		1: return 700
		2: return 900
		3: return 1100
	return 100

func editor_stuff():
	$EnemyBase.scale = Vector2(size, size)
	$collision.scale = Vector2(size, size)
	$skin/skin.scale = Vector2(size, size)
	$left.position.x = size * -12
	$right.position.x = size * 12

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): editor_stuff()
	else: super._process(delta)
