@tool
extends Node2D

const collectable_type = Globals.COLLECT.SNOWFLAKE
@export var id = 1
@export var speed = 1.0
@export var init_progress_ratio = 0.0

@export var curve: Curve2D:
	set(value):
		$Path2D.curve = value
		curve = value

var level_number = -1:
	set(value):
		level_number = value
		if Globals.is_collectable_gone(collectable_type, level_number, id):
			queue_free()
		else: $Path2D/PathFollow2D/Snowflake.level_number = level_number

func _ready() -> void:
	if Engine.is_editor_hint():
		if get_parent() != null:
			for sibling in get_parent().get_children():
				if sibling.collectable_type == collectable_type and sibling.id == id and sibling != self:
					id += 1
			$Path2D/PathFollow2D/Snowflake.id = id
	else: 
		$Path2D/PathFollow2D/Snowflake.id = id
		if level_number != -1: $Path2D/PathFollow2D/Snowflake.level_number = level_number
	$Path2D/PathFollow2D.progress_ratio = init_progress_ratio if init_progress_ratio != null else 0.0

func _process(delta: float) -> void:
	$Path2D/PathFollow2D.progress += speed
