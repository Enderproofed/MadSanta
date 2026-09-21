class_name Door
extends Node2D

@export var enemies: Node2D
@export var opened = false
@export var grabs_camera_focus = true

var one_enemy = false

func _ready() -> void:
	if opened:
		$Top.position.y = -48
		$Bottom.position.y = 48
	else:
		$Animation.play("RESET")
	if enemies != null:
		one_enemy = enemies is Enemy
		if one_enemy:
			enemies.death_door_listeners.append(Callable(self, "remove_enemy"))
		else:
			for enemy in enemies.get_children():
				enemy.death_door_listeners.append(Callable(self, "remove_enemy"))

func remove_enemy(enemy: Enemy):
	if one_enemy or enemies.get_child_count() == 0 or enemies.get_child_count() == 1 and enemies.get_child(0) == enemy:
		open(null)

func open(source):
	if !opened:
		opened = true
		$Animation.play("open")
		if source is not DoorButton or !Globals.is_button_triggered(Globals.level.level_number, source.id):
			camera_focus()

func close():
	if opened:
		opened = false
		$Animation.play("close")

func camera_focus():
	if grabs_camera_focus:
		if Globals.player != null: Globals.player.stop_laser()
		Globals.offset_camera_global(global_position)
		Globals.player.get_node("CamAnimation").play("3secZoomInOut")
		Globals.set_paused(true)
		await Globals.timer(3.25, true)
		Globals.reset_camera()
		await Globals.timer(0.75, true)
		Globals.set_paused(false)
