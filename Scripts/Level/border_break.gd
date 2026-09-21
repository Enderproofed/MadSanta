extends Node2D

enum DIRECTION {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT
}

@export var direction: DIRECTION = DIRECTION.TOP
@export var added_limit = 100

var saved_value = null

func _on_entered_body_entered(body: Node2D) -> void:
	if body == Globals.player:
		if saved_value == null:
			Globals.player_cam.limit_smoothed = true
			await get_tree().physics_frame
			match direction:
				DIRECTION.TOP: saved_value = Globals.player_cam.limit_top
				DIRECTION.BOTTOM: saved_value = Globals.player_cam.limit_bottom
				DIRECTION.LEFT: saved_value = Globals.player_cam.limit_left
				DIRECTION.RIGHT: saved_value = Globals.player_cam.limit_right
		match direction:
			DIRECTION.TOP: 
				Globals.player_cam.limit_top = saved_value + added_limit
			DIRECTION.BOTTOM: Globals.player_cam.limit_bottom = saved_value + added_limit
			DIRECTION.LEFT: Globals.player_cam.limit_left = saved_value + added_limit
			DIRECTION.RIGHT: Globals.player_cam.limit_right = saved_value + added_limit
		Globals.give_player_cam_back()
		

func _on_exited_body_entered(body: Node2D) -> void:
	if body == Globals.player:
		if saved_value != null:
			match direction:
				DIRECTION.TOP: Globals.player_cam.limit_top = saved_value
				DIRECTION.BOTTOM: Globals.player_cam.limit_bottom = saved_value
				DIRECTION.LEFT: Globals.player_cam.limit_left = saved_value
				DIRECTION.RIGHT: Globals.player_cam.limit_right = saved_value
			saved_value = null
		Globals.steal_player_cam()
		await Globals.timer(0.5)
		Globals.player_cam.limit_smoothed = false
