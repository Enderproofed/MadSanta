extends Button

@export var level_scene : PackedScene
@export var level_number : int

func _ready() -> void:
	Globals.level_buttons.append(self)

func _on_pressed() -> void:
	if level_scene != null:
		Globals.change_scenes(Globals.PLAYING)
		Globals.start_level(level_scene)
