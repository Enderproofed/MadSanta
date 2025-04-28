@tool
class_name TextTrigger
extends Area2D

@export var text: Texts.TEXTS
@export var camera_offset_x = 0
@export var camera_offset_y = 0
@export var offset_target: Node2D

var triggered = false

func _ready() -> void:
	if offset_target != null:
		if offset_target is Enemy:
			offset_target.activated_by = self
	if text in Globals.triggered_texts:
		trigger()
		

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		$CamOffsetLine.clear_points()
		$CamOffsetLine.add_point(Vector2.ZERO)
		var offset = offset_target.global_position - global_position if offset_target != null else Vector2(camera_offset_x, camera_offset_y)
		$CamOffsetLine.add_point(offset)
		$CamOffsetLine.global_scale = Vector2.ONE

func _on_body_entered(body: Node2D) -> void:
	if !Engine.is_editor_hint():
		if body == Globals.player:
			start_text_sequence()
			trigger()

func start_text_sequence():
	if text not in Globals.triggered_texts:
		get_node("/root/Main/UI").start_text_sequence(Texts.get_text(text))
		if offset_target != null:
			Globals.offset_camera_global(offset_target.global_position)
		else:
			Globals.offset_camera(Vector2(camera_offset_x, camera_offset_y))
		Globals.triggered_texts.append(text)
		

func trigger():
	triggered = true
	if offset_target != null:
		if offset_target is Enemy:
			offset_target.activate()
