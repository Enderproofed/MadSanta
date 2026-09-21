extends Control

var content_type: String
var texture: CompressedTexture2D
var texture_color: Color = Color.WHITE
var button_group: ButtonGroup

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Texture.texture = texture
	$Texture.modulate = texture_color
	$Button.button_group = button_group
	$Label.text = tr(content_type)
	$Label.hide()

func select():
	$Button.button_pressed = true

func _on_button_mouse_entered() -> void:
	$Label.show()

func _on_button_mouse_exited() -> void:
	$Label.hide()
