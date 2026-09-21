extends Control

var focused = false
var disabled = false

@onready var ui: UI = get_node("/root/Main/Overlay/UI")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#SignalBus.load.connect(check_upgrades_enabled)
	#SignalBus.level_reset.connect(check_upgrades_enabled)
	#SignalBus.item_collected.connect(check_upgrades_enabled)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var focus = mouse_in_capsule()
	if focus != focused:
		$Button/Arrow/Texture.self_modulate = Color(2,2,2) if focus else Color.WHITE
	focused = focus

func mouse_in_capsule() -> bool:
	var height = $Button.shape.height
	var radius = $Button.shape.radius
	var circle_pos = Vector2(0, height/2 - radius)
	var mouse_pos = get_global_mouse_position()
	var inside = mouse_pos.distance_to(global_position - circle_pos) < $Button.shape.radius * $Button.scale.x
	inside = inside or mouse_pos.distance_to(global_position + circle_pos) < $Button.shape.radius * $Button.scale.x
	return inside or Rect2(Vector2(-radius, -height/2) + global_position, Vector2(radius*2, height)).has_point(mouse_pos)

func check_upgrades_enabled():
	set_upgrades_enabled(!Globals.collected_items.is_empty())
func set_upgrades_enabled(enabled: bool):
	modulate = Color.WHITE if enabled else Color(0, 0, 0, 0.5)
	$Title.add_theme_constant_override("outline_size", 15 if enabled else 0)
	disabled = !enabled
	$Button/PulsateAnimation.play("pulsate" if enabled else "RESET")

func _on_upgrades_button_pressed() -> void:
	if !disabled:
		$Button/PulsateAnimation.stop(true)
		$Button/Arrow/Animation.play("pop")
		ui.change_scenes(State.UPGRADES, 0, 0.5)
		await Globals.timer(1)
		$Button/Arrow/Animation.play("RESET")
