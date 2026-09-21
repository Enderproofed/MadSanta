@tool
extends ParallaxBackground

@export var night = false:
	set(value):
		night = value
		visibility_check()
@export var delete_others_on_start = true
@export var moon_visible = true:
	set(value):
		moon_visible = value
		visibility_check()

@export var indoor = false:
	set(value):
		indoor = value
		visibility_check()

@export var on_moon = false:
	set(value):
		on_moon = value
		visibility_check()

func _ready() -> void:
	if !Engine.is_editor_hint():
		if get_parent() != null and get_parent().get("night") != null: night = get_parent().night
		visibility_check()
		if delete_others_on_start:
			delete_others()

func delete_others():
	if indoor: $BackNight.queue_free()
	if indoor or on_moon:
		$BackDay.queue_free()
		$Mountains.queue_free()
		$DarkTrees.queue_free()
		$Trees.queue_free()
		$Snow.queue_free()
	elif night: $BackDay.queue_free()
	else: $BackNight.queue_free()

func visibility_check():
	if indoor == null or night == null or moon_visible == null or on_moon == null: return
	if has_node("BackDay"): $BackDay.visible = !indoor and !night
	if has_node("BackNight"):
		$BackNight.visible = !indoor and night
		$BackNight/Moon.visible = night and moon_visible
		$BackNight/Earth.visible = night and on_moon
	if has_node("Mountains"):
		$Mountains.visible = !indoor and !on_moon
		for child in $Mountains.get_children():
			child.position.y = 324 + 48 if night else 324
	if has_node("DarkTrees"): $DarkTrees.visible = !indoor and !on_moon
	if has_node("Trees"): $Trees.visible = !indoor and !on_moon
	if has_node("Snow"): $Snow.visible = !indoor and !on_moon
	if has_node("Indoor"): $Indoor.visible = indoor
	
	if Engine.is_editor_hint():
		if on_moon and !night: night = true
		if night and !on_moon and !moon_visible: moon_visible = true
	elif has_node("BackNight") and $BackNight.has_node("ShootingStars"):
		$BackNight/ShootingStars.disabled = !night
		if night:
			var viewport_size = LevelEditor.adjusted_viewport_size(get_viewport())
			$BackNight/ShootingStars.drawing_rect = Rect2(Vector2.ZERO, Vector2(viewport_size.x, viewport_size.y if on_moon else viewport_size.y * 0.4))
