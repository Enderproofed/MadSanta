@tool
extends ParallaxBackground

@export var night = false:
	set(value):
		night = value
		night_switch()
@export var delete_others_on_start = true
@export var moon_visible = true:
	set(value):
		moon_visible = value
		night_switch()

func _ready() -> void:
	if !Engine.is_editor_hint():
		if get_parent() != null and get_parent().get("night") != null: night = get_parent().night
		night_switch()
		if delete_others_on_start:
			delete_others()

func delete_others():
	if night: $BackDay.queue_free()
	else: $BackNight.queue_free()

func night_switch():
	if has_node("BackDay"): $BackDay.visible = !night
	if has_node("BackNight"):
		$BackNight.visible = night
		$BackNight/Moon.visible = night and moon_visible
	if has_node("Mountains"): 
		for child in $Mountains.get_children():
			child.position.y = 324 + 48 if night else 324
