extends Control



func _on_play_pressed() -> void:
	var level = preload("res://Scenes/level_1.tscn").instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	get_node("../../").add_child(level)
	hide()
	var intro_text = [
		"Du bist ein Schneemann und deine Schneefrau wurde brutal von\n
		Schrergen des wild gewordenen Weihnachtsmannes getötet.",
		"Deine Mission ist es den Weihnachtsmann und seine fiesen\n
		Machenschaften zu stoppen und dich an ihm zu rächen.",
		"Doch sei gewarnt. Er hat bereits seine Schergen auf dich\n
		angesetzt. Sei also auf der hut!"
		]
	get_parent().start_text_sequence(intro_text)

func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()
