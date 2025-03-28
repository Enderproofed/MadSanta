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
			print("saved")
			match direction:
				DIRECTION.TOP: saved_value = body.get_node("Cam").limit_top
				DIRECTION.BOTTOM: saved_value = body.get_node("Cam").limit_bottom
				DIRECTION.LEFT: saved_value = body.get_node("Cam").limit_left
				DIRECTION.RIGHT: saved_value = body.get_node("Cam").limit_right
		match direction:
			DIRECTION.TOP: body.get_node("Cam").limit_top = saved_value + added_limit
			DIRECTION.BOTTOM: body.get_node("Cam").limit_bottom = saved_value + added_limit
			DIRECTION.LEFT: body.get_node("Cam").limit_left = saved_value + added_limit
			DIRECTION.RIGHT: body.get_node("Cam").limit_right = saved_value + added_limit
		

func _on_exited_body_entered(body: Node2D) -> void:
	print("exited")
	if body == Globals.player:
		if saved_value != null:
			match direction:
				DIRECTION.TOP: body.get_node("Cam").limit_top = saved_value
				DIRECTION.BOTTOM: body.get_node("Cam").limit_bottom = saved_value
				DIRECTION.LEFT: body.get_node("Cam").limit_left = saved_value
				DIRECTION.RIGHT: body.get_node("Cam").limit_right = saved_value
			saved_value = null
