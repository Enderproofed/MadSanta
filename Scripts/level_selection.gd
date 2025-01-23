extends Control

func _ready() -> void:
	#$MarginContainer/VBoxContainer/Level2.disabled = true
	$MarginContainer/VBoxContainer/Level3.disabled = true
	$MarginContainer/VBoxContainer/Level4.disabled = true

func _process(delta: float) -> void:
	pass

func _on_back_pressed() -> void:
	get_node("../").change_scenes(Globals.MAIN_MENU)


func _on_pressed() -> void:
	pass # Replace with function body.
