extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_restart_pressed() -> void:
	get_parent().play_again()


func _on_main_menu_pressed() -> void:
	get_parent().change_scenes(Globals.MAIN_MENU)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_levelauswahl_pressed() -> void:
	get_parent().change_scenes(Globals.LEVEL_SELECTION)
