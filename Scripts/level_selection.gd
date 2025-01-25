extends Control

func _on_back_pressed() -> void:
	get_parent().change_scenes(Globals.MAIN_MENU)
