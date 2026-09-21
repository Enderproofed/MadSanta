class_name Projectile extends CharacterBody2D

var dead = false
var die_timer = 5.0
var damage_left_to_deal
var damage
var size = 1.0

func _ready() -> void:
	if damage != null and has_node("HitBoxPlayer"): $HitBoxPlayer.damage = damage

func _process(delta: float) -> void:
	if dead: return
	if die_timer <= 0:
		die()
		return
	die_timer = max(0, die_timer - delta)

# returns true, if the projectile was still alive before
# calls on_die() for the handling of the children
func die() -> bool:
	if !dead:
		dead = true
		on_die()
		return true
	else: return false

# to be implemented by child Nodes
func on_die():
	pass
