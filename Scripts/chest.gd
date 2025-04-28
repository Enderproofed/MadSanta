extends Area2D

@export var item: Globals.CHEST_ITEMS

var opened = false

func _ready() -> void:
	if item in Globals.collected_items:
		for child in get_children():
			if child is GPUParticles2D:
				child.preprocess = 0
		$Animation.play("open_without_sound")
		opened = true

func _on_body_entered(body: Node2D) -> void:
	if body == Globals.player and !opened:
		print("COLLECTED!!!")
		Globals.change_scenes(Globals.COLLECT_SCREEN)
		Globals.collect_screen.set_item_type(item)
		$Animation.play("open")
		opened = true
