extends Control

@onready var ui: UI = get_parent()

func _ready() -> void:
	$RadioButtonContainer.set_value(Globals.locale)

func _on_back_pressed() -> void:
	ui.back()

func _on_radio_button_container_button_pressed(locale: Variant) -> void:
	Localization.set_language(locale)
