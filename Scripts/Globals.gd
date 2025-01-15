extends Node

const PLAYING = "PLAYING"
const PAUSED = "PAUSED"
const MAIN_MENU = "MAIN_MENU"
const LEVEL_MENU = "LEVEL_MENU"

var fullscreen = false
var state = MAIN_MENU

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ESC"):
		get_tree().quit()
	if Input.is_action_just_pressed("F11"):
		fullscreen = !fullscreen
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)

	

func timer(seconds: float):
	return get_tree().create_timer(seconds).timeout
