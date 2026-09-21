extends Control

@export var name_edit: LineEdit
@export var has_name_toggle: SlideButton
@export var random_name_toggle: SlideButton

var placeholder: LevelEditorPlaceholder

func set_placeholder(place: LevelEditorPlaceholder):
	placeholder = place
	has_name_toggle.set_pressed(placeholder.has_name())
	random_name_toggle.set_pressed(place.is_random_name())
	name_edit.text = placeholder.get_placeholder_name()
	visibility()

func visibility():
	custom_minimum_size.y = 96 if has_name_toggle.pressed else 48
	if has_name_toggle.pressed: custom_minimum_size.y = 96 if random_name_toggle.pressed else 144
	random_name_toggle.visible = has_name_toggle.pressed
	name_edit.visible = has_name_toggle.pressed and !random_name_toggle.pressed

func _on_has_name_toggled(on: bool) -> void:
	visibility()
	placeholder.set_has_name(on)

func _on_random_name_toggled(on: bool) -> void:
	visibility()
	placeholder.set_random_name(on)

func _on_name_edit_text_changed(new_text: String) -> void:
	placeholder.set_placeholder_name(new_text)
