class_name HitBoxEnemy
extends Area2D

@export var damage = 10
@export var knockback = 200
@export var one_hit = true
@export var active = true

var hitCountdown = 0.0
var hit = false

func can_hit() -> bool:
	return (!one_hit or !hit) and active

func _hit():
	hit = true
	hitCountdown = 0.5

func _process(delta: float) -> void:
	if hit:
		hitCountdown = max(0, hitCountdown - delta)
		if hitCountdown <= 0:
			hit = false

func _init() -> void:
	collision_layer = 2
	collision_mask = 0
