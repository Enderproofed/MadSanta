extends Node2D

var pressed = false

@export var door: Door

func _on_body_entered(body: Node2D) -> void:
	if !pressed:
		$Animation.play("press")
		pressed = true
		door.open()
