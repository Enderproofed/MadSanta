extends Node2D

var entered = false

func _on_entered_body_entered(body: Node2D) -> void:
	if body == Globals.player:
		if !entered: 
			entered = true
			$Animation.play("fade")

func _on_exited_body_entered(body: Node2D) -> void:
	if body == Globals.player:
		if entered: 
			entered = false
			$Animation.play_backwards("fade")
