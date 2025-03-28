@tool
extends Node2D

@export var finish_position: int
@export var night: bool
@export var border_bottom: int
@export var border_top: int
@export var border_left: int

func _ready() -> void:
	if !Engine.is_editor_hint():
		$BorderRect.hide()

func _process(delta: float) -> void:
	$Finish.position.x = finish_position
	$BackgroundNight.visible = night
	$Background.visible = !night
	$BorderRect.position.y = border_top
	$BorderRect.position.x = border_left
	$BorderRect.size.x = get_right()
	$BorderRect.size.y = get_bottom()

func get_right() -> int:
	return finish_position - border_left
	
func get_bottom() -> int:
	return border_bottom - border_top
