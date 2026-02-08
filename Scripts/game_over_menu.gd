extends Control


func _on_restart_pressed() -> void:
	get_parent().play_again()


func _on_main_menu_pressed() -> void:
	get_parent().change_scenes(Globals.MAIN_MENU)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_levelauswahl_pressed() -> void:
	get_parent().change_scenes(Globals.LEVEL_SELECTION)
