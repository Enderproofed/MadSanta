extends Control

var old_text = ""

func _ready() -> void:
	init()

func add_buttons_show_hide():
	$Saves/AddSave.show()
	$Saves/NewSave.hide()

func init():
	if $Saves.get_child_count() != 0:
		for child in $Saves.get_children():
			if child.name != "AddSave" and child.name != "NewSave":
				child.queue_free()
	add_buttons_show_hide()
	var saves = Save.get_global_data()["saves"]
	saves.sort()
	for save in saves:
		add_save_button(save)
	$Saves.move_child($Saves/AddSave, $Saves.get_child_count())
	$Saves.move_child($Saves/NewSave, $Saves.get_child_count())

func add_save_button(save_name: String):
	var save_button = preload("res://Scenes/save_button.tscn").instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	save_button.get_node("Button").text = save_name
	$Saves.add_child(save_button)

func _on_add_save_button_up() -> void:
	$Saves/AddSave.hide()
	$Saves/NewSave.show()
	$Saves/NewSave.grab_focus()

func _on_new_save_text_submitted(new_text: String) -> void:
	if Save.create_save(new_text):
		Globals.change_scenes(Globals.MAIN_MENU)

func _on_new_save_text_changed(new_text: String) -> void:
	if !isAlphaNumeric(new_text):
		$Saves/NewSave.text = old_text
	else:
		old_text = new_text

func isAlphaNumeric(text: String):
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z0-9, ]+$")  # Matches only alphanumeric strings
	return regex.search(text) != null
