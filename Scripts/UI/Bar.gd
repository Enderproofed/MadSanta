@tool
class_name Bar
extends TextureProgressBar

@export var is_vertical = false
@export_range(40, 1000, 4) var length = 128
@export var has_container = false
@export var is_health = false
@export var has_stars_on_full = true
@export var color = Color(0.6, 0.8, 100)

@onready var init_length = length
var init_max_value = max_value
var display_length = length

const thickness = 36

var extreme_color = color
var extreme_amplifier = 200
var half_extreme_color = color
var half_extreme_amplifier = 1.01
var full = false

var pushed_elements = []
var pushed_elements_init_pos = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		init()

func _ready() -> void:
	if !Engine.is_editor_hint():
		init()
		if !has_container: $Container.queue_free()
		if is_health:
			SignalBus.health.connect(update_value)

func init_progress(init_value: float):
	max_value = init_value
	init_max_value = init_value
	value = init_value
	full = true
	color_bar()

func init():
	set_extreme_color()
	
	rotation_degrees = -90 if is_vertical else -180
	fill_mode = FillMode.FILL_TOP_TO_BOTTOM# if is_vertical else FillMode.FILL_BOTTOM_TO_TOP
	$Container.visible = has_container
	
	if Engine.is_editor_hint():
		size.y = length
	else:
		set_length(length)
	
	if !has_stars_on_full:
		$Stars.queue_free()
		$StarsColored.queue_free()

func set_length(new_length):
	var difference = (new_length - init_length) * 1.15
	for i in range(pushed_elements.size()):
		if pushed_elements_init_pos.size() < pushed_elements.size():
			pushed_elements_init_pos.append(pushed_elements[i].position)
		pushed_elements[i].position = pushed_elements_init_pos[i] + (Vector2(difference, 0) if is_vertical else Vector2(0, -difference))
	display_length = new_length
	size.y = display_length
	$Bottom.position.y = display_length - 4
	if has_container: $Container.size.y = display_length / $Container.scale.y
	color_bar()
	if has_stars_on_full:
		var particles: ParticleProcessMaterial = $Stars.process_material
		particles.emission_box_extents = Vector3(thickness / 2, display_length / 2, 1)
		$Stars.position.y = display_length/2
		particles = $StarsColored.process_material
		particles.emission_box_extents = Vector3(thickness / 2, display_length / 2, 1)
		$StarsColored.position.y = display_length/2
		$StarsColored.modulate = color + Color(0.5, 0.5, 0.5)
		var particle_ratio = (display_length / 128.0) / 3.0
		$StarsColored.amount_ratio = particle_ratio
		$Stars.amount_ratio = particle_ratio

func update_value(new_value):
	value = new_value
	full = abs(max_value - value) < 0.01
	color_bar()
	particles()

func update_max_value(new_value, size_step):
	var old_value = max_value
	max_value = new_value
	value = new_value * (value / old_value)
	var new_length = (new_value / init_max_value) * init_length
	var difference = new_length - length
	length = new_length
	if difference <= 0:
		set_length(init_length)
		difference = new_length - init_length
	for i in range(int(difference)):
		set_length(display_length + 1)
		await Globals.timer(0.02)

func color_bar():
	if is_health:
		var progress = value/max_value
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
