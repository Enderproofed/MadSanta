extends Node

#Debug 
const debug_mode = true
const skip_intro_text = false
const start_with_all_items = false

#State "enum"
const PLAYING = "PLAYING"
const TEXT = "TEXT"
const PAUSED = "PAUSED"
const PAUSED_IN_GAME = "PAUSED_IN_GAME"
const SETTINGS = "SETTINGS"
const SETTINGS_PAUSE = "SETTINGS_PAUSE"
const SETTINGS_PLAYING = "SETTINGS_PLAYING"
const MAIN_MENU = "MAIN_MENU"
const SAVE_MENU = "SAVE_MENU"
const LEVEL_SELECTION = "LEVEL_SELECTION"
const CREDITS = "CREDITS"
const FINISH_MENU = "FINISH_MENU"
const COLLECT_SCREEN = "COLLECT_SCREEN"
const DEATH_SCREEN = "DEATH_SCREEN"
const UPGRADES = "UPGRADES"

# Callable "enum"
const LOAD = "load"
const HEALTH = "health"
const LVL_RESET = "level_reset"
const COLLECTED = "collected"
const ITEM_COLLECTED = "item_collected"
const UPGRADE_BOUGHT = "upgrade_bought"

enum CHEST_ITEMS { 
	SNOWBALL, #0
	ICICLE, #1
	LASER,
	#A, #1
	#B, #2
	#C, #3
}

enum COLLECT {
	COIN,
	SNOWFLAKE
}

enum UPGRADE {
	STRENGTH,
	RELOAD,
	SPEED,
	SIZE,
	SPREAD
}

const item_type_name_map: Dictionary = {
	CHEST_ITEMS.SNOWBALL: "Schneeball",
	CHEST_ITEMS.ICICLE : "Eiszapfen",
	CHEST_ITEMS.LASER : "Super Eis-Strahl"
}

const collectable_map: Dictionary = {
	COLLECT.COIN: "coins",
	COLLECT.SNOWFLAKE: "snowflakes"
}

const upgrade_name_map: Dictionary = {
	UPGRADE.STRENGTH: STRENGTH,
	UPGRADE.RELOAD: RELOAD,
	UPGRADE.SPEED: SPEED,
	UPGRADE.SIZE: SIZE,
	UPGRADE.SPREAD: SPREAD
}

const upgrade_costs_map: Dictionary = {
	UPGRADE.STRENGTH: COLLECT.SNOWFLAKE,
	UPGRADE.RELOAD: COLLECT.COIN,
	UPGRADE.SPEED: COLLECT.COIN,
	UPGRADE.SIZE: COLLECT.SNOWFLAKE,
	UPGRADE.SPREAD: COLLECT.SNOWFLAKE
}

const collectables_gone_after_completion = [COLLECT.SNOWFLAKE]

#Global constants
var levels = [load("res://Scenes/level_1.tscn"), load("res://Scenes/level_mirko.tscn"), load("res://Scenes/level_nico.tscn")]

#Global Strings
const MASTER = "Master"
const MUSIC = "Music"
const EFFECTS = "Effects"
#Upgrade Names
const STRENGTH = "strength"
const RELOAD = "reload"
const SPEED = "speed"
const SIZE = "size"
const SPREAD = "spread"

#Global variables
var loading_data = false
var fullscreen = false
var state = SAVE_MENU
var player: RigidBody2D = null
var level: Level = null
var level_buttons = []
var current_level = 1
var enemies_in_level = 0
var enemies_killed = 0
var listeners: Dictionary = {
	LOAD: [],
	HEALTH: [],
	LVL_RESET: [],
	COLLECTED: [],
	ITEM_COLLECTED: [],
	UPGRADE_BOUGHT: []
}

var tmp_dictionary = {}
var tmp_data = [
	"collected_items", "selected_weapon", "coins", "snowflakes", "total_coins", "total_snowflakes",
	"collected_collectables_per_level", "upgrades"
]

#Savable data
var unlocked_level: int = 1
var collected_items: Array[CHEST_ITEMS] = []
var selected_weapon = null
var level1_played = false
var triggered_texts = []
var triggered_buttons = {}
var coins: int = 0
var snowflakes: int = 0
var total_coins: int = 0
var total_snowflakes: int = 0
var audio: Dictionary = {
	MASTER: {
		"mute": false,
		"value": -2.9
	},
	MUSIC: {
		"mute": false,
		"value": -2.9
	},
	EFFECTS: {
		"mute": false,
		"value": -2.9
	}
}
var collected_collectables_per_level = {
	COLLECT.SNOWFLAKE: {
		1: []
	}
}:
	set(value):
		collected_collectables_per_level = value
var upgrades: Dictionary = {
	CHEST_ITEMS.SNOWBALL: {
		STRENGTH: 1,
		SPEED: 1,
		SIZE: 1,
		RELOAD: 1
	},
	CHEST_ITEMS.ICICLE: {
		STRENGTH: 1,
		SPEED: 1,
		SIZE: 1,
		RELOAD: 1
	}, CHEST_ITEMS.LASER: {
		STRENGTH: 1,
		SPREAD: 1
	}
}

const saved_variables = ["unlocked_level", "collected_items", "selected_weapon", "level1_played",
	"triggered_texts", "triggered_buttons", "coins", "snowflakes","total_coins", "total_snowflakes",
	"audio", "collected_collectables_per_level", "upgrades"
]
const nullable_variables = ["selected_weapon"]

@onready var collect_screen = get_node("/root/Main/Overlay/UI/CollectScreen")
@onready var ui: UI = get_node("/root/Main/Overlay/UI")
@onready var weapon_selection: WeaponSelection = get_node("/root/Main/Overlay/UI/WeaponSelection")
@onready var world_screen: CanvasLayer = get_node("/root/Main/WorldLayer")

var shaking = false
var shake_fade_out = 0

const shake_frequency = 0.06
const shake_intensity = 6
var shake_timer = 0
var shake_next_pos = Vector2.ZERO

func _ready() -> void:
	for tmp in tmp_data:
		var field = get(tmp)
		tmp_dictionary.get_or_add("tmp_" + tmp, field)
	process_mode = PROCESS_MODE_ALWAYS

func load_data(data: Dictionary):
	loading_data = true
	for variable:String in saved_variables:
		var value = data.get(variable)
		if value == null and variable not in nullable_variables:
			value = Save.base_data[variable]
			print("No value for variable '", variable, "' found. Using base data instead. Base data: '", value, "'")
		print(variable, ": ", value)
		if variable == "triggered_buttons":
			triggered_buttons = {}
			for level_number in value.keys():
				triggered_buttons.get_or_add(int(level_number), value[level_number])
		elif variable == "collected_collectables_per_level":
			collected_collectables_per_level = {}
			for collectable in value.keys():
				var collected_in_level = {}
				for level_number in value[collectable].keys():
					collected_in_level.get_or_add(int(level_number), value[collectable][level_number])
				collected_collectables_per_level.get_or_add(id_to_item(collectable), collected_in_level)
		elif variable == "upgrades":
			for type_to_upgrade in value.keys():
				var item_type = id_to_item(type_to_upgrade)
				for upgrade_type in value[type_to_upgrade].keys():
					upgrades[item_type][upgrade_type] = value[type_to_upgrade][upgrade_type]
		elif variable == "collected_items":
			collected_items = []
			for item in value:
				collected_items.append(id_to_item(item))
			collected_items.sort()
		elif variable == "selected_weapon":
			selected_weapon = id_to_item(value)
		else:
			if value == null and get(variable) is int: continue
			set(variable, value) 
	
	if start_with_all_items:
		for chest_item in CHEST_ITEMS.values():
			collect_item(chest_item)
	else:
		if not selected_weapon in collected_items: selected_weapon = null
	
	#TODO remove - only current workaround:
	total_coins = max(coins, total_coins)
	total_snowflakes = max(snowflakes, total_snowflakes)
	
	call_action(LOAD)
	loading_data = false
	
	ui.get_node("Background").night = unlocked_level == 2
	
	if !collected_collectables_per_level[Globals.COLLECT.SNOWFLAKE].has(unlocked_level):
		add_next_collectable_storage()
	add_buttons_to_trigger()

func next_level_unlocked():
	unlocked_level += 1
	add_next_collectable_storage()
	add_buttons_to_trigger()

func add_next_collectable_storage():
	for collectable_type in collected_collectables_per_level.keys():
		collected_collectables_per_level[collectable_type].get_or_add(unlocked_level, [])

func add_buttons_to_trigger():
	for i in range(unlocked_level):
		var lvl_id = i+1
		if !triggered_buttons.keys().has(lvl_id):
			triggered_buttons.get_or_add(lvl_id, [])

func shake_effect():
	shaking = true
	shake_fade_out = 10

func stop_shake_effect():
	shaking = false
	shake_fade_out = 0.7

func buy_upgrade(item: CHEST_ITEMS, upgrade: UPGRADE):
	upgrades[item][get_upgrade_name(upgrade)] += 1
	call_action(UPGRADE_BOUGHT, item, upgrade)
	play_sound("res://Resources/Sounds/upgrade.wav", EFFECTS)

func upgrade_costs(upgrade: UPGRADE):
	return upgrade_costs_map[upgrade]

func upgrade_cost(item: CHEST_ITEMS, upgrade: UPGRADE) -> int:
	var costs: COLLECT = upgrade_costs(upgrade)
	match costs:
		COLLECT.SNOWFLAKE:
			var current_upgrade = upgrades[item][get_upgrade_name(upgrade)]
			var cost = 1
			for i in range(current_upgrade):
				if i >= 2: cost -= 1 # so that it doesn't jump from 2 to 4, result: 1, 2, 3, 5, 8, 12, 17, 23...
				cost += i
			return cost
		COLLECT.COIN:
			var current_upgrade = upgrades[item][get_upgrade_name(upgrade)]
			var cost = 10
			for i in range(current_upgrade):
				if i >= 2: cost -= 5 # so that it doesn't jump from 15 to 25, result: 10, 15, 20, 30, 45, 65, 90, 120...
				cost += i*5
			return cost
	print("Unknown cost ", costs)
	return 9999

func collect(collectable_type: COLLECT, amount: int):
	var collectable_name = collectable_map[collectable_type]
	set(collectable_name, get(collectable_name) + amount)
	set("total_" + collectable_name, get("total_" + collectable_name) + amount)
	call_action(COLLECTED, collectable_type)

func get_item_type_name(chest_item: CHEST_ITEMS) -> String:
	return item_type_name_map.get(chest_item, "Unbekannt :(")

func get_upgrade_name(upgrade: UPGRADE) -> String:
	return upgrade_name_map.get(upgrade, "Unbekannt :(")

func is_collected(chest_item: CHEST_ITEMS) -> bool:
	return chest_item in collected_items

func is_collectable_gone_after_completion(collectable_type: COLLECT) -> bool:
	return collectable_type in collectables_gone_after_completion

func is_collectable_gone(collectable_type: COLLECT, level_number: int, id: int) -> bool:
	if not is_collectable_gone_after_completion(collectable_type): return false
	var collected_in_level = collected_collectables_per_level[collectable_type][level_number]
	for collected in collected_in_level:
		if int(collected) == id: return true
	return false

func set_button_triggered(level_number: int, id: int):
	if !is_button_triggered(level_number, id): triggered_buttons[level_number].append(id)

func is_button_triggered(level_number: int, id: int):
	return triggered_buttons[level_number].has(id)

func collect_gone(collectable_type: COLLECT, level_number: int, id: int):
	if is_collectable_gone_after_completion(collectable_type):
		if level_number == -1:
			print("level number not initialized correctly for ", collectable_map[collectable_type], " with id ", id, ". Using Globals' current level")
			level_number = current_level
		var gone_in_level = collected_collectables_per_level[collectable_type][level_number]
		if id not in gone_in_level:
			gone_in_level.append(id)

func add_listener(container: String, listener: Callable):
	listeners[container].append(listener)
func add_listeners(containers, listeners):
	if containers is String and listeners is Callable:
		print("Single listener bound to '", containers, "'. Please use normal #add_listener for that!")
		add_listener(containers, listeners)
	elif containers is Array and listeners is Callable:
		for container in containers:
			add_listener(container, listeners)
	elif containers is String and listeners is Array:
		for listener in listeners:
			add_listener(containers, listener)
	elif containers is Array and listeners is Array:
		for container in containers:
			for listener in listeners:
				add_listener(container, listener)
	else: print("Could not resolve listeners to add. Containers: '", containers, "', Listeners: '", listeners, "'")

func call_action(container: String, arg1 = null, arg2 = null, arg3 = null):
	var for_removal = []
	for action: Callable in listeners[container]:
		if action == null or action.get_object() == null:
			for_removal.append(action)
		else: 
			match action.get_argument_count():
				0: action.call()
				1: action.call(arg1)
				2: action.call(arg1, arg2)
				3: action.call(arg1, arg2, arg3)
	for action in for_removal: # discarding those later prevents concurrent modification
		listeners[container].erase(action)

func get_data_to_save():
	var result: Dictionary = {}
	for variable in saved_variables:
		var value = get(variable)
		result.get_or_add(variable, value)
	return result

func _process(delta: float) -> void:
	#todo remove this:
	#if Input.is_action_just_pressed("ui_down"):
		#shake_effect()
	#if Input.is_action_just_released("ui_down"):
		#stop_shake_effect()
	
	if !isPaused():
		if Input.is_action_just_pressed("pause"):
			change_scenes(Globals.PAUSED)
		if Input.is_action_just_pressed("U"):
			change_scenes(Globals.UPGRADES)
	if Input.is_action_just_pressed("ESC"):
		ui.back()
	if Input.is_action_just_pressed("F11"):
		fullscreen = !fullscreen
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	
	if Input.is_action_just_pressed("1"): weapon_selection.set_index(0)
	if Input.is_action_just_pressed("2"): weapon_selection.set_index(1)
	if Input.is_action_just_pressed("3"): weapon_selection.set_index(2)
	
	
	shake_fade_out = max(0, shake_fade_out-delta)
	if shaking and shake_fade_out == 0:
		stop_shake_effect()
	if !shaking and shake_fade_out != 0:
		world_screen.offset = lerp(world_screen.offset, Vector2.ZERO, 0.02)
	
	if shaking:
		shake_timer -= delta
		if shake_timer <= 0:
			shake_timer = shake_frequency
			shake_next_pos = Vector2(randi_range(-shake_intensity, shake_intensity), randi_range(-shake_intensity, shake_intensity))
		world_screen.offset = lerp(world_screen.offset, shake_next_pos, 0.2)

func offset_camera(offset: Vector2):
	player.get_node("Cam").position = offset

func offset_camera_global(global_offset: Vector2):
	player.get_node("Cam").position = global_offset - player.global_position

func reset_camera():
	player.get_node("Cam").position = Vector2.ZERO

func item_to_id(item: CHEST_ITEMS) -> int:
	return item
	#if item == CHEST_ITEMS.SNOWBALL: return 0
	#elif item == CHEST_ITEMS.ICICLE: return 1
	#else:
		#print("Item/Waffe ", item, " konnte nicht gefunden werden!!!")
		#return -1

func id_to_item(id):
	if id is CHEST_ITEMS or id == null: return id
	id = int(id)
	if id == 0: return CHEST_ITEMS.SNOWBALL
	elif id == 1: return CHEST_ITEMS.ICICLE
	elif id == 2: return CHEST_ITEMS.LASER
	else:
		print("ID ", id, " gehört keinem Item!!!")
		return null

# ---------- State ---------- #
func isPaused(state_to_check = state) -> bool:
	return state_to_check != PLAYING
func isInMenu(state_to_check = state) -> bool:
	return state_to_check in [MAIN_MENU, LEVEL_SELECTION, SAVE_MENU, CREDITS] or isSettings(state_to_check)
func isSettings(state_to_check = state) -> bool:
	return state_to_check in [SETTINGS, SETTINGS_PAUSE, SETTINGS_PLAYING]

func update_level_buttons():
	for level_button in level_buttons:
		level_button.disabled = unlocked_level < level_button.level_number or level_button.level_number > levels.size()

func timer(seconds: float):
	return get_tree().create_timer(seconds).timeout

func start_level(level_scene: PackedScene):
	ui.start_level(level_scene)

func change_scenes(scene: String):
	ui.change_scenes(scene)

func finish_level():
	if current_level == unlocked_level:
		next_level_unlocked()
	Globals.store_on_complete_data()
	Save.save_data()

func delete_level():
	ui.delete_level()

func collect_item(item: CHEST_ITEMS):
	collected_items.append(item)
	collected_items.sort()
	selected_weapon = item
	call_action(ITEM_COLLECTED, item)
	if item == CHEST_ITEMS.LASER:
		ui.get_node("LevelOverlay/LaserBar").visible = true

func playerDied():
	if state != FINISH_MENU:
		ui.change_scenes(DEATH_SCREEN)

func store_on_complete_data():
	for field_name in tmp_data:
		var field = get(field_name)
		if field is Array or field is Dictionary:
			tmp_dictionary["tmp_" + field_name] = field.duplicate(true)
		else: tmp_dictionary["tmp_" + field_name] = field

func revert_stored_on_complete_data():
	for field in tmp_data:
		if get(field) is Array:
			set(field, tmp_dictionary["tmp_" + field].duplicate(true))
		else: set(field, tmp_dictionary["tmp_" + field])
	call_action(LVL_RESET)

func play_sound(path_to_sound: String, bus: String = "Master", volume: int = 0):
	var sound: AudioStreamWAV = load(path_to_sound)
	var sound_player: AudioStreamPlayer = AudioStreamPlayer.new()
	sound_player.stream = sound
	sound_player.bus = bus
	sound_player.volume_db = volume
	ui.add_child(sound_player)
	sound_player.play()
	await Globals.timer(sound.get_length())
	sound_player.queue_free()
