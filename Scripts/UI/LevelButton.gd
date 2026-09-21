class_name LevelButton extends Control

@export var level_number : int

func _on_pressed() -> void:
	var back_rect: Rect2 = get_node("../../Back").get_global_rect()
	var forth_rect: Rect2 = get_node("../../Forth").get_global_rect()
	var mouse_pos = get_global_mouse_position()
	if !back_rect.has_point(mouse_pos) and !forth_rect.has_point(mouse_pos):
		Globals.start_level(level_number)

func _ready() -> void:
	$Label.text = str("Level  ", level_number)
	var texture = load(str("res://Resources/Images/LevelPreview/Level", level_number, ".png"))
	if texture == null:
		texture = load("res://Resources/Images/LevelPreview/NoImageBg.png")
	$Image.texture = texture
	var level_time = Globals.times_of_levels["1"][str(level_number)]
	if level_time == null: $Time.text = "Time: -"
	else: 
		$Time.text = "Time: " + Globals.time_to_str(level_time)
		if level_time <= float(Globals.speedrun_times[0][str(level_number)]):
			$Stars/Star1.modulate = Color.WHITE
