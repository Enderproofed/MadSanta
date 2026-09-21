class_name Overlay extends Control

static var current_overlay: Overlay

func _ready() -> void:
	current_overlay = self

func remove():
	if current_overlay == self: current_overlay = null
	queue_free()
