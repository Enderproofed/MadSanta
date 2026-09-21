extends Control

@onready var ui: UI = get_parent()

func _ready() -> void:
	if !Globals.playing_custom_level: $Container/ResumeBuilding.hide()

func _on_resume_pressed() -> void:
	Globals.set_paused(false)
	ui.back()

func _on_resume_building_pressed() -> void:
	Globals.set_paused(false)
	ui.change_scenes(State.LEVEL_EDITOR)

func _on_restart_pressed() -> void:
	Globals.set_paused(false)
	ui.play_again()

func _on_options_pressed() -> void:
	ui.change_scenes(State.SETTINGS)

func _on_exit_level_pressed() -> void:
	Globals.set_paused(false)
	ui.change_scenes(State.MAIN_MENU) 

func _on_quit_game_pressed() -> void:
	get_tree().quit()
