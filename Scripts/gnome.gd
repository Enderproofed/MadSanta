@tool
class_name Gnome
extends Enemy

@export_range(1,3) var size = 1

func _ready() -> void:
	editor_stuff()
	if !Engine.is_editor_hint():
		set_health(get_health())
		alerted_speed_aplifier = 1.8 * size

func get_health() -> int:
	match size:
		1: return 100
		2: return 200
		3: return 400
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
