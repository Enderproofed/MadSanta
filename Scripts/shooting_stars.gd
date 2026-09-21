extends Node2D

### parameters ###
var lower_wait_time = 0.5
var upper_wait_time = 18.0
var lower_size = 0.5
var upper_size = 1.5
var lower_duration = 0.2
var upper_duration = 0.4
var drawing_rect: Rect2 = Rect2(0, 0, 1800, 320)

### used during a shooting start draw ###
var waiting_time = 0.0
var duration = 0.0
var direction = Vector2.ZERO
var speed = 0.0
var pos = Vector2.ZERO
var shoot_star_begin = 0.0
var shoot_star_end = 0.0
var shoot_star_fade = 0.0

var disabled = true: set = set_disabled

func _ready() -> void:
	$Star.visible = false
	$Line.visible = false
	$Star.modulate.a = 1
	$Line.modulate.a = 1
	set_waiting_time_random()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return # needed for scenes containing Background.tscn - LevelBase might not need @tool
	if waiting_time > 0 and waiting_time - delta <= 0 and !disabled:
		shoot_star()
	elif shoot_star_begin > 0:
		if shoot_star_begin - delta <= 0:
			shoot_star_end = duration
			pos = Vector2(0, 0)
		else: draw_shooting_star()
	elif shoot_star_end > 0:
		if shoot_star_end - delta <= 0:
			shoot_star_fade = duration
			$Line.visible = false
		else: undraw_shooting_star()
	elif shoot_star_fade > 0:
		if shoot_star_fade - delta <= 0:
			$Star.visible = false
			$Star.modulate.a = 1
			set_waiting_time_random()
		else: fade()
	elif disabled: return
	
	waiting_time -= delta
	shoot_star_begin -= delta
	shoot_star_end -= delta
	shoot_star_fade -= delta

func fade():
	rotate_star()
	if shoot_star_fade < duration / 2:
		$Star.modulate.a = shoot_star_fade * 2 / duration

func draw_shooting_star():
	rotate_star()
	pos += direction * speed
	$Line.set_point_position(0, pos)
	$Star.position += direction * speed

func undraw_shooting_star():
	rotate_star()
	pos = lerp(Vector2.ZERO, $Line.get_point_position(0), 1.0 - (shoot_star_end / duration))
	$Line.set_point_position(1, pos)

func shoot_star():
	var size = randf_range(lower_size, upper_size)
	$Star.scale = Vector2(size, size) * 0.2
	$Line.width = size * 4
	$Star.visible = true
	$Line.visible = true
	direction = Vector2(1, 0).rotated(randf_range(0, PI))
	speed = 3.0 * size
	duration = randf_range(lower_duration, upper_duration)
	pos = Vector2(0, 0)
	$Star.position = Vector2(randf_range(drawing_rect.position.x, drawing_rect.position.x + drawing_rect.size.x), randf_range(drawing_rect.position.y, drawing_rect.position.y + drawing_rect.size.y))
	$Line.position = $Star.position
	print($Line.position)
	$Line.clear_points()
	$Line.add_point(Vector2(0, 0))
	$Line.add_point(Vector2(0, 0))
	shoot_star_begin = duration

func rotate_star():
	if direction.x >= 0: $Star.rotation_degrees += speed
	else: $Star.rotation_degrees -= speed

func set_waiting_time_random():
	waiting_time = randf_range(lower_wait_time, upper_wait_time)

func set_disabled(is_disabled):
	disabled = is_disabled
	if !disabled: set_waiting_time_random()
