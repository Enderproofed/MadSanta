extends Area2D

@export var item: Globals.CHEST_ITEMS
@export var hides_label: Label

var opened = false

func _ready() -> void:
	check_for_collected()

func open(fast = true):
	opened = true
	if fast:
		for child in get_children():
			if child is GPUParticles2D:
				child.preprocess = 0
		$Animation.play("open_without_sound")
	else:
		$Animation.play("open")
	if hides_label != null:
		if !fast: Globals.timer(1)
		hides_label.queue_free()

func check_for_collected():
	if item in Globals.collected_items:
		open()
	else:
		$Animation.play("RESET")

func _on_body_entered(body: Node2D) -> void:
	if body == Globals.player and !opened:
		open(false)
		Globals.collect_screen.set_item_type(item)
		Globals.change_scenes(Globals.COLLECT_SCREEN)
