@tool
class_name LevelBase extends Node2D

@export var finish_position: int
@export var has_border_sets: bool
@export var night: bool
@export var border_bottom: int
@export var border_top: int
@export var border_right: int
@export var border_left: int
@export var indoor = false
@export var on_moon = false

func _ready() -> void:
	if !Engine.is_editor_hint():
		$BorderRect.hide()
		init()

func init():
	$Background.night = night
	$Background.moon_visible = night and !on_moon
	$Background.indoor = indoor
	$Background.on_moon = on_moon
	$Finish.position.x = finish_position
	$BorderRect.global_position = Vector2(get_left(), get_top())
	$BorderRect.size = Vector2(get_right() - get_left(), get_bottom() - get_top())
	$LevelBorder.global_position.x = get_left()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		init()

func get_right() -> int:
	return finish_position if not has_border_sets else border_right

func get_left() -> int:
	return border_left

func get_bottom() -> int:
	return border_bottom

func get_top() -> int:
	return border_top
