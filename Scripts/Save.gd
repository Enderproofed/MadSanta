extends Node

var base_data = {
	"unlocked_level": 1,
	"collected_items": [],
	"selected_weapon": null,
	"level1_played": false,
	"triggered_texts": [],
	"triggered_buttons": {
		1: []
	},
	"coins": 0,
	"snowflakes": 0,
	"total_coins": 0,
	"total_snowflakes": 0,
	"collected_collectables_per_level": {
		Globals.COLLECT.SNOWFLAKE: {
			1: []
		}
	},
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
		Globals.CHEST_ITEMS.SNOWBALL: {
			Globals.STRENGTH: 1,
			Globals.SPEED: 1,
			Globals.SIZE: 1,
			Globals.RELOAD: 1
		},
		Globals.CHEST_ITEMS.ICICLE: {
			Globals.STRENGTH: 1,
			Globals.SPEED: 1,
			Globals.SIZE: 1,
			Globals.RELOAD: 1
		}, Globals.CHEST_ITEMS.LASER: {
			Globals.STRENGTH: 1,
			Globals.SPREAD: 1
		}
	}
}

var global_data = {"saves" : []}

var active_save_name
var saves = []
var save_file_path = ""
const GLOBAL_SAVE_FILE_PATH = "user://MadSanta.docx"
const SAVES_PATH = "user://Saves/"

func _init() -> void:
	load_global_data()

func create_save(save_name: String) -> bool:
	var created = DirAccess.make_dir_recursive_absolute(SAVES_PATH + save_name) == Error.OK
	if !created:
		print("Could not create the save folder for ", save_name)
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
	save_file_path = get_save_path(save_name) + "/Save.png"
	load_data()

func get_global_data() -> Dictionary:
	global_data["saves"] = saves
	return global_data

func save_global_data():
	#var json_string = JsonParser.dictionary_to_json(get_global_data(), true)
	var json_string = JSON.stringify(get_global_data(), "  ")
	#var json_string = JSON.stringify(get_global_data())
	var save_file = FileAccess.open(GLOBAL_SAVE_FILE_PATH, FileAccess.WRITE)
	save_file.store_line(json_string)

func load_global_data():
	var data = read_json_file(GLOBAL_SAVE_FILE_PATH)
	for variable in global_data.keys():
		print(variable, ": ", data.get(variable))
		set(variable, data.get(variable)) 

func save_data():
	var data_to_save = Globals.get_data_to_save()
	var json_string = JSON.stringify(data_to_save, "\t")
	if json_string == "null" or json_string == null:
		print("Saving data did not work, got a null as save data")
		return
	var save_file = FileAccess.open(save_file_path, FileAccess.WRITE)
	save_file.store_line(json_string)

func load_data():
	if not FileAccess.file_exists(save_file_path):
		Globals.load_data(base_data)
		save_data()
		print("Save file not found. Using base data and creating new save file.")
		return
	
	Globals.load_data(read_json_file(save_file_path))

func read_json_file(file_path):
	var save_file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = save_file.get_as_text().replace("\t", "").replace("\n", "").replace(": ", ":")
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return base_data
	
	return json.data
