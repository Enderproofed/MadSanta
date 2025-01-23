extends Control

func _on_play_pressed() -> void:
	get_parent().change_scenes(Globals.LEVEL_MENU)
