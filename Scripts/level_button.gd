extends Button

@export var levelScene : PackedScene

func _on_pressed() -> void:
	if levelScene != null:
		Globals.change_scenes(Globals.PLAYING)
		Globals.start_level(levelScene)
