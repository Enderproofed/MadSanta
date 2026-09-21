@tool class_name Collectable extends Area2D

@export var collectable_type: E.COLLECT
@export var check_id = false: 
	set(value):
		id_check()
@export var id = 1
@export var decoration = false:
	set(value):
		decoration = value
		if value: id = -1
		else: id_check()
@export var fake_collect = false

var collected = false
var to_delete_on_collect = []
var activation_timer = 0.0
var active = true
var collect_queued = false

func _ready() -> void:
	if Engine.is_editor_hint():
		#if Globals.is_collectable_gone_after_completion(collectable_type) and get_parent() != null:
		id_check()
	elif decoration:
		$Collision.disabled = true
		if has_node("HoverAnimation"): $HoverAnimation.play("RESET")
		if !fake_collect: $CollectEasteregg.queue_free()
	else:
		$CollectEasteregg.queue_free()
		delete_on_collected()
		if activation_timer > 0.0:
			await Globals.timer(activation_timer)
			active = true
			if collect_queued: collect()

# has to be set before _ready is called
func set_activation_timer(value):
	active = false
	activation_timer = value

func id_check() -> int:
	if get_parent() is not PathFollow2D:
		return id_check_static(get_parent(), self)
	else: return id_check_static(get_parent().get_parent().get_parent(), self)

static func id_check_static(parent: Node2D, collectable: Collectable) -> int:
	#var new_id = collectable.id
	if collectable.id != -1 and Engine.is_editor_hint() and parent.get_child_count() != 0:
		collectable.id = 1
		#new_id = 1
		var ids = []
		var idsDict = {}
		for sibling in parent.get_children():
			if sibling is PathCollectable or sibling is Collectable:
				if sibling.get("collectable_type") != null and collectable.collectable_type == sibling.collectable_type and sibling != collectable:# and collectable.id == sibling.id:
					if idsDict.get_or_add(sibling.id, sibling.name) != sibling.name:
						print("Collectable ", idsDict.get(sibling.id), " and ", sibling.name, " have the same id: ", sibling.id)
					else: ids.append(sibling.id)
		ids.sort()
		for id in ids:
			if id == collectable.id:
				collectable.id += 1
			else: break
		
	return collectable.id
	#return new_id

func _on_body_entered(body: Node2D) -> void:
	if !decoration and body == Globals.player or body is Projectile:
		collect()

func collect():
	if !collected:
		if !active:
			collect_queued = true
		else:
			collected = true
			child_collectable_check()
			if visible and modulate.a == 1:
				$CollectAnimation.play("collect")
				Globals.collect_gone(collectable_type, Globals.current_level, id)
				Globals.collect(collectable_type, 1)
			else: queue_free()

func remove():
	for to_delete in to_delete_on_collect:
		to_delete.queue_free()
	queue_free()

func child_collectable_check():
	var children_to_re_hang = []
	for child in get_children():
		if child is Collectable or child is PathCollectable: # umhängen bei bspw. Coin-Ring
			children_to_re_hang.append(child)
	for child in children_to_re_hang:
		var pos_save = child.global_position
		remove_child(child)
		get_parent().add_child(child)
		child.global_position = pos_save


func delete_on_collected():
	if !decoration and id != null and Globals.current_level > 0 and Globals.is_collectable_gone(collectable_type, Globals.current_level, id):
		queue_free()

func _on_collect_easteregg_button_down() -> void:
	$CollectAnimation.play("collect_without_die")
