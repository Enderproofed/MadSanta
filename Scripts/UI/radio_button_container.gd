extends ScrollContainer

@export var labels: Array[String]
@export var values: Array
@export var translate_labels = false
#@export var

var button_group: ButtonGroup = ButtonGroup.new()
var buttons: Array[SlideButton] = []
var slide_button_load = load("uid://yfnm24kwyj4s")

signal button_pressed(value)

func _ready() -> void:
	button_group.allow_unpress = false
	for i in range(labels.size()):
		var label = labels[i]
		var value = values[i]
		var check_button: SlideButton = slide_button_load.instantiate()
		if translate_labels:
			Localization.translate_node(check_button.get_node("Label"), label)
		else: check_button.get_node("Label").text = label
		check_button.get_node("Button").button_group = button_group
		check_button.value = value
		$Spacing.add_child(check_button)
		buttons.append(check_button)
	button_group.connect("pressed", _button_pressed)

func set_value(value):
	var index = values.find(value)
	if index != -1:
		buttons[index].pressed = true

func _button_pressed(button: BaseButton):
	emit_signal("button_pressed", get_pressed_button_value())

func get_pressed_button_value():
	return values[button_group.get_pressed_button().get_parent().get_index()]
