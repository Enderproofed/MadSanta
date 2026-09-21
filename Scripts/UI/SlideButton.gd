@tool 
class_name SlideButton extends Control

signal toggled(on: bool)

@export var text = "Hier könnte ihre Werbung stehen":
	set(value):
		text = value
		$Label.text = value
@export var translated = false

@export var disabled = false : set = set_disabled
@export var pressed = false : set = set_pressed
@export var right_label = false : set = set_right_label
@export var setting: E.BOOL_SETTING

var on_pressed: Callable
var value

var initialized = false
func _ready() -> void:
	if setting != E.BOOL_SETTING.NONE: pressed = Globals.is_bool_setting(setting)
	initialized = true
	if translated: Localization.translate_node($Label, text)
	update_label()

func set_pressed(value: bool):
	if disabled and !Engine.is_editor_hint() and initialized: return
	if !value:
		var button_group: ButtonGroup = $Button.button_group
		if button_group and !button_group.allow_unpress and button_group.get_pressed_button() == $Button: return
	pressed = value
	if $Button.button_pressed != value: $Button.button_pressed = value
	if initialized: 
		if on_pressed: 
			if on_pressed.get_argument_count() > 0: on_pressed.call(value)
			else: on_pressed.call()
		if setting != E.BOOL_SETTING.NONE: Globals.set_bool_setting(setting, value)
		if value: 
			# Check needed for Radio Buttons
			if $Button/Background/Snowball.position.y > -13: $Animation.play("toggle" if !disabled else "toggle_disabled")
		else: $Animation.play_backwards("toggle" if !disabled else "toggle_disabled")
	else:
		if value: $Animation.play("toggled" if !disabled else "toggled_disabled")
		else: $Animation.play("RESET")
	
	update_label()
	toggled.emit(pressed)

func update_label():
	if !pressed: 
		$Label.add_theme_color_override("font_color", Color.WHITE)
		$Label.add_theme_color_override("font_outline_color", Color.BLACK)
	else: 
		$Label.remove_theme_color_override("font_color")
		$Label.remove_theme_color_override("font_outline_color")
	$Label.add_theme_constant_override("outline_size", 35 if pressed else 25)

func set_right_label(value: bool):
	right_label = value
	if !Engine.is_editor_hint() and !initialized: return
	#$Button.position.x = 0 if value else 72
	$Label.position.x = 80 if value else -320
	$Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if value else HORIZONTAL_ALIGNMENT_RIGHT

func set_disabled(value: bool):
	disabled = value
	$Button/Background.modulate = Color(0.9, 0.9, 0.9) if !value else Color(0.5, 0.5, 0.5, 0.5)
	if pressed: $Button/Background.self_modulate.b = 1

func _on_button_mouse_entered() -> void:
	if !disabled: $Button/Background.modulate = Color.WHITE
func _on_button_mouse_exited() -> void:
	if !disabled: $Button/Background.modulate = Color(0.9, 0.9, 0.9)

func _on_label_gui_input(event: InputEvent) -> void:
	if event.is_action_released("mouse_left"):
		set_pressed(!pressed)
