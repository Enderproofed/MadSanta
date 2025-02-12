class_name HurtBoxPlayer
extends Area2D

func _init() -> void:
	collision_layer = 0
	collision_mask = 2

func _ready() -> void:
	connect("area_entered", _on_area_entered)

func _on_area_entered(hitbox: Area2D) -> void:
	if hitbox == null:
		return
	
	if owner.has_method("take_damage") and hitbox is HitBoxEnemy and hitbox.can_hit():
		owner.take_damage(hitbox.damage)
		hitbox._hit()
		if owner.has_method("set_velocity") and hitbox.get("knockback") != null:
			owner.set_velocity((owner.global_position - hitbox.global_position).normalized() * hitbox.knockback)
