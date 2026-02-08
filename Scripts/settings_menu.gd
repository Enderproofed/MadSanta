extends Control

@onready var ui: UI = get_parent()

func _on_back_pressed() -> void:
	ui.change_scenes(ui.settings_from)
