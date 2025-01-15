extends Control

func _process(delta: float) -> void:
	if Globals.MAIN_MENU:
		$Background/SildeCam.position.x += 1

func _on_play_pressed() -> void:
	var level = preload("res://Scenes/level_1.tscn").instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	get_node("../../").add_child(level)
	hide()
	$Background/SildeCam.enabled = false
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
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()

func credits() -> void:
	pass

func new_game() -> void:
	pass
