extends Control

func _on_play_again_pressed() -> void:
	get_parent().play_again()

func _on_level_selection_pressed() -> void:
	get_parent().change_scenes(Globals.LEVEL_SELECTION)

func _on_next_level_pressed() -> void:
	get_parent().next_level()
