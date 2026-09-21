@tool extends Button

enum Type {
	BACK,
	FORTH,
	BACK_FULL,
	FORTH_FULL
}

@export var type: Type = Type.BACK:
	set(value):
		type = value
		if !has_node("Pivot/Pivot/Label"): return
		$Pivot/Pivot/Label.show()
		$Pivot/Pivot/PlayImage.show()
		$Pivot/Pivot.position.x = 12
		$Pivot/Pivot/PlayImage.position.x = -12 if value == Type.BACK_FULL else 12
		if value == Type.FORTH:
			name = "Forth"
			$Pivot/Pivot/Label.text = ">"
			$Pivot/Pivot.position.x = -12
			$Pivot/Pivot/Label.position.x = -26
		elif value == Type.BACK:
			name = "Back"
			$Pivot/Pivot/Label.text = "<"
			$Pivot/Pivot/Label.position.x = -52
		else: $Pivot/Pivot/Label.hide()
		if value == Type.FORTH_FULL:
			name = "Forth"
			$Pivot/Pivot/PlayImage.flip_h = false
			$Pivot/Pivot/PlayImage/Inner.flip_h = false
			$Pivot/Pivot/PlayImage/Shadow.flip_h = false
			$Pivot/Pivot/PlayImage/Inner.position.x = -3
			$Pivot/Pivot.position.x = -12
		elif value == Type.BACK_FULL:
			name = "Back"
			$Pivot/Pivot/PlayImage.flip_h = true
			$Pivot/Pivot/PlayImage/Inner.flip_h = true
			$Pivot/Pivot/PlayImage/Shadow.flip_h = true
			$Pivot/Pivot/PlayImage/Inner.position.x = 3
		else: $Pivot/Pivot/PlayImage.hide()

@export var button_size = 1.0:
	set(value):
		button_size = value
		$Pivot.scale = Vector2(value, value)

func _on_button_down() -> void:
	$Pivot/Pivot/Animation.play("pressed")

func _on_button_up() -> void:
	$Pivot/Pivot/Animation.play_backwards("pressed")
