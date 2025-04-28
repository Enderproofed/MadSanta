class_name Door
extends Node2D

func open():
	Globals.offset_camera_global(global_position)
	#Globals.player.get_node("Cam").global_position = global_position
	Globals.player.get_node("CamAnimation").play("3secZoomInOut")
	$Animation.play("open")
	get_tree().paused = true
	await Globals.timer(3.25)
	Globals.reset_camera()
	#Globals.player.get_node("Cam").position = Vector2.ZERO
	await Globals.timer(0.75)
	get_tree().paused = false
