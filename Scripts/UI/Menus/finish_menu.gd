extends Control

@export var edit_button: Button
@export var my_levels_button: Button
@export var level_selection_button: Button
@export var next_level_button: Button
@export var enemies_killed: Label

@onready var ui: UI = get_parent()

func _ready() -> void:
	next_level_button.visible = Globals.levels.size() > Globals.current_level
	enemies_killed.text = str(Globals.enemies_killed, " / ", Globals.enemies_in_level)
	var editing_own_level = Globals.current_custom_level != null
	edit_button.visible = editing_own_level
	my_levels_button.visible = editing_own_level
	level_selection_button.visible = !editing_own_level

func _on_play_again_pressed() -> void:
	ui.play_again()

func _on_level_selection_pressed() -> void:
	ui.change_scenes(State.LEVEL_SELECTION)

func _on_next_level_pressed() -> void:
	ui.next_level()

func _on_my_levels_pressed() -> void:
	ui.change_scenes(State.CREATE_LEVEL_MENU)

func _on_edit_pressed() -> void:
	ui.change_scenes(State.LEVEL_EDITOR)
