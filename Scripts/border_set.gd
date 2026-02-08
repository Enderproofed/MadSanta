@tool class_name BorderSet extends Node2D

@export var draw_border = true
@export var border_bottom: int
@export var border_top: int
@export var border_left: int
@export var border_right: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		init()

func init():
	if Engine.is_editor_hint():
		$BorderRect.visible = draw_border
		if draw_border:
			$BorderRect.set_global_position(Vector2(border_left, border_top))
			$BorderRect.size = Vector2(border_right - border_left, border_bottom - border_top)
	else:
		$BorderRect.queue_free()

func _on_trigger_body_entered(body: Node2D) -> void:
	if body == Globals.player:
		set_border()

func set_border():
	var cam: Camera2D = Globals.player.get_node("Cam")
	cam.limit_bottom = border_bottom
	cam.limit_top = border_top
	cam.limit_left = border_left
	cam.limit_right = border_right
