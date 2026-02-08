extends Node

func _on_resume_pressed() -> void:
	get_tree().paused = false
	get_parent().change_scenes(Globals.PLAYING)

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_parent().play_again()


func _on_options_pressed() -> void:
	get_parent().change_scenes(Globals.SETTINGS_PAUSE)

func _on_exit_level_pressed() -> void:
	get_tree().paused = false
	get_parent().change_scenes(Globals.MAIN_MENU) 


func _on_quit_game_pressed() -> void:
	get_tree().quit()
