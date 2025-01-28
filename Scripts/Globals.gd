extends Node

#State enum
const PLAYING = "PLAYING"
const TEXT = "TEXT"
const PAUSED = "PAUSED"
const MAIN_MENU = "MAIN_MENU"
const LEVEL_SELECTION = "LEVEL_SELECTION"
const CREDITS = "CREDITS"
const FINISH_MENU = "FINISH_MENU"
const COLLECT_SCREEN = "COLLECT_SCREEN"

enum CHEST_ITEMS { SNOWBALL, ICICLE }

#Debug 
const debug_mode = false
const skip_intro_text = false

#Global constants
const levels = [preload("res://Scenes/level_1.tscn"), preload("res://Scenes/level_2.tscn")]

#Global variables
var fullscreen = false
var state = MAIN_MENU
var player: RigidBody2D = null
var level: Node2D = null
var level_buttons = []
var current_level = 1
var enemies_in_level = 0
var enemies_killed = 0

#Savable data
var unlocked_level = 1
var collected_items = []
var selected_weapon = null

@onready var collect_screen = get_node("/root/Main/UI/CollectScreen")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ESC"):
		get_tree().quit()
	if Input.is_action_just_pressed("F11"):
		fullscreen = !fullscreen
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)

func isPaused() -> bool:
	return state != PLAYING

func update_level_buttons():
	for level_button in level_buttons:
		level_button.disabled = unlocked_level < level_button.level_number or level_button.level_number > levels.size()

func timer(seconds: float):
	return get_tree().create_timer(seconds).timeout

func start_level(level_scene: PackedScene):
	get_node("/root/Main/UI").start_level(level_scene)

func change_scenes(scene: String):
	get_node("/root/Main/UI").change_scenes(scene)

func finish_level():
	if current_level == unlocked_level:
		unlocked_level += 1
		#save data
	get_node("/root/Main/UI").finish_level()

func collect_item(item: CHEST_ITEMS):
	collected_items.append(item)
	player.set_weapon(item)
	Globals.selected_weapon = item
