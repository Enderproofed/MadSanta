class_name LevelEntry extends Button

@export var height: float:
	set(value):
		custom_minimum_size.y = value
		size.y = value

var level_name: set = set_level_name
var level_path = ""
var is_new = false
var level_file: LevelFile = null

@onready var ui: UI = get_node("/root/Main/Overlay/UI")

func _ready() -> void:
	$Animation.play("RESET")
	
	load_level_file()
	if level_file and !level_file.invalid: set_valid(level_file.is_validated())
	else: set_valid(false)
	
	if is_new:
		await get_tree().physics_frame
		await get_tree().physics_frame
		call_deferred("grab_focus")
		if button_pressed: _on_toggled(true)

func set_level_name(new_level_name):
	level_name = new_level_name
	$Title.text = new_level_name
	$TitleEdit.text = new_level_name

func set_valid(valid):
	$Valid.text = tr("VALID" if valid else "NOT_VALID")
	$Valid/Icon.texture = load("res://Resources/Images/Icons/CheckMark.png" if valid else "res://Resources/Images/Icons/Cross.png")
	$Valid/Icon.modulate = Color(1.5, 5, 1.5) if valid else Color(10, 0.4, 0.4)

# Returns true, if there is a level file that is valid, else tries to load it again and only then returns false
func load_level_file() -> bool:
	if level_file == null or level_file.invalid:
		level_file = Save.load_level(level_name)
		if level_file.invalid:
			ui.show_image_alert(E.IMAGE_ALERTS.FAILED_TO_LOAD)
			return false
	return true

func _on_toggled(toggled_on: bool) -> void:
	print(toggled_on)
	if toggled_on:
		if size.y < 134:
			$Animation.play("open")
	else:
		if size.y > 69: 
			$Animation.play_backwards("open")
		if $TitleEditToggle.button_pressed:
			_on_title_edit_toggle_toggled(false)
			$TitleEdit.text = $Title.text
	$TitleEditToggle.visible = toggled_on

func _on_title_edit_toggle_toggled(toggled_on: bool) -> void:
	$TitleEditToggle.icon = load("res://Resources/Images/Icons/Save.png" if toggled_on else "res://Resources/Images/Icons/pencil.png")
	$Title.visible = !toggled_on
	$TitleEdit.visible = toggled_on
	if !toggled_on: # counted as submitted
		Save.rename_level(level_name, $TitleEdit.text)
		level_name = $TitleEdit.text
		if level_file and !level_file.invalid: level_file.set_level_name(level_name)

func _on_title_edit_text_submitted(new_text: String) -> void:
	$Title.text = new_text
	_on_title_edit_toggle_toggled(false)

func _on_open_save_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path(level_path))


func _on_play_pressed() -> void:
	if load_level_file():
		level_file.play()

func _on_edit_pressed() -> void:
	if load_level_file():
		level_file.set_level_name(level_name)
		Globals.current_custom_level = level_file
		ui.change_scenes(State.LEVEL_EDITOR, 0.5, 0.0)

func _on_delete_pressed() -> void:
	Globals.dialog(tr("DELETE_LEVEL"), delete, get_node("/root/Main/Overlay/UI"))

func delete():
	if Save.delete_level(level_name): queue_free()
	else: ui.show_image_alert(E.IMAGE_ALERTS.FAILED_TO_DELETE)
