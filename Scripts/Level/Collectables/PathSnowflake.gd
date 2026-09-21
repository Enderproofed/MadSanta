@tool
class_name PathCollectable extends Node2D

const name_to_enum = {
	"Snowflake": E.COLLECT.SNOWFLAKE,
	"Coin": E.COLLECT.COIN,
	"IceShard": E.COLLECT.ICE_SHARD,
	"FireShard": E.COLLECT.FIRE_SHARD
}

@export var collectable_type = E.COLLECT.SNOWFLAKE:
	set(value):
		collectable_type = value
		visibility()
		id_check()
@export var id = 1
@export var check_id = false:
	set(value):
		id_check()
@export var speed = 1.0
@export var init_progress_ratio = 0.0

@export var curve: Curve2D:
	set(value):
		$Path2D.curve = value
		curve = value

@export var all_rotating = false:
	set(value):
		all_rotating = value
		visibility()
@export var rotating_speed = 0.5

var index = 0

func _ready() -> void:
	$Path2D/PathFollow2D.progress_ratio = init_progress_ratio if init_progress_ratio != null else 0.0
	if Engine.is_editor_hint(): id_check()
	else:
		var collectable:Collectable = get_collectable(enum_to_name(collectable_type))
		collectable.id = id
		if !all_rotating:
			for child in $Path2D/PathFollow2D.get_children():
				if child != collectable: child.queue_free()
		else: rotating_loop()
		
func rotating_loop():
	var stop = false
	while !is_queued_for_deletion() and !stop:
		for child: Collectable in $Path2D/PathFollow2D.get_children():
			if child.collected: stop = true
		if !stop:
			for child: Collectable in $Path2D/PathFollow2D.get_children():
				child.visible = child.get_index() == index
			index = index + 1 if index < $Path2D/PathFollow2D.get_child_count()-1 else 0
		await Globals.timer(rotating_speed)

func _process(delta: float) -> void:
	$Path2D/PathFollow2D.progress += speed

func id_check():
	print(collectable_type)
	id = Collectable.id_check_static(get_parent(), get_collectable(enum_to_name(collectable_type)))

func enum_to_name(collectable: E.COLLECT):
	return name_to_enum.find_key(collectable)

func visibility():
	for collectable_name in name_to_enum.keys():
		get_collectable(collectable_name).visible = collectable_type == name_to_enum[collectable_name] or all_rotating

func get_collectable(collectable_name: String) -> Collectable:
	return $Path2D/PathFollow2D.get_node(collectable_name)
