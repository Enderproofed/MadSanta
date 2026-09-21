class_name HitBox
extends Area2D

enum TYPE {
	PLAYER,
	ENEMY
}

@export var damage = 10
@export var knockback = 100
@export var one_hit = true
@export var active = true
@export var owner_type = TYPE.PLAYER
@export var hits_types: Array[TYPE] = [TYPE.ENEMY]

var hitCountdown = 0.0
var hit = false

var hit_body

func _init() -> void:
	collision_layer = 0
	collision_mask = 0

func _ready() -> void:
	if TYPE.PLAYER in hits_types: collision_mask += 2
	if TYPE.ENEMY in hits_types: collision_mask += 8
	owner = get_parent() if get_parent() is CharacterBody2D else get_parent().get_parent()
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if can_hit() and body.has_method("take_damage"):
		hit_that_body(body)

func _on_body_exited(body: Node2D) -> void:
	if body == hit_body: hit_body = null

func hit_that_body(body: Node2D):
	_hit()
	hit_body = body
	body.take_damage(damage)
	if TYPE.PLAYER in hits_types:
		owner.dealt_damage_to_player(body)
	if body.has_method("knock_back"):
		body.knock_back(body.global_position - global_position, 0.5, knockback)

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
			if hit_body != null:
				hit_that_body(hit_body)
