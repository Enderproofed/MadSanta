extends Control

func _on_play_pressed() -> void:
	get_parent().change_scenes(Globals.LEVEL_SELECTION)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_credits_pressed() -> void:
	get_parent().change_scenes(Globals.CREDITS)

func _on_options_pressed() -> void:
	get_parent().change_scenes(Globals.SETTINGS)
