extends Control

@onready var ui: UI = get_parent()

@export var edit_button: Button
@export var my_levels_button: Button
@export var level_selection_button: Button

func _ready() -> void:
	var editing_own_level = Globals.current_custom_level != null
	edit_button.visible = editing_own_level
	my_levels_button.visible = editing_own_level
	level_selection_button.visible = !editing_own_level


func _on_restart_pressed() -> void:
	ui.play_again()

func _on_main_menu_pressed() -> void:
	ui.change_scenes(State.MAIN_MENU)

func _on_quit_pressed() -> void:
	ui.quit()

func _on_levelauswahl_pressed() -> void:
	ui.change_scenes(State.LEVEL_SELECTION)

func _on_edit_pressed() -> void:
	ui.change_scenes(State.LEVEL_EDITOR)

func _on_my_levels_pressed() -> void:
	ui.change_scenes(State.CREATE_LEVEL_MENU)
