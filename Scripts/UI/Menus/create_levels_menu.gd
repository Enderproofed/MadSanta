extends Control

var level_entry_load = load("uid://cfvkbulgn0l0s")

var button_group: ButtonGroup = ButtonGroup.new()
var level_entries: Array[LevelEntry] = []

func _ready() -> void:
	#button_group.allow_unpress = true
	#for i in range(10):
		#create_level(str("Eigenes Level ", i+1), false)
	var level_paths = Save.get_level_paths()
	for level_path in level_paths:
		if Save.is_file_valid(level_path, Save.LEVEL_FILE_ENCODING):
			create_level(level_path)
	$NoLevelsPlaceholder.visible = level_entries.is_empty()

func new_level() -> void:
	Globals.created_levels += 1
	Save.save_value("created_levels")
	var level_name = str("Neues Level #", Globals.created_levels)
	Save.save_level(LevelFile.base_level_data, level_name)
	var level_entry := create_level(Save.level_dir_path + level_name, true, true)

func create_level(level_path: String, pressed = false, is_new = false) -> LevelEntry:
	var split = level_path.split("/")
	var level_name = split[split.size()-1].replace(Save.LEVEL_FILE_FORMAT, "")
	var level_entry: LevelEntry = level_entry_load.instantiate()
	level_entry.button_group = button_group
	level_entry.level_name = level_name
	level_entry.level_path = level_path.replace(str("/", level_name, Save.LEVEL_FILE_FORMAT), "")
	level_entry.button_pressed = pressed
	level_entry.is_new = is_new
	$LevelContainerScrollPanel/Container/Spacing.add_child(level_entry)
	level_entries.append(level_entry)
	$NoLevelsPlaceholder.hide()
	return level_entry

func import_level() -> void:
	var file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.add_filter(str("*", Save.LEVEL_FILE_FORMAT), "Pimmel File")
	file_dialog.connect("file_selected", _on_file_selected)
	file_dialog.use_native_dialog = true
	add_child(file_dialog)
	file_dialog.popup_centered()

var import_path = ""
func _on_file_selected(path: String):
	import_path = path
	if FileAccess.file_exists(path):
		Globals.dialog(tr("OVERWRITE_LEVEL"), copy_file, self)
		return
	copy_file()

func copy_file():
	var split = import_path.split("\\")
	var destination_path = Save.level_dir_path + split[split.size() - 1]
	var err := DirAccess.copy_absolute(import_path, ProjectSettings.globalize_path(destination_path))
	if err != OK:
		push_error("Failed to copy file: %s Error %s" % [error_string(err), err])
		return false
	return true
