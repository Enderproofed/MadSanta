@tool
class_name Bar
extends TextureProgressBar

@export var is_vertical = false
@export_range(40, 1000, 4) var length = 128
@export var has_container = false
@export var is_health = false
@export var has_stars_on_full = true
@export var color = Color(0.6, 0.8, 100)

const thickness = 36

var extreme_color = color
var extreme_amplifier = 200
var half_extreme_color = color
var half_extreme_amplifier = 1.01
var full = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		init()

func _ready() -> void:
	if !Engine.is_editor_hint():
		init()
		if !has_container: $Container.queue_free()
		Globals.add_listener(Globals.HEALTH, Callable(self, "update_value"))

func init_progress(init_value: float):
	max_value = init_value
	value = init_value
	full = true
	color_bar()

func init():
	set_extreme_color()
	
	rotation_degrees = -90 if is_vertical else -180
	fill_mode = FillMode.FILL_TOP_TO_BOTTOM# if is_vertical else FillMode.FILL_BOTTOM_TO_TOP
	$Container.visible = has_container
	size.y = length
	$Bottom.position.y = length - 4
	$Container.size.y = length / $Container.scale.y
	color_bar()
	if has_stars_on_full:
		var particles: ParticleProcessMaterial = $Stars.process_material
		particles.emission_box_extents = Vector3(thickness / 2, length / 2, 1)
		$Stars.position.y = length/2
		particles = $StarsColored.process_material
		particles.emission_box_extents = Vector3(thickness / 2, length / 2, 1)
		$StarsColored.position.y = length/2
		$StarsColored.modulate = color + Color(0.5, 0.5, 0.5)
		if 10 * (length / 128) >= 1:
			$StarsColored.amount = 10 * (length / 128)
			$Stars.amount = 10 * (length / 128)
	else:
		$Stars.queue_free()
		$StarsColored.queue_free()

func update_value(new_value):
	value = new_value
	full = value == max_value
	color_bar()
	particles()

func color_bar():
	var progress = value/max_value
	if is_health:
		if progress <= 0.5: color = Color(1.0, progress * 2.0, 0.0)
		else: color = Color(1.0 - (progress - 0.5) * 2.0, 1.0, 0.0)
	if full:
		$Top/Inner.modulate = extreme_color
		$Bottom/Inner.modulate = extreme_color
		if !Engine.is_editor_hint(): tint_progress = half_extreme_color
		$Top.self_modulate = Color(color*0.5,1)
		$Bottom.self_modulate = Color(color*0.5,1)
	else:
		$Top/Inner.modulate = Color(1, 1, 1, 0.5)
		$Bottom/Inner.modulate = Color(1, 1, 1, 0.5)
		if !Engine.is_editor_hint(): tint_progress = Color(color*0.8,1)
		$Top.self_modulate = Color.WHITE
		$Bottom.self_modulate = Color.WHITE

func set_extreme_color():
	if color.r >= 1: 
		extreme_color = Color(extreme_amplifier, color.g, color.b)
		half_extreme_color = Color(half_extreme_amplifier, color.g, color.b)
	if color.g >= 1: 
		extreme_color = Color(color.r, extreme_amplifier, color.b)
		half_extreme_color = Color(color.r, half_extreme_amplifier, color.b)
	if color.b >= 1: 
		extreme_color = Color(color.r, color.g, extreme_amplifier)
		half_extreme_color = Color(color.r, color.g, half_extreme_amplifier)

func particles():
	if has_stars_on_full:
		if full:
			$Stars.emitting = true
			$StarsColored.emitting = true
		else:
			$Stars.emitting = false
			$StarsColored.emitting = false
