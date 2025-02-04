class_name HitBoxEnemy
extends Area2D

@export var damage = 10
@export var knockback = 200
@export var one_hit = true

var hit = false

func can_hit() -> bool:
	return !one_hit or !hit

func _init() -> void:
	collision_layer = 2
	collision_mask = 0
