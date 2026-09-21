extends Node

#Debug 
var debug_mode = false
const skip_intro_text = false
const start_with_all_items = false
const sandbox_test = false
const funny_mode = true

# Callable "enum"
const LOAD = "load"
const HEALTH = "health"
const LVL_RESET = "level_reset"
const COLLECTED = "collected"
const ITEM_COLLECTED = "item_collected"
const UPGRADE_BOUGHT = "upgrade_bought"
const STATE_CHANGED = "state_changed"
const UPGRADES_RESET = "upgrades_reset"
const PLAYER_DIED = "player_died"

#Global constants
const collectables_gone_after_completion = [E.COLLECT.SNOWFLAKE]
const base_gravity = -9.8 * 3
const levels_per_world = [3]
const speedrun_times = [
	{"0": 0.0, "1": 65.0, "2": 50.0, "3": 10.0} # World 1
]

var levels = [level_scene("level_1"), level_scene("level_mirko"), level_scene("level_2")]
func level_scene(level_name: String) -> Resource:
	var level = load(str("res://Scenes/Levels/", level_name, ".tscn"))
	if level == null: 
		printerr("Level '", level_name, "' was not found. Falling back to level 1")
		level = load("res://Scenes/Levels/level_1.tscn")
	return level


#Global Strings
const MASTER = "Master"
const MUSIC = "Music"
const EFFECTS = "Effects"

#Global variables
var loading_data = false
var fullscreen = false
var just_collected_item = null
var queued_cam_offset: Node2D = null
var is_camera_offset = false
var player: Player = null
var player_cam: Camera2D = null
var level: Level = null
var active_minigame: Node2D = null
var current_level = 1
var current_world = 1 # not changing currently. Effectively a const
var enemies_in_level = 0
var enemies_killed = 0
var target_minigame_active = false
var playing_custom_level = false
var gravity = base_gravity
var current_custom_level: LevelFile = null
var listeners: Dictionary = {
	LOAD: [],
	HEALTH: [],
	LVL_RESET: [],
	COLLECTED: [],
	ITEM_COLLECTED: [],
	UPGRADE_BOUGHT: [],
	STATE_CHANGED: [],
	UPGRADES_RESET: [],
	PLAYER_DIED: []
}

var tmp_dictionary = {}
var tmp_data = [
	"collected_items", "selected_weapon", "coins", "snowflakes", "ice_shards", "fire_shards",
	"total_coins", "total_snowflakes", "total_ice_shards", "total_fire_shards",
	"collected_collectables_per_level", "upgrades"
]

#Savable data
var unlocked_level: int = 1
var collected_items: Array[E.CHEST_ITEMS] = []
var selected_weapon = null
var level1_played = false
var triggered_texts = []
var triggered_buttons = {}
var last_minigame_time = 0.0
var coins: int = 0
var snowflakes: int = 0
var ice_shards: int = 0
var fire_shards: int = 0
var total_coins: int = 0
var total_snowflakes: int = 0
var total_ice_shards: int = 0
var total_fire_shards: int = 0
var created_levels = 0
var locale = OS.get_locale_language()
var times_of_levels: Dictionary = {}
var collected_collectables_per_level: Dictionary = {
	E.COLLECT.SNOWFLAKE: {
		1: []
	}
}:
	set(value):
		collected_collectables_per_level = value
var upgrades: Dictionary = {
	E.CHEST_ITEMS.SNOWBALL: {
		Upgrades.STRENGTH: 1,
		Upgrades.SPEED: 1,
		Upgrades.SIZE: 1,
		Upgrades.RELOAD: 1,
		Upgrades.BOUNCES: 1
	}, E.CHEST_ITEMS.ICICLE: {
		Upgrades.STRENGTH: 1,
		Upgrades.SPEED: 1,
		Upgrades.SIZE: 1,
		Upgrades.RELOAD: 1,
		Upgrades.SPREAD: 1
	}, E.CHEST_ITEMS.LASER: {
		Upgrades.STRENGTH: 1,
		Upgrades.SPREAD: 1,
		Upgrades.RELOAD: 1, # Aufladegeschwindigkeit
		Upgrades.SPEED: 1 # Zeit die der Laser feuert
	}, E.CHEST_ITEMS.WINGS: {
		Upgrades.STRENGTH: 1, # Flugzeit
		Upgrades.RELOAD: 1, # Aufladegeschwindigkeit
		Upgrades.SPEED: 1 # Fluggeschwindigkeit
	}
}
# Settings
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
var draw_preview = false
var player_ghost_visible = false

const saved_variables = ["unlocked_level", "collected_items", "selected_weapon", "level1_played",
	"triggered_texts", "triggered_buttons", "last_minigame_time", "coins", "snowflakes", "total_coins", "total_snowflakes",
	"collected_collectables_per_level", "upgrades", "locale", "created_levels",
	### Settings ###
	"audio", "draw_preview", "player_ghost_visible"
]
const nullable_variables = ["selected_weapon"]

const bool_settings: Dictionary = {
	E.BOOL_SETTING.DRAW_PREVIEW_TRAIL: "draw_preview",
	E.BOOL_SETTING.PLAYER_GHOST_VISIBLE: "player_ghost_visible",
}

@onready var ui: UI = get_node("/root/Main/Overlay/UI")
@onready var weapon_selection: WeaponSelection = get_node("/root/Main/Overlay/UI/WeaponSelection")
@onready var world_screen: CanvasLayer = get_node("/root/Main/WorldLayer")

var shaking = false
var shake_fade_out = 0

const shake_frequency = 0.06
var shake_intensity = 6
var shake_timer = 0
var shake_next_pos = Vector2.ZERO

func _ready() -> void:
	Input.set_custom_mouse_cursor(load("res://Resources/Images/Crosshair.png"), Input.CursorShape.CURSOR_CROSS, Vector2(19.5, 19.5))
	for tmp in tmp_data:
		var field = get(tmp)
		tmp_dictionary.get_or_add("tmp_" + tmp, field)
	process_mode = PROCESS_MODE_ALWAYS
	for i in range(levels_per_world.size()):
		var times_per_world: Dictionary = {}
		for j in range(1, levels_per_world[i] + 1):
			times_per_world[str(j)] = null
		times_of_levels[str(i+1)] = times_per_world
	print("times_of_levels: ", times_of_levels)

func set_paused(value: bool):
	get_tree().paused = value
	if value: hide_particles()
	else: show_particles()

## Find and hide all GPUParticle2D effects
func hide_particles():
	for node in get_tree().root.find_children("*", "GPUParticles2D", true, false):
		if node.editor_description.is_empty():
			node.set_meta("gg_pause", node.visible)
			node.visible = false
## Restore visibility of all previously hidden GPUParticle2D effects
func show_particles():
	for node in get_tree().root.find_children("*", "GPUParticles2D", true, false):
		if node.has_meta("gg_pause"):
			node.visible = node.get_meta("gg_pause")
			node.remove_meta("gg_pause")

func load_data(data: Dictionary, skip_data_when_not_present: bool = false):
	loading_data = true
	for variable:String in saved_variables:
		var value = data.get(variable)
		if value == null and variable not in nullable_variables:
			if skip_data_when_not_present: continue
			else:
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
	
	for i in range(AudioServer.bus_count):
		var bus_name = AudioServer.get_bus_name(i)
		AudioServer.set_bus_volume_db(i, audio[bus_name]["value"])
		AudioServer.set_bus_mute(i, audio[bus_name]["mute"])
	
	if start_with_all_items:
		for chest_item in E.CHEST_ITEMS.values():
			collect_item(chest_item)
	else:
		if not selected_weapon in collected_items: selected_weapon = null
	
	#TODO remove - only current workaround:
	total_coins = max(coins, total_coins)
	total_snowflakes = max(snowflakes, total_snowflakes)
	
	Localization.set_language(locale)
	
	SignalBus.load.emit()
	loading_data = false
	
	ui.get_node("Background").night = unlocked_level == 2
	
	if !collected_collectables_per_level[E.COLLECT.SNOWFLAKE].has(unlocked_level):
		add_next_collectable_storage()
	add_buttons_to_trigger()

func load_sandbox_mode():
	weapon_selection.set_all_disabled_except([0, 1])

func get_collected_weapons(include_laser = false) -> Array[E.CHEST_ITEMS]:
	var copy: Array[E.CHEST_ITEMS] = []
	for item in collected_items:
		if E.is_weapon(item) or (include_laser and item == E.CHEST_ITEMS.LASER):
			copy.append(item)
	return copy

func get_collected_weapons_int() -> Array[int]:
	var collected_weapons_int: Array[int] = []
	for collected_weapon in get_collected_weapons(): 
		collected_weapons_int.append(item_to_id(collected_weapon))
	return collected_weapons_int

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

func shake_effect(instant_set = true):
	shaking = true
	shake_fade_out = 10
	if instant_set:
		world_screen.offset = Vector2(shake_intensity, 0).rotated(deg_to_rad(randi_range(0, 360)))

func stop_shake_effect():
	shaking = false
	shake_fade_out = 0.7

func buy_upgrade(item: E.CHEST_ITEMS, upgrade: Upgrades.Type):
	upgrades[item][Upgrades.get_upgrade_name(upgrade)] += 1
	SignalBus.upgrade_bought.emit(item, upgrade)
	play_sound("res://Resources/Sounds/Upgrade.wav", EFFECTS)

func reset_upgrades():
	var actually_resetted_something = false
	for item in upgrades.keys():
		for upgrade_name in upgrades[item]:
			var upgrade: Upgrades.Type = Upgrades.upgrade_name_map.find_key(upgrade_name)
			var upgrades_amount = upgrades[item][upgrade_name]
			for i in range(1, upgrades_amount):
				var costs: Dictionary = Upgrades.upgrade_cost(item, upgrade, i)
				for cost_type in costs.keys():
					collect(cost_type, costs[cost_type])
					actually_resetted_something = true
			upgrades[item][upgrade_name] = 1
	
	SignalBus.upgrades_reset.emit()
	return actually_resetted_something

func collect(collectable_type: E.COLLECT, amount: int):
	var collectable_name = E.collectable_name_map[collectable_type]
	set(collectable_name, get(collectable_name) + amount)
	set("total_" + collectable_name, get("total_" + collectable_name) + amount)
	SignalBus.collected.emit(collectable_type)

func get_item_type_name(chest_item: E.CHEST_ITEMS) -> String:
	return E.item_type_name_map.get(chest_item, "Unbekannt :(")

func is_collected(chest_item: E.CHEST_ITEMS) -> bool:
	return chest_item in collected_items

func is_collectable_gone_after_completion(collectable_type: E.COLLECT) -> bool:
	return collectable_type in collectables_gone_after_completion

func is_collectable_gone(collectable_type: E.COLLECT, level_number: int, id: int) -> bool:
	if not is_collectable_gone_after_completion(collectable_type): return false
	var collected_in_level = collected_collectables_per_level[collectable_type][level_number]
	for collected in collected_in_level:
		if int(collected) == id: return true
	return false

func set_button_triggered(level_number: int, id: int):
	if !is_button_triggered(level_number, id): triggered_buttons[level_number].append(id)

func is_button_triggered(level_number: int, id: int):
	return triggered_buttons[level_number].has(id)

func collect_gone(collectable_type: E.COLLECT, level_number: int, id: int):
	if is_collectable_gone_after_completion(collectable_type):
		if level_number == -1:
			print("level number not initialized correctly for ", E.collectable_name_map[collectable_type], " with id ", id, ". Using Globals' current level")
			level_number = current_level
		var gone_in_level = collected_collectables_per_level[collectable_type][level_number]
		if id not in gone_in_level:
			gone_in_level.append(id)

func get_data_to_save():
	var result: Dictionary = {}
	for variable in saved_variables:
		var value = get(variable)
		result.get_or_add(variable, value)
	return result

func force_debug_redraw():
	var win = get_window()
	var size = win.size.y
	win.size.y = size - 1
	await get_tree().process_frame
	win.size.y = size

func _process(delta: float) -> void:
	#todo remove this:
	#if Input.is_action_just_pressed("ui_down"):
		#shake_effect()
	#if Input.is_action_just_released("ui_down"):
		#stop_shake_effect()
	
	if Input.is_action_just_pressed("ESC"):
		ui.back()
	if Input.is_action_just_pressed("F11"):
		fullscreen = !fullscreen
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	
	if Input.is_action_just_pressed("debug_mode"):
		debug_mode = !debug_mode
		ui.show_alert("Debug-Modus " + ("aktiviert!" if debug_mode else "deaktiviert!"))
		SignalBus.debug_mode_changed.emit(debug_mode)
	if Input.is_action_just_pressed("show_collision_shapes"):
		get_tree().debug_collisions_hint = !get_tree().debug_collisions_hint
		ui.show_alert("Collision Shape Modus " + ("aktiviert!" if get_tree().debug_collisions_hint else "deaktiviert!"))
		force_debug_redraw()
	
	if State.is_playing():
		if Input.is_action_just_pressed("pause"):
			change_scenes(State.PAUSED)
		if Input.is_action_just_pressed("U") and !Globals.collected_items.is_empty():
			change_scenes(State.UPGRADES)
		if Input.is_action_just_pressed("1"): weapon_selection.set_index(0, true)
		if Input.is_action_just_pressed("2"): weapon_selection.set_index(1, true)
		if Input.is_action_just_pressed("3"): weapon_selection.set_index(2, true)
	
	
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
	player_cam.position = offset

func offset_camera_global(global_offset: Vector2):
	player_cam.position = global_offset - player.global_position

func reset_camera():
	if queued_cam_offset != null:
		if is_camera_offset:
			give_player_cam_back()
			queued_cam_offset = null
		else:
			steal_player_cam()
		is_camera_offset = !is_camera_offset
	player_cam.position = Vector2.ZERO

func steal_player_cam():
	if queued_cam_offset != null:
		player.remove_child(player_cam)
		if !queued_cam_offset.get_children().has(player_cam):
			queued_cam_offset.add_child(player_cam)

func give_player_cam_back():
	if queued_cam_offset != null:
		queued_cam_offset.remove_child(player_cam)
		if !player.get_children().has(player_cam):
			player.add_child(player_cam)

func item_to_id(item: E.CHEST_ITEMS) -> int:
	return item
	#if item == E.CHEST_ITEMS.SNOWBALL: return 0
	#elif item == E.CHEST_ITEMS.ICICLE: return 1
	#else:
		#print("Item/Waffe ", item, " konnte nicht gefunden werden!!!")
		#return -1

func id_to_item(id):
	if id is E.CHEST_ITEMS or id == null: return id
	id = int(id)
	if id == 0: return E.CHEST_ITEMS.SNOWBALL
	elif id == 1: return E.CHEST_ITEMS.ICICLE
	elif id == 2: return E.CHEST_ITEMS.LASER
	elif id == 3: return E.CHEST_ITEMS.WINGS
	else:
		print("ID ", id, " gehört keinem Item!!!")
		return null

func timer(seconds: float, process_when_paused = false):
	if !process_when_paused: return get_tree().create_timer(seconds).timeout
	return get_tree().create_timer(seconds, process_when_paused).timeout

func start_level(level_number: int):
	Globals.current_level = level_number
	ui.start_level_scene(levels[level_number - 1])

func change_scenes(scene):
	ui.change_scenes(scene)

func finish_level():
	if current_custom_level != null:
		current_custom_level.set_validated(true)
		var previous_completion_time = current_custom_level.get_completion_time()
		current_custom_level.set_completion_time(player.level_time)
		if player.level_time < previous_completion_time: # only update ghost, if level was completed faster or the first time
			current_custom_level.set_ghost_frames(player.new_ghost_frames)
		current_custom_level.save()
	else:
		if current_level == unlocked_level:
			next_level_unlocked()
		times_of_levels[str(current_world)][str(current_level)] = player.level_time
	store_on_complete_data()
	Save.save_data()

func delete_level():
	ui.delete_level()

func collect_item(item: E.CHEST_ITEMS):
	collected_items.append(item)
	collected_items.sort()
	if E.is_weapon(item): selected_weapon = item
	SignalBus.item_collected.emit(item)

func has_wings():
	return is_collected(E.CHEST_ITEMS.WINGS)

func playerDied():
	if current_custom_level != null and !current_custom_level.is_validated():
		player.new_ghost_frames[player.new_ghost_frames.size()-1].died = true
		current_custom_level.set_ghost_frames(player.new_ghost_frames)
		current_custom_level.save()
	if !State.equals(State.FINISH_MENU):
		ui.change_scenes(State.DEATH_SCREEN)

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
	SignalBus.level_reset.emit()

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

func is_bool_setting(setting: E.BOOL_SETTING):
	return get(bool_setting_to_variable(setting))

func bool_setting_to_variable(setting: E.BOOL_SETTING):
	return bool_settings.get(setting)

func set_bool_setting(setting: E.BOOL_SETTING, value: bool):
	var variable_name = bool_setting_to_variable(setting)
	set(variable_name, value)
	
	if setting == E.BOOL_SETTING.DRAW_PREVIEW_TRAIL:
		if player != null: player.shoot_preview_trail()
	
	SignalBus.setting_changed_bool.emit(setting, value)
	Save.save_value(variable_name)

static func time_to_str(time: float):
	if time > 60.0:
		return str("%2d" % [int(time / 60.0)], ":", "%2d" % [int(time) % 60], ":", "%3d" % [(time - int(time)) * 1000])
	else:
		return str("%2d" % [int(time)], ":", "%3d" % [(time - int(time)) * 1000])

func dialog(dialog_text: String, on_ok: Callable, parent: Node):
	var dialog := ConfirmationDialog.new()
	dialog.dialog_text = dialog_text.replace("%n", "\n")
	dialog.confirmed.connect(on_ok)
	dialog.theme = load("res://Resources/main_theme.tres")
	parent.add_child(dialog)
	dialog.popup_centered()
