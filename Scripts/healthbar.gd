class_name HealthBar
extends ProgressBar

@export var health = 0 : set = _set_health

func _set_health(new_health):
	health = min(max_value, new_health)
	value = health
	update_fill_color(health/max_value)
	if health <= 0:
		hide()

func calculate_color(progress: float) -> Color:
	return Color(1.0, progress * 2.0, 0.0) if progress <= 0.5 else Color(1.0 - (progress - 0.5) * 2.0, 1.0, 0.0)

func update_fill_color(progress: float) -> void:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = calculate_color(progress)
	add_theme_stylebox_override("fill", stylebox)

func init_health(_health):
	set_max_value(_health)
	health = _health

func set_max_value(new_max_value):
	max_value = new_max_value
	size.x = 36 + (new_max_value-100.0)*(36.0/100.0) 
	position.x = -size.x/2
