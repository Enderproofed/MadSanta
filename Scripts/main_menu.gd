extends Control

@onready var ui: UI = get_parent()

func _on_play_pressed() -> void:
	ui.change_scenes(Globals.LEVEL_SELECTION)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_credits_pressed() -> void:
	ui.change_scenes(Globals.CREDITS)

func _on_options_pressed() -> void:
	ui.change_scenes(Globals.SETTINGS)

func _on_accounts_pressed() -> void:
	ui.change_scenes(Globals.SAVE_MENU)
