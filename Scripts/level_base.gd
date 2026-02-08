@tool
class_name LevelBase extends Node2D

@export var finish_position: int
@export var has_border_sets: bool
@export var night: bool
@export var border_bottom: int
@export var border_top: int
@export var border_right: int
@export var border_left: int

func _ready() -> void:
	if !Engine.is_editor_hint():
		$BorderRect.hide()
		init()
		$Background.night_switch()

func init():
	$Background.night = night
	$Finish.position.x = finish_position
	$BorderRect.global_position = Vector2(get_left(), get_top())
	$BorderRect.size = Vector2(get_right() - border_left, get_bottom() - border_top)

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
