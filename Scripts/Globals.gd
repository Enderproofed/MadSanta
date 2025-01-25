extends Node

#State enum
const PLAYING = "PLAYING"
const PAUSED = "PAUSED"
const MAIN_MENU = "MAIN_MENU"
const LEVEL_SELECTION = "LEVEL_SELECTION"
const CREDITS = "CREDITS"

#Debug 
const debug_mode = false
const skip_intro_text = false

#Global variables
var fullscreen = false
var state = MAIN_MENU
var player: RigidBody2D
var level
var level_buttons = []

#Savable data
var unlocked_level = 1

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ESC"):
		get_tree().quit()
	if Input.is_action_just_pressed("F11"):
		fullscreen = !fullscreen
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	

func update_level_buttons():
	for level_button in level_buttons:
		level_button.disabled = unlocked_level < level_button.level_number

func timer(seconds: float):
	return get_tree().create_timer(seconds).timeout

func start_level(level_scene: PackedScene):
	get_node("/root/Main/UI").start_level(level_scene)

func change_scenes(scene: String):
	get_node("/root/Main/UI").change_scenes(scene)
