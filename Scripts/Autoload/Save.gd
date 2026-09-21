extends Node

const ERROR_ENCODING = 1
const ERROR_PARSE = 2

const GAME_VERSION = "0.0.1"
const GLOBAL_SAVE_FILE_PATH = "user://MadSanta.docx"
const SAVES_PATH = "user://Saves/"
const LEVEL_FILE_FORMAT = ".pimmel"
const LEVEL_FILE_ENCODING = "HEE HEE :)\n\n"

var base_data = {
	"unlocked_level": 1,
	"collected_items": [],
	"selected_weapon": null,
	"level1_played": false,
	"triggered_texts": [],
	"triggered_buttons": {
		1: []
	},
	"last_minigame_time": 0,
	"coins": 0,
	"snowflakes": 0,
	"ice_shards": 0,
	"fire_shards": 0,
	"total_coins": 0,
	"total_snowflakes": 0,
	"total_ice_shards": 0,
	"total_fire_shards": 0,
	"created_levels": 0,
	"locale": OS.get_locale_language(),
	"collected_collectables_per_level": {
		E.COLLECT.SNOWFLAKE: {
			1: []
		}
	},
	"draw_preview": true,
	"player_ghost_visible": true,
	"audio": {
		Globals.MASTER: {
			"mute": false,
			"value": -2.9
		},
		Globals.MUSIC: {
			"mute": false,
			"value": -2.9
		},
		Globals.EFFECTS: {
			"mute": false,
			"value": -2.9
		}
	},
	"upgrades": {
		E.CHEST_ITEMS.SNOWBALL: {
			Upgrades.STRENGTH: 1,
			Upgrades.SPEED: 1,
			Upgrades.SIZE: 1,
			Upgrades.RELOAD: 1,
			Upgrades.BOUNCES: 1
		},
		E.CHEST_ITEMS.ICICLE: {
			Upgrades.STRENGTH: 1,
			Upgrades.SPEED: 1,
			Upgrades.SIZE: 1,
			Upgrades.RELOAD: 1
		},
		E.CHEST_ITEMS.LASER: {
			Upgrades.STRENGTH: 1,
			Upgrades.SPREAD: 1,
			Upgrades.RELOAD: 1,
			Upgrades.SPEED: 1
		},
		E.CHEST_ITEMS.WINGS: {
			Upgrades.STRENGTH: 1,
			Upgrades.RELOAD: 1,
			Upgrades.SPEED: 1
		}
	}
}

var sandbox_data = {
	"unlocked_level": 1,
	"collected_items": [E.CHEST_ITEMS.SNOWBALL, E.CHEST_ITEMS.ICICLE, E.CHEST_ITEMS.LASER, E.CHEST_ITEMS.WINGS],
	"selected_weapon": E.CHEST_ITEMS.SNOWBALL,
	"level1_played": false,
	"triggered_texts": [],
	"triggered_buttons": {
		1: []
	},
	"coins": 1000,
	"snowflakes": 1000,
	"ice_shards": 1000,
	"fire_shards": 1000,
	"total_coins": 1000,
	"total_snowflakes": 1000,
	"total_ice_shards": 1000,
	"total_fire_shards": 1000,
	"collected_collectables_per_level": {
		E.COLLECT.SNOWFLAKE: {
			1: []
		}
	},
	"draw_preview": true,
	"player_ghost_visible": true,
	"audio": {
		Globals.MASTER: {
			"mute": true,
			"value": -2.9
		},
		Globals.MUSIC: {
			"mute": true,
			"value": -2.9
		},
		Globals.EFFECTS: {
			"mute": true,
			"value": -2.9
		}
	},
	"upgrades": {
		E.CHEST_ITEMS.SNOWBALL: {
			Upgrades.STRENGTH: 5,
			Upgrades.SPEED: 1,
			Upgrades.SIZE: 1,
			Upgrades.RELOAD: 5,
			Upgrades.BOUNCES: 1
		},
		E.CHEST_ITEMS.ICICLE: {
			Upgrades.STRENGTH: 5,
			Upgrades.SPEED: 5,
			Upgrades.SIZE: 5,
			Upgrades.RELOAD: 5
		},
		E.CHEST_ITEMS.LASER: {
			Upgrades.STRENGTH: 5,
			Upgrades.SPREAD: 5,
			Upgrades.RELOAD: 5,
			Upgrades.SPEED: 5
		},
		E.CHEST_ITEMS.WINGS: {
			Upgrades.STRENGTH: 1,
			Upgrades.RELOAD: 1,
			Upgrades.SPEED: 1
		}
	}
}

var global_data = {"saves" : []}

var sandbox_mode = false
var active_save_name
var saves = []
var save_file_path = ""
var save_dir_path = ""
var level_dir_path = ""

func _init() -> void:
	load_global_data()

func create_save(save_name: String) -> bool:
	var created = DirAccess.make_dir_recursive_absolute(SAVES_PATH + save_name) == Error.OK
	if !created: push_error("Could not create the save folder for ", save_name)
	else:
		saves.append(save_name)
		active_save_name = save_name
		set_save_file(save_name)
		save_global_data()
	return created

func rename_save(old_name, new_name) -> bool:
	var path = get_save_path(old_name)
	var result = DirAccess.rename_absolute(get_save_path(old_name), get_save_path(new_name))
	if result != Error.OK:
		print("Failed to rename '", old_name, "' Save. Error code was: ", result)
	else:
		saves.erase(old_name)
		saves.append(new_name)
		save_global_data()
	return result == Error.OK

func delete_save(save_name) -> bool:
	var path = get_save_path(save_name)
	var result = OS.move_to_trash(ProjectSettings.globalize_path(get_save_path(save_name)))
	if result != Error.OK:
		print("Failed to delete '", save_name, "' Save. Error code was: ", result)
	else:
		saves.erase(save_name)
		save_global_data()
	return result == Error.OK

func get_save_path(save_name):
	return SAVES_PATH + save_name

func set_save_file(save_name):
	save_dir_path = get_save_path(save_name) + "/"
	save_file_path = save_dir_path + "Save.png"
	level_dir_path = save_dir_path + "Levels/"
	
	var created = DirAccess.make_dir_recursive_absolute(level_dir_path) == Error.OK
	if !created: push_error("Could not create the Level saves folder for ", save_name)
	
	load_data()

func get_level_paths() -> Array[String]:
	var level_paths: Array[String] = []
	var dir := DirAccess.open(level_dir_path)
	if dir == null:
		push_error("Failed to open directory: %s" % level_dir_path)
		return level_paths
	dir.list_dir_begin()
	while true:
		var file_name := dir.get_next()
		if file_name.is_empty():
			break
		if not dir.current_is_dir():
			level_paths.append(level_dir_path.path_join(file_name))
	
	dir.list_dir_end()
	return level_paths

func get_global_data() -> Dictionary:
	global_data["saves"] = saves
	return global_data

func save_global_data():
	var json_string = JSON.stringify(get_global_data(), "  ")
	var save_file = FileAccess.open(GLOBAL_SAVE_FILE_PATH, FileAccess.WRITE)
	save_file.store_line(json_string)

func load_global_data():
	var data = read_json_file(GLOBAL_SAVE_FILE_PATH)
	for variable in global_data.keys():
		print(variable, ": ", data.get(variable))
		set(variable, data.get(variable)) 

func save_data(data_to_save: Dictionary = Globals.get_data_to_save()):
	if sandbox_mode: return
	var json_string = JSON.stringify(data_to_save, "\t")
	if json_string == "null" or json_string == null:
		print("Saving data did not work, got a null as save data")
		return
	var save_file = FileAccess.open(save_file_path, FileAccess.WRITE)
	save_file.store_line(json_string)

func save_value(variables):
	if sandbox_mode: return
	var data: Dictionary = read_json_file(save_file_path)
	if data.is_empty():
		printerr("WARNING!!! You are trying to save a value to an empty Dictionary!")
		return
	if variables is String:
		data[variables] = Globals.get(variables)
	if variables is Array:
		for variable in variables:
			data[variable] = Globals.get(variable)
	save_data(data)

func load_data():
	if not FileAccess.file_exists(save_file_path):
		load_default_data()
	
	var data: Dictionary = read_json_file(save_file_path)
	if data.is_empty(): load_default_data()
	else: Globals.load_data(data)

func load_default_data(print_message = true):
	if print_message: print("Save file not found. Using base data and creating new save file.")
	Globals.load_data(base_data)
	save_data()

func load_sandbox_mode():
	sandbox_mode = true
	Globals.load_data(sandbox_data, true)


### Level handling ###
func save_level(data: Dictionary, level_name: String) -> bool:
	push_error("Test 123")
	var json_string = LEVEL_FILE_ENCODING + JSON.stringify(data, "\t")
	if json_string == "null" or json_string == null:
		push_error("Saving data did not work, got a null as save data")
		return false
	var save_file = FileAccess.open(level_dir_path + level_name + LEVEL_FILE_FORMAT, FileAccess.WRITE)
	if save_file == null:
		push_error(str("Error ", FileAccess.get_open_error(), " occured. Could not open the file ", level_name, LEVEL_FILE_FORMAT, " for writing"))
		return false
	save_file.store_line(json_string)
	return true

func load_level(level_name: String) -> LevelFile:
	var data = read_json_file(level_dir_path + level_name + LEVEL_FILE_FORMAT, LEVEL_FILE_ENCODING, {"error": ERROR_PARSE})
	if data.has("error"):
		return LevelFile.INVALID_FILE
	return LevelFile.create(data)

func rename_level(from: String, to: String):
	var path := ProjectSettings.globalize_path(level_dir_path)
	var result = DirAccess.rename_absolute(path + from + LEVEL_FILE_FORMAT, path + to + LEVEL_FILE_FORMAT)
	if result != Error.OK:
		print("Failed to rename Level '", from, "' to '", to, ". Error code was: ", result)

func delete_level(level_name: String) -> bool:
	var result = DirAccess.remove_absolute(level_dir_path + level_name + LEVEL_FILE_FORMAT)
	return result == OK

### General Utility ###
func read_json_file(file_path: String, file_prefix: String = "", fallback_data: Dictionary = base_data) -> Dictionary:
	var save_file = FileAccess.open(file_path, FileAccess.READ)
	var raw_file_content = save_file.get_as_text()
	
	if !file_prefix.is_empty():
		if !raw_file_content.contains(file_prefix):
			# If the file does not contain the given prefix, it is not treated as invalid and an error is propagated 
			return {"error": 1}
		raw_file_content = raw_file_content.replace(file_prefix, "")
	
	var json_string = raw_file_content.replace("\t", "").replace("\n", "").replace(": ", ":")
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return fallback_data
	
	if json.data is not Dictionary:
		printerr("json.data was no Dictionary... faulty data: ", json.data, "  Going on with fallback data")
		return fallback_data
	
	return json.data

func is_file_valid(file_path: String, file_prefix: String) -> bool:
	var save_file = FileAccess.open(file_path, FileAccess.READ)
	var file_content = save_file.get_as_text()
	return file_content.contains(file_prefix)
