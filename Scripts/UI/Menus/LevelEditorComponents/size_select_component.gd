extends Control

var placeholder: LevelEditorPlaceholder

func set_placeholder(place: LevelEditorPlaceholder):
	placeholder = place
	set_value(placeholder.get_size())

func set_value(value, set_slider = true):
	$SlideKnob.position.x = 120 + (value - 1) * 60
	$SlideKnob.scale = Vector2(0.5, 0.5) * (value + 1)
	$SizeSlider/Boss.visible = int(value) == 3
	placeholder.set_size(int(value))
	if set_slider: $SizeSlider.value = value

func _on_size_select_value_changed(value: float) -> void:
	set_value(value, false)
