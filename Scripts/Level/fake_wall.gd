extends Node2D

var entered = false

func _on_visible_area_body_entered(body: Node2D) -> void:
	if body == Globals.player:
		if !entered: 
			entered = true
			$Animation.play("fade")

func _on_visible_area_body_exited(body: Node2D) -> void:
	if body == Globals.player:
		if entered: 
			entered = false
			$Animation.play_backwards("fade")
