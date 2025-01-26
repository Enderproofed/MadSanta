extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body == Globals.player:
		Globals.change_scenes(Globals.FINISH_MENU)
