extends Node2D

@export var level_number: int

func _ready() -> void:
	$Player/Cam.position.y = 60
	$Player/Cam.limit_left = $Positions/LevelBorder.position.x
	$Player/Cam.limit_bottom = $Positions/LevelBorder.position.y
	$Player/Cam.limit_right = $Positions/LevelBorder2.position.x
	$Player/Cam.limit_top = $Positions/LevelBorder2.position.y
	

func zoom_out():
	$Animation.play("zoom_out")
	$Player/Cam.position.y = 0

func _process(delta: float) -> void:
	pass
