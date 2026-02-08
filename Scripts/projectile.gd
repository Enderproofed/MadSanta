class_name Projectile extends RigidBody2D

var dead = false
var damage_left_to_deal
var damage

func _ready() -> void:
	if damage != null: $HitBoxPlayer.damage = damage
