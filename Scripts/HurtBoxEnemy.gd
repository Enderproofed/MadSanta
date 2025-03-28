class_name HurtBoxEnemy
extends Area2D

@onready var enemy = $"../.."

func _init() -> void:
	collision_layer = 0
	collision_mask = 2

func _ready() -> void:
	connect("area_entered", _on_area_entered)
	
func _on_area_entered(hitbox: Area2D) -> void:
	if hitbox == null:
		return
	
	if enemy.has_method("take_damage") and (hitbox is HitBoxPlayer or (hitbox is HitBoxEnemy and hitbox.active)):
		enemy.take_damage(hitbox.damage)
