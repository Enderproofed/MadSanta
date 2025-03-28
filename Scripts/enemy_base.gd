extends Node2D

func _ready() -> void:
	var seed = int(global_position.x * global_position.y)
	$Label.text = Namegenerator.generate_full_name()
	
