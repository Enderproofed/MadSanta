extends Node2D

@export var level_number: int

func _ready() -> void:
	$Player/Cam.position.y = 60
	$Player/Cam.limit_left = $LevelBase.border_left
	$Player/Cam.limit_top = $LevelBase.border_top
	$Player/Cam.limit_right = $LevelBase.finish_position
	$Player/Cam.limit_bottom = $LevelBase.border_bottom

func zoom_out():
	$Animation.play("zoom_out")
	$Player/Cam.position.y = 0

func get_bottom():
	return $LevelBase.get_bottom()
	
