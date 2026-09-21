extends Button

func _ready() -> void:
	show_button()
	
	get_parent().size.x = get_parent().get_parent().size.x
	#$"../RenameSave".size.x = size.x
	#$"../Edit".size = Vector2(size.y, size.y)
	#$"../Edit".position.x = size.x + 8
	#$"../Delete".size = Vector2(size.y, size.y)
	#$"../Delete".position.x = size.x + 16 + size.y
	

func show_button():
	visible = true
	$"../RenameSave".visible = false
func show_line_edit():
	visible = false
	$"../RenameSave".visible = true

func _on_button_up() -> void:
	Save.set_save_file(text)
	Globals.change_scenes(State.MAIN_MENU)

func _on_edit_button_up() -> void:
	show_line_edit()
	$"../RenameSave".text = text
	$"../RenameSave".grab_focus()

func _on_delete_button_up() -> void:
	if Save.delete_save(text):
		get_parent().queue_free()

func _on_rename_save_text_submitted(new_text: String) -> void:
	if Save.rename_save(text, new_text):
		text = new_text
		get_parent().get_parent().get_parent().init()
		await get_tree().process_frame
		grab_focus()
	else:
		$RenameSave.modulate = Color(1, 0.5, 0.5)
	show_button()
