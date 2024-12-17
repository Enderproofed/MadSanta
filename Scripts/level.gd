extends Node2D

func _ready() -> void:
	$Animation.play("zoom_in")
	$Player/Cam.position.y = 200

func zoom_out():
	$Animation.play_backwards("zoom_in")
	$Player/Cam.position.y = 0

func _process(delta: float) -> void:
	pass
