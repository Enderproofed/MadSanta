extends Control

@onready var ui: UI = get_parent()
@onready var minigames_texture = load("res://Resources/Images/Targets/TargetBig.png")
@onready var minigames_texture_focused = load("res://Resources/Images/Targets/TargetBigFocus.png")

var minigames_disabled = false
var focuses: Dictionary = {"Minigames": false, "Create": false}

func _ready() -> void:
	await get_tree().physics_frame
	print($Buttons/Play.is_in_group("Translated"))

func _on_play_pressed() -> void:
	ui.change_scenes(State.LEVEL_SELECTION)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_credits_pressed() -> void:
	ui.change_scenes(State.CREDITS)

func _on_options_pressed() -> void:
	ui.change_scenes(State.SETTINGS)

func _on_accounts_pressed() -> void:
	ui.change_scenes(State.SAVE_MENU)

func _process(delta: float) -> void:
	for node_name in focuses.keys():
		var button_node = get_node(node_name + "/Button")
		var focus = get_global_mouse_position().distance_to(button_node.global_position) < button_node.shape.radius * button_node.scale.x
		if focus != focuses[node_name]:
			if node_name == "Minigames":
				$Minigames/Button/Target/Texture.texture = minigames_texture_focused if focus else minigames_texture
			if node_name == "Create":
				var mat: ShaderMaterial = $Create/Button/Icon/Texture.material
				mat.set_shader_parameter("line_thickness", 1.0 if focus else 0.0)
		focuses[node_name] = focus

func _on_minigames_button_pressed() -> void:
	$Minigames/Button/PulsateAnimation.stop(true)
	$Minigames/Button/Target/Animation.play("pop")
	ui.change_scenes(State.MINIGAMES_MENU, 1.75, 0.5)
	await Globals.timer(3)
	$Minigames/Button/Target/Animation.play("RESET")

func _on_create_button_pressed() -> void:
	$Create/Button/PulsateAnimation.stop(true)
	$Create/Button/Icon/Animation.play("pop")
	ui.change_scenes(State.CREATE_LEVEL_MENU, 1.75, 0.5)
	await Globals.timer(3)
	$Create/Button/Icon/Animation.play("RESET")
