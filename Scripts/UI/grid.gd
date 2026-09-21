extends Node2D

@export var grid_color := Color(0.8, 0.8, 0.8, 0.1)
@export var grid_size = 48
@export var limit_left = -1
@export var limit_right = -1
@export var limit_top = -1
@export var limit_bottom = -1

@onready var camera: Camera2D = $"../Camera"
@onready var viewport := get_viewport()

var first = true

func _process(_delta):
	queue_redraw()
func _draw():
	var vp_size = viewport.size
	var cam_pos = camera.position
	var size_x = vp_size.x / camera.zoom.x / 2
	var size_y = vp_size.y / camera.zoom.y / 2
	var leftmost = max(limit_left, -size_x + cam_pos.x) if limit_left != -1 else -size_x + cam_pos.x
	var topmost = max(limit_top, -size_y + cam_pos.y) if limit_top != -1 else -size_y + cam_pos.y
	var rightmost = min(limit_right, size_x + cam_pos.x) if limit_right != -1 else size_x + cam_pos.x
	var bottommost = min(limit_bottom, size_y + cam_pos.y) if limit_bottom != -1 else size_y + cam_pos.y
	if first: print(bottommost)
	# Vertical lines |
	var left = ceil(leftmost / grid_size) * grid_size
	for x in range(0, vp_size.x / (camera.zoom.x * grid_size) + 1):
		if left >= limit_left or limit_left == -1: draw_line(Vector2(left, topmost), Vector2(left, bottommost), grid_color, -2)
		left += grid_size
		if left > limit_right and limit_right != -1: break
	
	# Horizontal lines ––
	var top = ceil(topmost / grid_size) * grid_size
	for y in range(0, vp_size.y / (camera.zoom.y * grid_size) + 1):
		if top >= limit_top or limit_top == -1: draw_line(Vector2(leftmost, top), Vector2(rightmost, top), grid_color, -2)
		top += grid_size
		if top > limit_bottom and limit_bottom != -1: break
		
	first = false
