extends HitBox

var die_timer = 0.6

func _ready() -> void:
	owner_type = HitBox.TYPE.ENEMY
	hits_types = [HitBox.TYPE.PLAYER, HitBox.TYPE.ENEMY]
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	if die_timer <= 0.2 and has_node("Collision"):
		$Collision.queue_free()
	if die_timer <= 0:
		queue_free()
		return
	die_timer -= delta
