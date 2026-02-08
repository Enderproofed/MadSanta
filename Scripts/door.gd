class_name Door
extends Node2D

@export var enemies: Node2D

func _ready() -> void:
	if enemies != null:
		for enemy in enemies.get_children():
			enemy.multi_death_door_listener = Callable(self, "remove_enemy")

func remove_enemy(enemy: Enemy):
	if enemies.get_child_count() == 0 or enemies.get_child_count() == 1 and enemies.get_child(0) == enemy:
		open(null)

func open(source):
	$Animation.play("open")
	if source is not TriggerButton or !Globals.is_button_triggered(Globals.level.level_number, source.id):
		Globals.offset_camera_global(global_position)
		#Globals.player.get_node("Cam").global_position = global_position
		Globals.player.get_node("CamAnimation").play("3secZoomInOut")
		
		get_tree().paused = true
		await Globals.timer(3.25)
		Globals.reset_camera()
		#Globals.player.get_node("Cam").position = Vector2.ZERO
		await Globals.timer(0.75)
		get_tree().paused = false
