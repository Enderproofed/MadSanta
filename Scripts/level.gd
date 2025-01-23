extends Node2D

func _ready() -> void:
	$Player/Cam.position.y = 60
	$Player/Cam.limit_left = $LevelBorder.position.x
	$Player/Cam.limit_bottom = $LevelBorder.position.y

func zoom_out():
	$Animation.play("zoom_out")
	$Player/Cam.position.y = 0

func _process(delta: float) -> void:
	pass
