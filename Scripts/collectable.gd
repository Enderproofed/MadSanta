@tool class_name Collectable extends Area2D

@export var collectable_type: Globals.COLLECT
@export var id = 1:
	set(value):
		id = value
		delete_on_collected()
@export var decoration = false
@export var fake_collect = false

var collected = false
var level_number = -1:
	set(value):
		level_number = value
		delete_on_collected()

func _ready() -> void:
	if Engine.is_editor_hint():
		#if Globals.is_collectable_gone_after_completion(collectable_type) and get_parent() != null:
		if get_parent() != null and get_parent() is not PathFollow2D:
			for sibling in get_parent().get_children():
				if sibling.collectable_type == collectable_type and sibling.id == id and sibling != self:
					id += 1
	elif decoration:
		$Collision.disabled = true
		if !fake_collect: $CollectEasteregg.queue_free()
	else: $CollectEasteregg.queue_free()

func _on_body_entered(body: Node2D) -> void:
	if !decoration and body == Globals.player or body is Projectile:
		if !collected:
			collected = true
			$CollectAnimation.play("collect")
			Globals.collect_gone(collectable_type, level_number, id)
			Globals.collect(collectable_type, 1)

func delete_on_collected():
	if !decoration and id != null and level_number != -1 and Globals.is_collectable_gone(collectable_type, level_number, id):
		queue_free()

func _on_collect_easteregg_button_down() -> void:
	$CollectAnimation.play("collect_without_die")
