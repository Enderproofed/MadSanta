extends Control

@onready var ui: UI = get_parent()

func _ready() -> void:
	var level_editor = ui.menus[State.to_text(State.LEVEL_EDITOR)]
	level_editor._connect_exit_menu(self)
