@tool
extends Node2D

@export var finish_position: int

func _process(delta: float) -> void:
	$Finish.position.x = finish_position
