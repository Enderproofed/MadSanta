extends Control

var old_text = ""

@onready var save_button_load = load("uid://lq6302o3juwu")

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
	var save_button = save_button_load.instantiate()
	save_button.get_node("Button").text = save_name
	$Saves.add_child(save_button)

func _on_add_save_button_up() -> void:
	$Saves/AddSave.hide()
	$Saves/NewSave.show()
	$Saves/NewSave.grab_focus()

func _on_new_save_text_submitted(new_text: String) -> void:
	if !new_text.is_empty() and Save.create_save(new_text):
		Globals.change_scenes(State.MAIN_MENU)

func _on_new_save_text_changed(new_text: String) -> void:
	var text_trimmed = ""
	for i in range(new_text.length()):
		var character = new_text[i]
		if character != " ": 
			text_trimmed += character
	if !isAlphaNumeric(text_trimmed):
		var tmp_caret_column = $Saves/NewSave.caret_column
		$Saves/NewSave.text = old_text
		$Saves/NewSave.caret_column = tmp_caret_column-1
		
	else:
		old_text = new_text

func isAlphaNumeric(text: String) -> bool:
	if text.is_empty(): return true
	return text.is_valid_filename()
	#var regex = RegEx.new()
	#regex.compile("^[a-zA-Z0-9, ]+$")  # Matches only alphanumeric strings
	#return regex.search(text) != null
